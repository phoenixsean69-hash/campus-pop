"""Tests for the bounded Campus Pop offline prototype."""
import unittest
from tutor import OfflineTutor
from neural_lm import TinyCharLM


class Tests(unittest.TestCase):
    def test_retrieval(self):
        tutor = OfflineTutor()
        self.assertIn('parameter', tutor.respond('What is the difference between parameters and arguments?').lower())
        self.assertIn('return', tutor.respond('Explain return values').lower())

    def test_followup_another_example(self):
        tutor = OfflineTutor()
        tutor.respond('What are parameters and arguments?')
        self.assertIn('number is parameter', tutor.respond('another example'))

    def test_unknown_is_not_hallucinated(self):
        tutor = OfflineTutor()
        self.assertIn("can't reliably interpret", tutor.respond('xylophone marmalade orbit'))

    def test_neural_generator_smoke(self):
        model = TinyCharLM(sorted(set('abc ')), context=3, embed=4, hidden=8)
        model.train('abc abc abc abc abc abc ', steps=3, batch_size=4)
        output = model.generate('abc', n_chars=6)
        self.assertEqual(len(output), 9)
        self.assertTrue(all(c in 'abc ' for c in output))

    def test_specific_beginner_followup(self):
        tutor = OfflineTutor()
        tutor.respond('What is a Python function?')
        text = tutor.respond("Explain that like I'm completely new to programming. I don't understand what def, parentheses or indentation mean.")
        for expected in ['def:', 'Parentheses ()', 'Indentation:', 'greet()', 'four spaces']:
            self.assertIn(expected.lower(), text.lower())
        self.assertNotIn("Try this: Write a function", text)

    def test_followup_without_keywords_keeps_context(self):
        tutor = OfflineTutor()
        tutor.respond('Explain parameters and arguments')
        response = tutor.respond("I'm still confused. Explain it simply.")
        self.assertIn('parameter', response.lower())
        self.assertIn('argument', response.lower())

    def test_accepts_offered_line_by_line_followup(self):
        tutor = OfflineTutor()
        tutor.respond('What is a Python function?')
        tutor.respond("I'm new and I don't understand def and indentation")
        response = tutor.respond('Yes, please')
        self.assertIn('one line at a time', response.lower())
        self.assertIn('four spaces', response.lower())

    def test_topic_switch_outside_scope(self):
        tutor = OfflineTutor()
        tutor.respond('What is a Python function?')
        response = tutor.respond('How do I make a Python list?')
        self.assertIn('different python topic', response.lower())
        self.assertNotIn('write def', response.lower())

    def test_no_auto_exercise_after_explanation(self):
        tutor = OfflineTutor()
        result = tutor.respond('What is a Python function?')
        self.assertNotIn('Try this:', result)

    def test_parameter_argument_distinction(self):
        tutor = OfflineTutor()
        result = tutor.respond('I am new: what is the difference between parameter and argument?')
        self.assertIn("'Rudo'", result)
        self.assertIn('parameter', result.lower())
        self.assertIn('argument', result.lower())

    def test_reset_removes_context(self):
        tutor = OfflineTutor()
        tutor.respond('Explain return values')
        self.assertIn('reset', tutor.respond('/reset').lower())
        self.assertIn("can't reliably interpret", tutor.respond("Explain it again").lower())

    def test_explicit_practice_has_no_mastery_claim(self):
        tutor = OfflineTutor()
        tutor.respond('What is a Python function?')
        result = tutor.respond('Give me an exercise')
        self.assertIn('cannot certify mastery', result.lower())


if __name__ == '__main__':
    unittest.main(verbosity=2)
