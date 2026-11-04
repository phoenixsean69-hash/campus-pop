StudySpace v2 QML hotfix - 2026-11-02

Fixes invalid object binding in HybridPanel.qml line 117:
    background: Item { }; onAccepted: ...
The TextField is now expanded to separate QML properties.
Also declares index in the schedule Repeater delegate.

Install: Unzip into the Storm project directory with overwrite enabled.
Run the local QML load test before opening the app:
    .\.venv\Scripts\python.exe validate_ui.py
If it says PASS, launch normally:
    .\.venv\Scripts\python.exe main.py

This patch does not alter the Python environment, the fonts, or app data.
