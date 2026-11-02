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
- Ground plane snapped on an 8-unit grid while its grass texture tiles every 10 units, so the grass pattern jumped 0.8 of a tile every 8 m of travel — a visible shimmer/pop under the car. The ground now snaps on whole 10-unit tiles, which makes each jump an exact tile and the pattern world-locked (no pop).
- Tree collision boxes sat 3 m inside the trees they belonged to: the scenery places a tree at `14 + rand*25` units from the centre line, but the collision test used `11 + rand*25`, so every tree was an invisible obstacle a few metres nearer the road and could be driven straight through at its real position. The collision query now uses the same offset as the renderer, so you hit exactly the trunk you can see.
<!-- scheduled runs append below this line -->
- Switching car models built a fresh model and simply dropped the old one, so every switch leaked that model's GPU geometry for the rest of the session (12 switches grew live geometries from 132 to 423). The outgoing model now releases the geometries and materials it owns, skipping the handful shared with the traffic cars; the same 12 switches now stay flat (132 to 135).
## 2026-11-02
- Restarting from the main menu started the race on empty grass: `newGame()` puts the car back at z=0 but only cleared the segment cursor (`curK=-1e9`), and the scenery is rebuilt inside the `play` branch of the loop, so the whole three-second countdown played over the bare ground plane and the road, rails and trees popped in at GO. `newGame()` now rebuilds the scenery for the new position immediately, so the countdown starts on a complete track.
