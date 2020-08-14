from subprocess import run, PIPE
import csv
from jiwer import wer

p = '/home/gbaril/e2e-ner/End-to-end-E2E-Named-Entity-Recognition-from-English-Speech/E2E_NER/'

error = 0
num = 0

with open(p + '/data/ner/small_test.csv', newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    i = 0
    for row in reader:
        predicted = run(['bash', '/home/gbaril/kaldi/egs/aspire/s5/transcript.sh', p + row[0]], stdout=PIPE)
        expected = run(['cat', p + row[1]], stdout=PIPE)
        pre = str(predicted.stdout[:-1].upper())
        exp = str(expected.stdout)
        error += wer(pre, exp)
        num += len(exp.split(" "))
        i += 1
        if i % 25 == 0:
            print(i, "done")

print("WER:", float(error)/ num)