from __future__ import division
from __future__ import print_function

import os
import glob
import time
import random
import argparse
import numpy as np
import torch
import torch.nn.functional as F
import torch.optim as optim

from utils import get_data
from models import GAT

# Training settings
parser = argparse.ArgumentParser()
parser.add_argument('--no-cuda', action='store_true', default=False,
                    help='Disables CUDA training.')
parser.add_argument('--no-until-year', action='store_true', default=False)
parser.add_argument('--min-year', type=int, default=2000)
parser.add_argument('--max-year', type=int, default=2013)
parser.add_argument('--seed', type=int, default=72, help='Random seed.')
parser.add_argument('--epochs', type=int, default=10000,
                    help='Number of epochs to train.')
parser.add_argument('--lr', type=float, default=0.005,
                    help='Initial learning rate.')
parser.add_argument('--weight_decay', type=float, default=5e-4,
                    help='Weight decay (L2 loss on parameters).')
parser.add_argument('--hidden', type=int, default=4,
                    help='Number of hidden units.')
parser.add_argument('--nb_heads', type=int, default=4,
                    help='Number of head attentions.')
parser.add_argument('--dropout', type=float, default=0.6,
                    help='Dropout rate (1 - keep probability).')
parser.add_argument('--alpha', type=float, default=0.2,
                    help='Alpha for the leaky_relu.')
parser.add_argument('--patience', type=int, default=200, help='Patience')

credential = {
    "database": "cpdb",
    "user": "postgres",
    "password": "12345678",
    "host": "127.0.0.1",
    "port": "5432"
}

args = parser.parse_args()
args.cuda = not args.no_cuda and torch.cuda.is_available()

random.seed(args.seed)
np.random.seed(args.seed)
torch.manual_seed(args.seed)

# Load data
officer_id, features, train_data, val_data, test_data = \
    get_data(is_until_year=not args.no_until_year,
             min_year=args.min_year,
             max_year=args.max_year,
             **credential)

# Model and optimizer
model = GAT(feature_num=features.shape[1],
            hidden_feature_num=args.hidden,
            output_num=1,
            output_softmax=False,
            head_num=args.nb_heads,
            dropout_prob=args.dropout,
            lrelu_alpha=args.alpha)
optimizer = optim.Adam(model.parameters(),
                       lr=args.lr,
                       weight_decay=args.weight_decay)

if args.cuda:
    model.cuda()
    features = features.cuda()
    for i, x in enumerate(train_data):
        if torch.is_tensor(x):
            train_data[i] = x.cuda()
    for i, x in enumerate(val_data):
        if torch.is_tensor(x):
            val_data[i] = x.cuda()
    for i, x in enumerate(test_data):
        if torch.is_tensor(x):
            test_data[i] = x.cuda()


def train(epoch):
    t = time.time()
    # train
    model.train()
    optimizer.zero_grad()
    output = model(features, train_data[0], train_data[1])
    loss_train = F.mse_loss(output[train_data[3]], train_data[2])
    loss_train.backward()
    optimizer.step()

    # Evaluate validation set performance
    model.eval()
    output = model(features, val_data[0], val_data[1])
    loss_val = F.mse_loss(output[val_data[3]], val_data[2])

    print('Epoch: {:04d}'.format(epoch + 1),
          'loss_train: {:.4f}'.format(loss_train.data.item()),
          'loss_val: {:.4f}'.format(loss_val.data.item()),
          'time: {:.4f}s'.format(time.time() - t))

    return loss_val.data.item()


