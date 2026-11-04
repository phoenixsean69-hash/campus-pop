from backend.tutor_bridge import TutorBridge
from backend.library_bridge import LibraryBridge
"""StudySpace local QML validation. Execute using Storm's .venv Python."""
import os
import sys
from pathlib import Path
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from backend.studyspace_state import PreferencesBridge, WorkspaceBridge
from backend.profile_bridge import ProfileBridge

QQuickStyle.setStyle("Basic")
app = QGuiApplication(sys.argv)
app.setApplicationName("StudySpace")
app.setOrganizationName("Storm")
root = Path(__file__).resolve().parent
qml = root / "ui" / "Main.qml"
if not qml.is_file():
    print(f"FAIL: Missing {qml}", file=sys.stderr)
    sys.exit(1)
engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty("appFontFamily", "Nunito")
settings_bridge = PreferencesBridge()
workspace_bridge = WorkspaceBridge()
engine.rootContext().setContextProperty("settingsBridge", settings_bridge)
engine.rootContext().setContextProperty("workspaceBridge", workspace_bridge)
# CAMPUS_POP_PROFILE_V25
profile_bridge = ProfileBridge(settings_bridge)
engine.rootContext().setContextProperty("profileBridge", profile_bridge)
tutor_bridge = TutorBridge(Path(__file__).resolve().parent, workspace_bridge, profile=profile_bridge)
engine.rootContext().setContextProperty("tutorBridge", tutor_bridge)
# CAMPUS_POP_LIBRARY_V26
library_bridge = LibraryBridge()
engine.rootContext().setContextProperty("libraryBridge", library_bridge)
engine.warnings.connect(lambda messages: [print(f"QML warning: {m.toString()}") for m in messages])
engine.load(QUrl.fromLocalFile(str(qml)))
if not engine.rootObjects():
    print("FAIL: Qt could not load the StudySpace interface.", file=sys.stderr)
    sys.exit(1)
print("PASS: Qt loaded StudySpace Main.qml and its imported components.")
sys.exit(0)
