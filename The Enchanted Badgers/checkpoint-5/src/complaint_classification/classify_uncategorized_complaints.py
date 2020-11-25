import json
import plac
from complaint_classifier_module.predictors.sentence_classifier_predictor import SentenceClassifierPredictor
from allennlp.models.archival import load_archive
from allennlp.data.vocabulary import Vocabulary
from allennlp.models import Model


@plac.annotations(
    archive_string=plac.Annotation("Path to the model.tar.gz file. (e.g. boe_model/model.tar.gz).", "positional", None, str)
)
def main(archive_string):
    # archive_string = "boe_model/model.tar.gz"
    data_path_string = "uncategorized_integration/formatted_uncategorized_complaints.json"

    # Load the trained model from the archive
    complaint_archive = load_archive(archive_string)
    predictor = SentenceClassifierPredictor.from_archive(complaint_archive)
    print(predictor)

    with open(data_path_string) as uncat_complaints_file:
        # Load in the model and vocabulary
        model = Model.from_archive(archive_string)
        vocab = model.vocab

        # Predict the classes for each sample
        results = []
        for line in uncat_complaints_file:
            line_dict = json.loads(line)
            result = predictor.predict(line_dict['sentence'])
            results.append(result)

        # Print/write the class and probability for the class with the highest probability
        counts = {}
        for i in range(len(results[0]['probs'])):
            label = vocab.get_token_from_index(i, 'labels')
            counts[label] = 0
        for result in results:
            idx = result['probs'].index(max(result['probs']))
            label = vocab.get_token_from_index(idx, 'labels')
            counts[label] += 1
            # print(vocab.get_token_from_index(idx, 'labels'))

        # print(json.dumps(counts))

        # Open a file and dump the dictionary to it
        sample_file = open("uncategorized_results.json", "w")
        sample_file.write(json.dumps(counts))
        sample_file.close()

if __name__ == "__main__":
    plac.call(main)