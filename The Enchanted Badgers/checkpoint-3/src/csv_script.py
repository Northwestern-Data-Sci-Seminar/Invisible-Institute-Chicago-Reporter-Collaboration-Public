import os

def main():
    if not os.path.exists('lda_topic_csv_files'):
        os.makedirs('lda_topic_csv_files')
    with open('lda_topic_csv_files/aggregation.csv', 'w+') as f:
        very_first_line = True
        for i in range(10):
            first_line = True
            with open('lda_topic_csv_files/summary_category_new_category_'+str(i)+'_aggregated.csv') as csv_file:
                lines = csv_file.readlines()
                for line in lines:
                    if very_first_line:
                        very_first_line = False
                        f.write('original_category,new_category,frequency,lda_model\n')
                        continue
                    elif first_line:
                        first_line = False
                        continue
                    f.write(line.rstrip()+',model_'+str(i)+'\n')

if __name__=='__main__':
    main()