def compute_test():
    model.eval()
    profiler = {}
    output = model(features, test_data[0], test_data[1], profiler)
    loss_test = F.mse_loss(output[test_data[3]], test_data[2])

    a_all_params = [v[0].cpu().numpy()
                    for k, v in profiler.items() if "in_" in k]
    np.savetxt("result/a_all_params.csv",
               np.concatenate(a_all_params, axis=1),
               delimiter=',')
    np.savetxt("result/a_abs_all_params.csv",
               np.abs(np.concatenate(a_all_params, axis=1)),
               delimiter=',')
    np.savetxt("result/a_avg_param.csv",
               np.stack(a_all_params, axis=0).mean(axis=0),
               delimiter=',')
    np.savetxt("result/a_abs_avg_param.csv",
               np.stack(np.abs(a_all_params), axis=0).mean(axis=0),
               delimiter=',')

    f = features.cpu()
    adj = test_data[0]
    target = test_data[2]
    nodes = test_data[3]

    inspect_high_allg_nodes = {}
    inspect_low_allg_nodes = {}
    pre_choose_num = 10
    inspect_num = 3

    for t, n in zip(target, nodes):
        if len(inspect_high_allg_nodes) >= pre_choose_num and \
                len(inspect_low_allg_nodes) >= pre_choose_num:
            break
        if len(inspect_high_allg_nodes) < pre_choose_num and t >= 4:
            inspect_high_allg_nodes[n] = []
        if len(inspect_low_allg_nodes) < pre_choose_num and t == 1:
            inspect_low_allg_nodes[n] = []

    a_all_views = [v[1].cpu()
                   for k, v in profiler.items() if "in_" in k]
    a_avg_view = torch.stack(a_all_views, dim=0).mean(dim=0)

    for h_node, h_node_rel in inspect_high_allg_nodes.items():
        index = adj[:, 0] == h_node
        for adj_row, avg_a_row, *all_a_rows in \
                zip(adj[index], a_avg_view[index],
                    *[v[index] for v in a_all_views]):
            h_node_rel.append((officer_id[(adj_row[1])],    # adjacent officer id in database
                               f[adj_row[1]],               # features of this adjacent officer
                               avg_a_row,                   # averaged softmax attention of this node from all heads
                               all_a_rows))                 # softmax attention of this node from all heads

    for l_node, l_node_rel in inspect_low_allg_nodes.items():
        index = adj[:, 0] == l_node
        for adj_row, avg_a_row, *all_a_rows in \
                zip(adj[index], a_avg_view[index],
                    *[v[index] for v in a_all_views]):
            l_node_rel.append((officer_id[(adj_row[1])],
                               f[adj_row[1]],
                               avg_a_row,
                               all_a_rows))
    # replace relative id with officer id in database
    # and remove nodes with empty adjacent neighbor list
    h_nodes = {officer_id[n]: rel
               for n, rel in inspect_high_allg_nodes.items()
               if len(rel) >= 1}
    l_nodes = {officer_id[n]: rel
               for n, rel in inspect_low_allg_nodes.items()
               if len(rel) >= 1}

    # select 3 nodes for each inspect group,
    h_nodes = {n: rel for ((n, rel), _)
               in zip(h_nodes.items(), range(inspect_num))}
    l_nodes = {n: rel for ((n, rel), _)
               in zip(l_nodes.items(), range(inspect_num))}

    # for manual inspection
    torch.save(h_nodes, "result/h_nodes.pkl")
    torch.save(l_nodes, "result/l_nodes.pkl")

    with open("result/h_attention_report.txt", "w") as f:
        for h_n, h_rel in h_nodes.items():
            f.write("Officer: {}\n".format(h_n))
            f.write("Neighbor num: {}\n".format(len(h_rel)))
            f.write("Neighbors: {}\n".format([hr[0] for hr in h_rel]))
            f.write("Attention mean of neighbors: {}\n".format(
                torch.stack([hr[2] for hr in h_rel], dim=0).mean()
            ))
            f.write("Attention variance of neighbors: {}\n".format(
                torch.stack([hr[2] for hr in h_rel], dim=0).var()
            ))
            f.write("\n")

    with open("result/l_attention_report.txt", "w") as f:
        for l_n, l_rel in l_nodes.items():
            f.write("Officer: {}\n".format(l_n))
            f.write("Neighbor num: {}\n".format(len(l_rel)))
            f.write("Neighbors: {}\n".format([lr[0] for lr in l_rel]))
            f.write("Attention mean of neighbors: {}\n".format(
                torch.stack([lr[2] for lr in l_rel], dim=0).mean()
            ))
            f.write("Attention variance of neighbors: {}\n".format(
                torch.stack([lr[2] for lr in l_rel], dim=0).var()
            ))
            f.write("\n")

    with open("result/l_and_h_node_neighbor_features.csv", "w") as f:
        f.write(",".join(
            ["h_node{}".format(i) for i in h_nodes.keys()] +
            ["l_node{}".format(i) for i in l_nodes.keys()]
        ) + "\n")
        neighbor_features = [
            torch.stack([rel[1] * rel[2] for rel in nrel], dim=0)\
                .mean(dim=0).numpy()
            for nrel in h_nodes.values()
        ] + [
            torch.stack([rel[1] * rel[2] for rel in nrel], dim=0) \
                .mean(dim=0).numpy()
            for nrel in l_nodes.values()
        ]
        np.savetxt(f, np.stack(neighbor_features, axis=1),
                   delimiter=',')

    print("Test set results:",
          "loss= {:.4f}".format(loss_test.data.item()))


# Train model
t_total = time.time()
loss_values = []
bad_counter = 0
best = args.epochs + 1
best_epoch = 0
for epoch in range(args.epochs):
    loss_values.append(train(epoch))

    torch.save(model.state_dict(), 'data/{}.pkl'.format(epoch))
    if loss_values[-1] < best:
        best = loss_values[-1]
        best_epoch = epoch
        bad_counter = 0
    else:
        bad_counter += 1

    if bad_counter == args.patience:
        break

    files = glob.glob('data/*.pkl')
    for file in files:
        epoch_nb = int(file[5:].split('.')[0])
        if epoch_nb < best_epoch:
            os.remove(file)

files = glob.glob('data/*.pkl')
for file in files:
    epoch_nb = int(file[5:].split('.')[0])
    if epoch_nb > best_epoch:
        os.remove(file)

print("Optimization Finished!")
print("Total time elapsed: {:.4f}s".format(time.time() - t_total))

# Restore best model
print('Loading {}th epoch'.format(best_epoch))
model.load_state_dict(torch.load('data/{}.pkl'.format(best_epoch)))

# Testing
compute_test()
