import torch
import torch.nn as nn
import torch.nn.functional as F
from layers import GraphAttentionLayer


class GAT(nn.Module):
    def __init__(self,
                 feature_num,
                 hidden_feature_num,
                 output_num,
                 head_num,
                 dropout_prob,
                 lrelu_alpha,
                 output_softmax=True):
        """Dense version of GAT."""
        super(GAT, self).__init__()
        self.dropout_prob = dropout_prob
        self.output_softmax = output_softmax

        self.attentions = [GraphAttentionLayer(feature_num, hidden_feature_num,
                                               dropout_prob=dropout_prob,
                                               lrelu_alpha=lrelu_alpha,
                                               concat=True)
                           for _ in range(head_num)]
        for i, attention in enumerate(self.attentions):
            attention.name = 'attention_{}'.format(i)
            self.add_module('attention_{}'.format(i), attention)

        self.out_att = GraphAttentionLayer(hidden_feature_num * head_num,
                                           output_num,
                                           dropout_prob=dropout_prob,
                                           lrelu_alpha=lrelu_alpha,
                                           concat=False)

    def forward(self, x, adj, adj_weight=None):
        x = F.dropout(x, self.dropout_prob, training=self.training)
        x = torch.cat([att(x, adj, adj_weight) for att in self.attentions],
                      dim=1)
        x = F.dropout(x, self.dropout_prob, training=self.training)
        x = self.out_att(x, adj, adj_weight)

        if self.output_softmax:
            return F.log_softmax(F.elu(x), dim=1)
        else:
            return x
