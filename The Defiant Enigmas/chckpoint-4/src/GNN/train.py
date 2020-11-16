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
parser.add_argument('--hidden', type=int, default=8,
                    help='Number of hidden units.')
parser.add_argument('--nb_heads', type=int, default=8,
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
features, train_data, val_data, test_data = get_data(is_until_year=not args.no_until_year,
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
    output = model(features, test_data[0], test_data[1])
    loss_test = F.mse_loss(output[test_data[3]], test_data[2])
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
