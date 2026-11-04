"""StudySpace Campus Pop — interface preview (no backend services)."""
import sys
from pathlib import Path
from PySide6.QtCore import QUrl
from PySide6.QtGui import QFont, QFontDatabase, QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from backend.studyspace_state import PreferencesBridge, WorkspaceBridge
from backend.profile_bridge import ProfileBridge
from backend.tutor_bridge import TutorBridge

from backend.library_bridge import LibraryBridge
def main():
    QQuickStyle.setStyle("Basic")
    # CAMPUS_POP_BRAND_V22 — Windows taskbar identity (not the QSettings ID).
    if sys.platform == "win32":
        try:
            import ctypes
            ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID("CampusPop.StudyPartner.Desktop")
        except (OSError, AttributeError):
            pass
    app = QGuiApplication(sys.argv)
    app.setApplicationName("StudySpace")
    app.setOrganizationName("Storm")
    root = Path(__file__).resolve().parent
    # Set the real app/taskbar icon and visible branding.
    campus_pop_icon = QIcon(str(root / "assets" / "branding" / "campus_pop.ico"))
    app.setWindowIcon(campus_pop_icon)
    app.setApplicationDisplayName("Campus Pop")
    font_file = root / "assets" / "fonts" / "Nunito.ttf"
    family = "Nunito" if "Nunito" in QFontDatabase.families() else "Segoe UI"
    if font_file.exists():
        font_id = QFontDatabase.addApplicationFont(str(font_file))
        if font_id >= 0:
            loaded = QFontDatabase.applicationFontFamilies(font_id)
            if loaded: family = loaded[0]
    app.setFont(QFont(family, 10))
    print(f"StudySpace font: {family}")
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("appFontFamily", family)
    settings_bridge = PreferencesBridge()
    workspace_bridge = WorkspaceBridge()
    engine.rootContext().setContextProperty("settingsBridge", settings_bridge)
    engine.rootContext().setContextProperty("workspaceBridge", workspace_bridge)
    # CAMPUS_POP_PROFILE_V25
    profile_bridge = ProfileBridge(settings_bridge)
    engine.rootContext().setContextProperty("profileBridge", profile_bridge)
    tutor_bridge = TutorBridge(root, workspace_bridge, profile=profile_bridge)
    engine.rootContext().setContextProperty("tutorBridge", tutor_bridge)
    # CAMPUS_POP_LIBRARY_V26
    library_bridge = LibraryBridge()
    engine.rootContext().setContextProperty("libraryBridge", library_bridge)
    engine.load(QUrl.fromLocalFile(str(root / "ui" / "Main.qml")))
    # Explicit Qt Quick window icon; ensures titlebar/taskbar consistency.
    for campus_window in engine.rootObjects():
        if hasattr(campus_window, "setIcon"):
            campus_window.setIcon(campus_pop_icon)
    if not engine.rootObjects():
        print("Unable to load main QML window", file=sys.stderr)
        return 1
    return app.exec()

if __name__ == "__main__":
    raise SystemExit(main())
