import spacy
import sys

label_to_character = {
    'PERSON': '|',
    'GPE': '$',
    'ORG': '{'
}

sentence = sys.argv[1]

nlp = spacy.load('en_core_web_sm')
# Remove split on apostrophe because kaldi do not do it
nlp.tokenizer.rules = {key: value for key, value in nlp.tokenizer.rules.items() if "'" not in key and "’" not in key and "‘" not in key}
doc = nlp(sentence)

sentence = sentence.split(" ")

for entity in doc.ents:
    if entity.label_ in label_to_character:
        try:
            sentence[entity.start] = label_to_character[entity.label_] + sentence[entity.start]
            sentence[entity.end-1] += ']'
        except IndexError as error:
            pass

print(' '.join(sentence))