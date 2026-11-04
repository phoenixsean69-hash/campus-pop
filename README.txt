StudySpace Quick Actions v6: replaces ONLY ui/components/cards/QuickActions.qml
and adds ui/components/buttons/DuoActionCard.qml.

These buttons are not instances of DuoButton.qml; they need a specialized
card component to show both title and subtitle. This fixes the previous
patch changing other controls but not Quick Actions.

Run validate_ui.py before main.py. Buttons lift on hover, show a beveled face
with a thick lower extrusion, compress while pressed, and wobble on click.
Navigation is delayed 235ms to make the click animation visible.

The component adds no database or AI behavior.
