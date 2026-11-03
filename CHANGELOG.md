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
- Restarting a race rewound the skid-mark ring buffer (`skidI=0`) but never cleared the instance matrices, so every tyre mark laid in the previous race stayed on the road for the rest of the session — black streaks where you had not driven this time, and only the first few of them ever got overwritten. `newGame()` now resets all 260 skid instances to the zero matrix, so a restart starts on a clean road.
- Every wheel was built from five separate spoke meshes, so each car spent 20 draw calls on spokes alone and the eight cars on screen at High pushed 562 draw calls a frame. The five spokes are now merged into one geometry per wheel (same boxes, same angles, same triangle count), taking each car from 66 to 50 meshes and the High preset from 562 to 434 draw calls a frame - 128 fewer draw submissions every frame, with the geometry count and the image unchanged.
- Restarting a race left the car and the dash carrying over the previous race: the countdown never calls `step()`, so the speedometer and gear readout still showed the speed you crashed at, and the body-roll/pitch springs plus the steering angle still had the car sitting tilted on the line with its front wheels turned until GO. `newGame()` now zeroes that derived state (forward speed, slip, throttle, brake, steer angle, body sway and load transfer), so a restart begins from a settled car.
- The particle system walked all 600 slots, re-uploaded four attribute buffers (~19 KB) and drew the mesh every single frame, even when no particle was alive - and spray only exists in the wet, dust only off-road and sparks only on a hit, so most frames have none at all. It now tracks how many particles are live and, with none, skips the loop, the uploads and the draw call; on the frame the last one dies it still uploads the zeros and hides the mesh, so the picture is unchanged.
- Leaving the game in a background tab left the engine droning: a hidden tab stops the render loop, so `audio()` never ran again and the engine, tyre and rain gains stayed frozen at whatever they held when you switched away, even though the race had already been paused. The visibility handler now mutes those three gains as well, and the first visible frame restores them from the physics state - same engine sound while you drive, no noise from a tab you are not looking at.

## 2026-11-03
- The race clock was running during the standing start: `tt` accumulated on `state==='play'||state==='count'`, so the HUD read 0:03.0 the instant the lights went out and every checkpoint message was inflated by the three-second wait, even though `step()` never runs and the car cannot move before GO. The clock now only accumulates in `play`, so the first frame of a race reads 0:00.0 and checkpoint splits are real race time.
