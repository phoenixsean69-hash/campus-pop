"""Tiny character-level neural language model, using NumPy only.

Research/learning prototype; NOT a general-purpose LLM.
Architecture: context character embedding -> tanh hidden -> next-character logits.
"""
import argparse
import json
from pathlib import Path
import numpy as np

DEFAULT_CORPUS = Path(__file__).with_name('training_text.txt')
DEFAULT_WEIGHTS = Path(__file__).with_name('tiny_model.npz')


class TinyCharLM:
    def __init__(self, alphabet, context=12, embed=16, hidden=96, seed=42):
        self.alphabet = list(alphabet)
        self.lookup = {char: i for i, char in enumerate(self.alphabet)}
        self.context = int(context)
        self.embed = int(embed)
        self.hidden = int(hidden)
        rng = np.random.default_rng(seed)
        v = len(self.alphabet)
        self.E = (rng.normal(0, .1, (v, embed))).astype(np.float32)
        self.W1 = (rng.normal(0, .045, (context * embed, hidden))).astype(np.float32)
        self.b1 = np.zeros(hidden, np.float32)
        self.W2 = (rng.normal(0, .045, (hidden, v))).astype(np.float32)
        self.b2 = np.zeros(v, np.float32)
        self.unk = self.lookup.get(' ', 0)

    def ids(self, text):
        return np.fromiter((self.lookup.get(char, self.unk) for char in text), dtype=np.int32)

    def train(self, text, steps=600, batch_size=128, learning_rate=.06, seed=7):
        ids = self.ids(text)
        if len(ids) < self.context + 2:
            raise ValueError('Training corpus is too short.')
        rng = np.random.default_rng(seed)
        offsets = np.arange(self.context, dtype=np.int32)
        for step in range(steps):
            locs = rng.integers(self.context, len(ids), size=batch_size)
            x = ids[locs[:, None] - self.context + offsets]
            y = ids[locs]
            z = self.E[x].reshape(batch_size, -1)
            h = np.tanh(z @ self.W1 + self.b1)
            logits = h @ self.W2 + self.b2
            logits -= np.max(logits, axis=1, keepdims=True)
            probs = np.exp(logits)
            probs /= probs.sum(axis=1, keepdims=True)
            loss = -np.log(np.maximum(probs[np.arange(batch_size), y], 1e-10)).mean()
            # Backpropagate next-character cross-entropy.
            grad = probs
            grad[np.arange(batch_size), y] -= 1
            grad /= batch_size
            dW2 = h.T @ grad
            db2 = grad.sum(axis=0)
            dh = (grad @ self.W2.T) * (1 - h * h)
            dW1 = z.T @ dh
            db1 = dh.sum(axis=0)
            dz = (dh @ self.W1.T).reshape(batch_size, self.context, self.embed)
            # Clip gradients to stabilize small-model training.
            for g in (dW1, db1, dW2, db2, dz):
                np.clip(g, -1.0, 1.0, out=g)
            self.W2 -= learning_rate * dW2
            self.b2 -= learning_rate * db2
            self.W1 -= learning_rate * dW1
            self.b1 -= learning_rate * db1
            np.add.at(self.E, x, -learning_rate * dz)
            if (step + 1) % 200 == 0:
                print(f'step {step+1}/{steps} | loss {loss:.3f}')

    def generate(self, seed_text='A Python function', n_chars=200, temperature=.75, seed=123):
        if temperature <= 0:
            raise ValueError('temperature must be positive')
        rng = np.random.default_rng(seed)
        result = seed_text
        for _ in range(n_chars):
            context = (' ' * self.context + result)[-self.context:]
            x = self.ids(context)
            z = self.E[x].reshape(1, -1)
            h = np.tanh(z @ self.W1 + self.b1)
            logits = ((h @ self.W2 + self.b2)[0] / temperature)
            logits -= logits.max()
            p = np.exp(logits)
            p /= p.sum()
            result += self.alphabet[int(rng.choice(len(self.alphabet), p=p))]
        return result

    def save(self, path=DEFAULT_WEIGHTS):
        np.savez_compressed(path, alphabet=np.array(self.alphabet), context=self.context,
                            embed=self.embed, hidden=self.hidden, E=self.E, W1=self.W1,
                            b1=self.b1, W2=self.W2, b2=self.b2)

    @classmethod
    def load(cls, path=DEFAULT_WEIGHTS):
        with np.load(path, allow_pickle=False) as weights:
            model = cls(weights['alphabet'].tolist(), int(weights['context']),
                        int(weights['embed']), int(weights['hidden']))
            for name in ('E', 'W1', 'b1', 'W2', 'b2'):
                setattr(model, name, weights[name].copy())
        return model


def main():
    parser = argparse.ArgumentParser(description='Experimental NumPy character language model')
    parser.add_argument('mode', choices=['train', 'generate'])
    parser.add_argument('--steps', type=int, default=600)
    parser.add_argument('--prompt', default='A Python function')
    parser.add_argument('--chars', type=int, default=200)
    parser.add_argument('--temperature', type=float, default=.75)
    args = parser.parse_args()
    if args.mode == 'train':
        corpus = DEFAULT_CORPUS.read_text(encoding='utf-8')
        alphabet = sorted(set(corpus + args.prompt + ' '))
        model = TinyCharLM(alphabet)
        model.train(corpus, steps=args.steps)
        model.save()
        print('Saved:', DEFAULT_WEIGHTS)
    else:
        if not DEFAULT_WEIGHTS.exists():
            parser.error('Run train first to generate model weights.')
        print(TinyCharLM.load().generate(args.prompt, args.chars, args.temperature))

if __name__ == '__main__':
    main()
