import torch
import torch.nn as nn
import torch.nn.functional as F


class GraphAttentionLayer(nn.Module):
    """
    Simple GAT layer, similar to https://arxiv.org/abs/1710.10903
    """

    def __init__(self,
                 in_features, out_features,
                 dropout_prob,
                 lrelu_alpha,
                 identity=False,
                 concat=True,
                 name=None):
        super(GraphAttentionLayer, self).__init__()
        self.dropout_prob = dropout_prob
        self.in_features = in_features
        self.out_features = out_features
        self.lrelu_alpha = lrelu_alpha
        self.concat = concat
        self.name= name
        self.identity = identity

        if identity and in_features != out_features:
            raise RuntimeError
        else:
            self.W = nn.Parameter(torch.empty(size=(in_features, out_features)))
            nn.init.xavier_uniform_(self.W.data, gain=1.414)
        self.a = nn.Parameter(torch.empty(size=(2 * out_features, 1)))
        nn.init.xavier_uniform_(self.a.data, gain=1.414)

        self.leakyrelu = nn.LeakyReLU(self.lrelu_alpha)

    def forward(self, h, adj, adj_weight=None, profiler=None):
        # note: adjacency matrix is flattened, of size [E, 2]
        # adj_weight.shape = [E, 1]
        # where E is the number of edges.
        # The first element of dim 1 is start node, and second element is
        # end node.
        # like: (0, 1) (1, 0) (1, 2) (1, 3) (1, 4) (2, 1) (2, 4) (3, 4)

        # h.shape: [N, in_features], Wh.shape: [N, out_features]
        # where N is the number of nodes.
        if not self.identity:
            Wh = torch.mm(h, self.W)
        else:
            Wh = h
        # a_input.shape: [E, 2 * out_features]
        # where second dim is concatenation of (Wh_i, Wh_j)
        a_input = self._get_attention_input(Wh, adj)

        # if adj_weight is not None:
        #     a_input = a_input * adj_weight

        # attention.shape: [E, 1]
        att1 = self.leakyrelu(torch.mm(a_input, self.a))

        att2 = self.indexed_softmax(h.shape[0], att1, adj)
        att3 = F.dropout(att2, self.dropout_prob,
                         training=self.training)
        h_prime = self.indexed_multiply_and_gather(att3, Wh, adj)

        if profiler is not None:
            profiler[self.name] = (self.a.data.clone(), att2.data.clone())

        if self.concat:
            return F.elu(h_prime)
        else:
            return h_prime

    def _get_attention_input(self, Wh, adj):
        return torch.cat([Wh[adj[:, 0]], Wh[adj[:, 1]]], dim=1)

    @staticmethod
    def indexed_softmax(N, x, adj):
        # x must be of shape [E, 1], adj must be of shape [E, 2]
        # prevent infinity caused nan
        x_exp = x.exp().clamp(0, 1e6)
        denom = torch.index_add(torch.full([N, 1], 1e-10,
                                           dtype=torch.float32,
                                           device=x.device),
                                dim=0, index=adj[:, 0], source=x_exp)
        denom = denom[adj[:, 0]]
        return x_exp / denom

    @staticmethod
    def indexed_multiply_and_gather(x, Wh, adj):
        new_expanded_Wh = Wh[adj[:, 1]] * x
        return torch.index_add(torch.zeros_like(Wh), dim=0,
                               index=adj[:, 0], source=new_expanded_Wh)

    def __repr__(self):
        return self.__class__.__name__ + ' (' + str(
            self.in_features) + ' -> ' + str(self.out_features) + ')'
