# Taupe Control Tint Design

## Goal

Use the app's taupe accent color for the valence slider and its Next button.

## Design

Replace the two ineffective `backgroundStyle(Color.taupe300)` modifiers in
`DiaryWriteScreen.valenceStep` with `tint(.taupe700)`.

`taupe700` is preferred over lighter palette values because it is visible on the
screen's `taupe100` background and already represents selected controls in this
screen. No palette, layout, or reusable style changes are needed.

## Verification

Build the iOS target and verify that the slider accent and Next button tint use
`taupe700` without changing the surrounding background or other wizard steps.
