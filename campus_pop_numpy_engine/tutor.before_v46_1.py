"""Reliable offline lesson retrieval + explicit concept-checking scaffold.

This is not a generative LLM. It complements the experimental neural_lm.py.
"""
import json
import re
from pathlib import Path
import numpy as np

DATA = Path(__file__).with_name('knowledge.json')


def words(text):
    return re.findall(r"[a-zA-Z_][a-zA-Z_0-9]*", text.lower())


class OfflineTutor:
    def __init__(self, source=DATA):
        self.lessons = json.loads(Path(source).read_text(encoding='utf-8'))
        self.docs = [item['title'] + ' ' + ' '.join(item['keywords']) + ' ' + item['summary'] for item in self.lessons]
        self.vocab = sorted(set(token for doc in self.docs for token in words(doc)))
        self.term_to_col = {word: i for i, word in enumerate(self.vocab)}
        tf = np.zeros((len(self.docs), len(self.vocab)), np.float32)
        for i, doc in enumerate(self.docs):
            for token in words(doc):
                tf[i, self.term_to_col[token]] += 1
        df = (tf > 0).sum(axis=0)
        self.idf = np.log((len(self.docs) + 1) / (df + 1)) + 1
        self.index = self._normalize(tf * self.idf)
        self.last_topic = None

    @staticmethod
    def _normalize(x):
        return x / np.maximum(np.linalg.norm(x, axis=-1, keepdims=True), 1e-8)

    def retrieve(self, message):
        vec = np.zeros((1, len(self.vocab)), np.float32)
        for token in words(message):
            if token in self.term_to_col:
                vec[0, self.term_to_col[token]] += 1
        vec = self._normalize(vec * self.idf)
        scores = (self.index @ vec[0])
        i = int(np.argmax(scores))
        return (self.lessons[i], float(scores[i])) if scores[i] > .07 else (None, 0.0)

    def respond(self, message):
        """Grounded explanations only; never claim to have graded open-ended code."""
        message = message.strip()
        if not message:
            return 'What would you like to learn about Python functions?'
        lower = message.lower()
        if any(x in lower for x in ('another example', 'more example', 'simpler', 'explain again')) and self.last_topic is not None:
            lesson = self.last_topic
        else:
            lesson, confidence = self.retrieve(message)
            if lesson is None:
                return ('I am not confident I understood that question. '
                        'You can ask about defining functions, parameters, arguments, return values, or calling functions.')
        self.last_topic = lesson
        if any(x in lower for x in ('quiz', 'question', 'exercise', 'test me', 'practice')):
            return lesson['question']
        if 'example' in lower or 'simpler' in lower:
            return lesson['example']
        return f"{lesson['summary']}\n\n{lesson['explanation']}\n\nTry this: {lesson['question']}"


def main():
    tutor = OfflineTutor()
    print('Campus Pop offline grounded tutor | type /quit to exit')
    while True:
        try:
            text = input('You: ')
        except (EOFError, KeyboardInterrupt):
            break
        if text.strip() == '/quit':
            break
        print('Tutor:', tutor.respond(text), '\n')

if __name__ == '__main__':
    main()
