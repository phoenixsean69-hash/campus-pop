"""Offline tests: no API calls, API keys, or PySide6 required."""
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace

from backend.llm_service import (
    StudyMaterialError, read_study_document, ask_model, build_instructions,
    friendly_error,
)


class FakeClient:
    received = None

    def __init__(self, **options):
        self.options = options
        self.responses = self

    def create(self, **kwargs):
        FakeClient.received = kwargs
        return SimpleNamespace(output_text="The example is 2 + 2 = 4.")


class TestTutor(unittest.TestCase):
    def test_request_uses_mode_and_history(self):
        answer, user_content = ask_model(
            api_key="offline-test-key", model="test-model", course="Applied Statistics",
            mode="Guided", level="Step by step", question="What is Bayes theorem?",
            attachment_path="", history=[{"role": "user", "content": "Hi"},
                                           {"role": "assistant", "content": "Hello"}],
            client_factory=FakeClient,
        )
        self.assertIn("2 + 2", answer)
        self.assertEqual("What is Bayes theorem?", user_content)
        self.assertIn("coach", FakeClient.received["instructions"].lower())
        self.assertEqual("test-model", FakeClient.received["model"])
        self.assertEqual(False, FakeClient.received["store"])
        self.assertEqual(3, len(FakeClient.received["input"]))

    def test_text_attachment(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "lecture.txt"
            p.write_text("Bayes updates probabilities from evidence.", encoding="utf-8")
            name, content = read_study_document(str(p))
            self.assertEqual(name, "lecture.txt")
            self.assertIn("Bayes", content)
            answer, used = ask_model(api_key="offline-test-key", model="model",
                                     course="Statistics", mode="Summarise", level="Concise",
                                     question="Summarise", attachment_path=str(p), history=[],
                                     client_factory=FakeClient)
            self.assertIn("UNTRUSTED STUDY MATERIAL", used)
            self.assertNotIn(str(p), used)

    def test_reject_unknown_file_type(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "lecture.exe"
            p.write_bytes(b"nothing")
            with self.assertRaises(StudyMaterialError):
                read_study_document(str(p))

    def test_auth_message_is_safe(self):
        result = friendly_error(RuntimeError("Error 401 invalid_api_key secret-value"))
        self.assertNotIn("secret-value", result)

    def test_missing_key(self):
        with self.assertRaises(RuntimeError):
            ask_model(api_key="", model="model", course="Math", mode="Explain",
                      level="Concise", question="Hi", attachment_path="", history=[],
                      client_factory=FakeClient)


if __name__ == "__main__":
    unittest.main()
