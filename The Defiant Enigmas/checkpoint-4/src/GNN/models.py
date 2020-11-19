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

        self.in_att = [GraphAttentionLayer(feature_num, feature_num,
                                           dropout_prob=dropout_prob,
                                           lrelu_alpha=lrelu_alpha,
                                           concat=True,
                                           identity=True,
                                           name="in_attention_{}".format(i))
                       for i in range(head_num)]
        self.hid_att = [GraphAttentionLayer(feature_num * head_num,
                                            hidden_feature_num,
                                            dropout_prob=dropout_prob,
                                            lrelu_alpha=lrelu_alpha,
                                            concat=True,
                                            name="hid_attention_{}".format(i))
                        for i in range(head_num)]
        for i, attention in enumerate(self.in_att + self.hid_att):
            self.add_module('attention_{}'.format(i), attention)

        self.out_att = GraphAttentionLayer(hidden_feature_num * head_num,
                                           output_num,
                                           dropout_prob=dropout_prob,
                                           lrelu_alpha=lrelu_alpha,
                                           concat=False,
                                           name="out_attention")

    def forward(self, x, adj, adj_weight=None, profiler=None):
        x = F.dropout(x, self.dropout_prob, training=self.training)
        x = torch.cat([att(x, adj, adj_weight, profiler)
                       for att in self.in_att], dim=1)
        x = F.dropout(x, self.dropout_prob, training=self.training)
        x = torch.cat([att(x, adj, adj_weight, profiler)
                       for att in self.hid_att], dim=1)
        x = F.dropout(x, self.dropout_prob, training=self.training)
        x = self.out_att(x, adj, adj_weight, profiler)

        if self.output_softmax:
            return F.log_softmax(F.elu(x), dim=1)
        else:
            return x
