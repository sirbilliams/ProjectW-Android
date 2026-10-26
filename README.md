# Project Wasteland — Android

An original, first-person post-apocalyptic open-world RPG prototype for the **AYN Thor MAX**, built with **Godot 4 and GDScript**.

## Prototype: Worldspace 001 — Dustfall

You wake up in a small boarding house in **Dustfall**, a quiet settlement assembled from salvage after the collapse of modern civilization. The town has a trading post, saloon, workshop, clinic and water purification station. Rusting wrecks, dead utility poles, barricades and fragments of a fallen highway establish the post-apocalyptic setting. The north and south roads are reserved for future neighboring chunks.

**Current prototype:** primitive 3D meshes, flat-color materials, no imported art assets, two scrap pickups, a first-person player, a brief wake-up title card, and a basic HUD. The intro is a fade-in with text, not a fully animated wake-up. This is a **blockout**, not a finished level.

**Not implemented:** branching conversations, missions, crowds, detailed textures, soundscape, actual worldspace streaming, separate-display Pip-Boy and persistence/save files. Android alpha debug APK releases are now automated.

## Alpha 2 — The Pit and the first morning

You wake on an old mattress in Dustfall. Calder, an aging scavenger beside your bed in a rocking chair, tells you he dragged you out of **the Pit** while looking for spare parts. Advance his dialogue with E / X. Once you stand, visit **Mara** at the saloon/canteen in the northern part of town.

The world starts at 08:00 on Day 1. A full in-game day takes approximately **24 real minutes** while exploring. The procedural sky shifts from daytime dusty blue to dusk and dark night; lighting changes with the clock. The simple color-gradient sky is a placeholder, not a full textured skybox.

- **Wait:** T on keyboard / Y on the controller advances one hour.
- **Sleep:** look toward and interact with the mattress in the boarding-house room (E / X) to sleep until 07:00.
- Time pauses during conversations, wake-up narration and wait/sleep fades.
- Neither sleeping nor waiting saves the game yet.

## Run on a PC

1. Clone or download this repository.
2. Open `project.godot` in a recent **Godot 4.x standard (GDScript)** editor.
3. Press **F5** to run the main scene. You begin in the boarding house.
4. Face the door toward the main street (+X/east) to explore Dustfall.

## Controls

| Action | Keyboard / mouse | Controller |
| --- | --- | --- |
| Move | W/A/S/D | Left stick |
| Look | Mouse | Right stick |
| Jump | Space | A / Cross |
| Interact / loot | E | X / Square |
| Shoot (prototype) | F | Right shoulder |
| Wait one hour | T | Y / Triangle |
| Sleep until morning | E near bed | X / Square near bed |
| Release mouse | Escape | — |

Controller mappings depend on Android's and Godot's button numbering. Test on the Thor MAX.

## Android test APK

Godot's Android export requires the export templates matching your editor version, a compatible JDK and Android SDK configured in the editor. Set up **Project → Export → Android**, then produce a **debug APK** and sideload it to the AYN Thor MAX. Nothing in this repository should be represented as an already-tested Android build.

## Chunk layout

`scripts/world/chunks/dustfall_001.gd` owns the first self-contained, approximately 96 × 96 meter worldspace. Later neighboring worldspaces can be designed as separate chunk scenes with a manager that loads them as the player travels. **Chunk streaming is not implemented yet**.

`scripts/main.gd` handles bootstrap/environment/HUD and starting worldspace. `scripts/player.gd` handles first-person interaction and controls.

## Current limitations

This branch has been committed through GitHub but **has not been verified in a running Godot editor or on hardware**. Expect to iterate on geometry, physics, gamepad mapping and performance after the first local run.

The bottom-screen Pip-Boy is planned; independent rendering on the Thor's second Android display needs separate device/firmware/native-integration research and testing.

This is an original project unaffiliated with Bethesda or Fallout.
