# Changelog

**Daily maintenance campaign — 1 to 20 November 2026, 10 updates per day.**
The UI is frozen: no entry below changes CSS, HUD, menus, layout or styling.
Every item is a bug fix, a performance optimisation or a fluidity improvement.

## 2026-10-31 — pre-campaign fixes
- Fixed a per-frame exception (`rp` was both the rain-drop array and the roll-rate spring) that aborted the render loop every frame.
- Cockpit camera sat *inside* the car body; it is now a hood cam just above the roof.
- Added lateral tyre grip + a grip-based yaw cap: the car tracks its nose instead of spinning out off-road (slip angle 23° → 7°).
- Replaced the teleporting off-road clamp with real guardrails; the rail now guides the car along instead of stopping it dead.
- Clamped suspension travel so a hard impact can no longer tilt the body through the floor.
- Wet asphalt re-tuned: dark and glossy instead of washed-out white.
- Countdown now runs on wall-clock time, so it no longer drags on slow devices.
- Default quality raised to High; adaptive resolution floored at 85% so the image never goes blurry.

## 2026-11-01
<!-- scheduled runs append below this line -->
