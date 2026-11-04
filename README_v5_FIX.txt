StudySpace Campus Pop — v5 Layout & Scroll Hotfix

Fixes:
1. WeeklyChart.qml — fixed-width stats column and explicit x/y chart geometry. The bars, weekday labels and horizontal grid can no longer collapse into the left edge because of RowLayout sizing.
2. QuickActions.qml — compact 2x2 button grid with fixed 62px button heights, tighter shadows, centered labels and preserved page navigation.
3. Main.qml — bounded, pixel-aligned scrolling with controlled flick velocity, and a content height that cannot be smaller than the viewport.

Only these three existing UI files are replaced. The package does not touch main.py, Nunito, the sidebar, assets or services.

Installation from PowerShell in the Storm directory:
  Expand-Archive -LiteralPath "$HOME\Downloads\StudySpace_CampusPop_LayoutScroll_v5.zip" -DestinationPath "." -Force
  .\.venv\Scripts\python.exe validate_ui.py
  if ($LASTEXITCODE -eq 0) { .\.venv\Scripts\python.exe main.py }

The runtime window must be validated on Windows / PySide6 Qt 6.12.0. This patch has undergone source-level static checks, not a Qt runtime launch in the build environment.
