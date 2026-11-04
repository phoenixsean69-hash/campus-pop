"""Launch-free QML import validator. Returns nonzero if any imported component fails."""
import sys
from pathlib import Path
from PySide6.QtGui import QGuiApplication, QFontDatabase, QFont
from PySide6.QtQuickControls2 import QQuickStyle
from PySide6.QtQml import QQmlApplicationEngine

project = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parent
qml = project / 'ui' / 'Main.qml'
QQuickStyle.setStyle("Basic")
app = QGuiApplication.instance() or QGuiApplication([])
family = "Nunito" if "Nunito" in QFontDatabase.families() else "Segoe UI"
font_file = project / "assets" / "fonts" / "Nunito.ttf"
if font_file.exists():
    font_id = QFontDatabase.addApplicationFont(str(font_file))
    if font_id >= 0:
        names = QFontDatabase.applicationFontFamilies(font_id)
        if names: family = names[0]
app.setFont(QFont(family, 10))
engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty("appFontFamily", family)
engine.load(str(qml))
if not engine.rootObjects():
    print('FAIL: Qt could not load StudySpace with My Courses.')
    sys.exit(1)
print('PASS: Qt loaded StudySpace including My Courses and its components.')
sys.exit(0)
