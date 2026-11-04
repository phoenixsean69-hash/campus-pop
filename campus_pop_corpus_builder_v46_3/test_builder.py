import tempfile
import unittest
from pathlib import Path
from corpus_builder import Corpus, COURSES, classify, normalized, split_for

class CorpusTests(unittest.TestCase):
    def test_six_courses(self):
        self.assertEqual(len(COURSES),6)
    def test_python(self):
        self.assertEqual(classify("Python (programming language)", "Python syntax and Python interpreter"),"Python Programming")
    def test_statistics(self):
        self.assertEqual(classify("Probability distribution", "Statistical analysis and Bayesian estimation"),"Applied Statistics")
    def test_unknown(self):
        self.assertEqual(classify("Mountain ranges", "The mountain is found in a remote region"),"English Linguistics")
    def test_split(self):
        self.assertEqual(split_for("item123"),split_for("item123"))
    def test_dedup_and_resume(self):
        with tempfile.TemporaryDirectory() as td:
            path=Path(td)
            text="A clear explanation about how code works and why a function can be called when needed."*3
            c=Corpus(path,30,1)
            self.assertTrue(c.add("Intro",text,"Python Programming","test","https://example.org","CC0"))
            self.assertFalse(c.add("Intro",text,"Python Programming","test","https://example.org","CC0"))
            c.close()
            c2=Corpus(path,30,1)
            self.assertGreater(c2.counts["Python Programming"],0)
            self.assertFalse(c2.add("Intro",text,"Python Programming","test","https://example.org","CC0"))
            c2.close()



class FastIOTests(unittest.TestCase):
    def test_flush_writes_manifest_and_record(self):
        with tempfile.TemporaryDirectory() as d:
            c = Corpus(Path(d), 30, 1)
            record = 'A short passage for studying Python functions and programming. ' * 4
            self.assertTrue(c.add('Intro',record,'Python Programming','test','https://example.org','CC0',source_id='flush'))
            c.flush()
            jsonls=list(Path(d).rglob('*.jsonl'))
            self.assertEqual(len(jsonls),1)
            self.assertIn('A short passage',jsonls[0].read_text(encoding='utf-8'))
            c.close()
            c2=Corpus(Path(d),30,1)
            self.assertFalse(c2.add('Intro',record,'Python Programming','test','https://example.org','CC0',source_id='flush'))
            c2.close()

if __name__=="__main__": unittest.main(verbosity=2)
