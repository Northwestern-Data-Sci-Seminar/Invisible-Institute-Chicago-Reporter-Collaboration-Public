{
    "dataset_reader" : {
        "type": "complaint_tsv_reader",
        "token_indexers": {
            "tokens": {
                "type": "single_id"
            }
        }
    },
    "train_data_path": "data/complaints/train_prepped.tsv",
    "validation_data_path": "data/complaints/valid_prepped.tsv",
    "model": {
        "type": "complaint_classifier",
        "embedder": {
            "token_embedders": {
                "tokens": {
                    "type": "embedding",
                    "embedding_dim": 10
                }
            }
        },
        "encoder": {
            "type": "bag_of_embeddings",
            "embedding_dim": 10
        }
    },
    "data_loader": {
        "batch_size": 8,
        "shuffle": true
    },
    "trainer": {
        "optimizer": "adam",
        "num_epochs": 10
    }
}
