# Campus Pop V46.2 — course-aware offline tutor prototype

This update expands the previous Python Functions-only terminal tutor to a **course-aware local reference and teaching prototype**. It preserves the improved Python Functions dialogue while adding a dynamic course catalog, limited introductory lessons, course-scoped NumPy retrieval, and local note imports.

This is **not a pretrained large language model**. It cannot understand arbitrary phrasing reliably, generate fluent answers from arbitrary PDFs, reliably summarize whole textbooks, or assess open-ended answers. The tiny character generator is **not** used as the teaching model. Do not connect this version to the live QML tutor as a replacement for a production LLM yet.

## What's included

- Six starter course entries: Applied Statistics, Python Programming, Computer Systems, Software Engineering, Discrete Mathematics, Database Systems.
- 21 brief built-in starter topics shared across those six subjects. These are introductory references, **not a full course syllabus**, not original student notes, and not verified against the university's course outlines.
- Dynamic user courses stored in `course_data/courses.json`.
- Optional JSON catalog sync via `/synccourses` for future connection to Campus Pop's `My Courses` data.
- Import `.txt`, `.md`, `.csv`, `.py`, `.pdf` (text PDFs), and `.docx` per course. Original files are copied into `course_data/materials/<course-id>/`, and imported notes remain on-device. File source names and PDF page numbers are displayed when possible.
- Course-specific NumPy TF–IDF nearest-passage retrieval. If the evidence is insufficient, the tutor says so rather than inventing material.
- Keeps the earlier Python Functions novice explanations, terminology clarification and line-by-line walkthrough.
- No exercise result is treated as independently assessed mastery.

## Install

1. Type `/quit` in the terminal tutor.
2. Download `campus_pop_numpy_engine_v46_2_multicourse.zip` into your Windows Downloads folder.
3. **Back up the existing `tutor.py`** and extract this patch into your existing Storm folder. See the ready-to-paste PowerShell commands in the ChatGPT response accompanying the package.
4. Run both test suites, then launch the terminal tutor.

This patch presumes `numpy` is already installed and the previous V46.1 engine is present, including `knowledge.json`, `neural_lm.py`, and `test_engine.py`. PDF and DOCX import also require `pypdf` and `python-docx`. Packages are required only at installation; the tutor works without an internet connection afterward.

## Example transcript

```text
You: /courses
You: /course "Applied Statistics"
You: What is a population and sample?
You: Explain that like I'm completely new to statistics.
You: Give me an exercise
You: /course "Database Systems"
You: What is a primary key?
You: /addcourse "Business Administration"
You: /import "C:\Users\nooklyweb\Documents\Business Notes\BS101.pdf"
You: /sources
You: /synccourses "C:\path\to\my_courses.json"
```

`/synccourses` accepts either `[{"name":"Business Administration"}, {"name":"Chemistry"}]`, `["Business Administration","Chemistry"]`, or `{"courses": [...]}`.

## Integration with the Campus Pop desktop application

The terminal program is not yet wired to the QML AI Tutor or the application's real course store. When integrating, the Python/PySide6 backend should pass the **currently selected course ID**, the student's course names, and that course's actual file paths into the library before asking `MultiCourseTutor.respond(message)`.

Recommended integration points:

- `My Courses`: register the actual enrolled/user-created courses through `CourseLibrary.sync_course_names(...)` and map the app's course identifiers to the engine identifiers.
- `Notes & Files`: import or index files belonging to the selected course using `CourseLibrary.import_path(course_id, path)`.
- `AI Tutor`: select `MultiCourseTutor.select_course(name)` when the active course changes; then call `respond` for messages.
- `Practice Lab / Performance`: **do not infer mastery from these ungraded text responses**; link only to validated exercise/grading results.

Before deployment, inspect the actual Campus Pop storage schema and connect these calls explicitly; no interface schema has been assumed here.

## Accuracy & limitations

- The reference snippets and handcrafted starter answers are not LLM generation. The engine does not yet produce novel fluent explanations of arbitrary imported material.
- Retrieval confidence is heuristic, not a guarantee of correctness. Always review results in real course material.
- Image-only/scanned PDF pages require separate OCR work and are not imported as text.
- Documents over 12 MB per file are skipped; PDF ingestion is limited to the first 150 pages per file.
- No uploaded notes leave the local computer through this package; it uses no online APIs.
- No desktop UI integration, shared study history, semantic grading, personalized mastery, or fine-tuned local pretrained LLM is included.
