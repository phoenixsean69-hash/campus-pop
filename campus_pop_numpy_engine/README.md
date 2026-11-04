# Campus Pop V46.1 — Offline Tutor Linguistic Repair

This patch addresses the specific regression where the tutor repeats its initial Python Functions explanation after a beginner asks what `def`, parentheses and indentation mean.

**Capabilities:** human-reviewed concept definitions, a step-by-step worked example, multi-term clarification, basic follow-up/topic tracking, lesson retrieval using NumPy, and conservative out-of-scope answers.

**Limitations:** this is **not a fluent large language model**. It is an offline rule-guided tutoring scaffold with NumPy similarity retrieval. The character neural model in `neural_lm.py` remains separate and is intentionally **not** used to provide lessons. Open-ended code answers are **not graded**, and the tutor does **not award mastery**. An appropriately pretrained small language model is necessary for broad, natural dialogue.

## PowerShell install/update

1. Exit the tutor by entering `/quit`.
2. Save `campus_pop_numpy_engine_v46_1.zip` to your Downloads folder.
3. Paste:

```powershell
$Project = "C:\Users\nooklyweb\Documents\Python Projects\Storm"
$Zip = Join-Path $env:USERPROFILE "Downloads\campus_pop_numpy_engine_v46_1.zip"
$Engine = Join-Path $Project "campus_pop_numpy_engine"
$Python = Join-Path $Project ".venv\Scripts\python.exe"
if (!(Test-Path $Zip)) { throw "Download ZIP first: $Zip" }
if (!(Test-Path $Python)) { throw "Python not found: $Python" }
if (Test-Path (Join-Path $Engine "tutor.py")) {
    Copy-Item (Join-Path $Engine "tutor.py") (Join-Path $Engine "tutor.before_v46_1.py") -Force
}
Expand-Archive -Path $Zip -DestinationPath $Project -Force
Push-Location $Engine
try {
    & $Python -m pip install numpy
    if ($LASTEXITCODE -ne 0) { throw "NumPy installation failed" }
    & $Python test_engine.py
    if ($LASTEXITCODE -ne 0) { throw "Automated tests failed" }
    & $Python tutor.py
} finally { Pop-Location }
```

## Regression conversation

```
You: What is a Python function?
You: Explain that like I'm completely new to programming. I don't understand what def, parentheses or indentation mean.
```

The tutor should now explain all three named terms and give a worked example. Try `How do I make a Python list?` to check that it declines unrelated content rather than switching to a function lesson. Try `/reset` to clear context.
