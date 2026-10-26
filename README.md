# Project Wasteland — Android

An original, first-person post-apocalyptic open-world RPG prototype for the **AYN Thor MAX**, built with **Godot 4 and GDScript**.

## Prototype: Worldspace 001 — Dustfall

You wake up in a small boarding house in **Dustfall**, a quiet settlement assembled from salvage after the collapse of modern civilization. The town has a trading post, saloon, workshop, clinic and water purification station. Rusting wrecks, dead utility poles, barricades and fragments of a fallen highway establish the post-apocalyptic setting. The north and south roads are reserved for future neighboring chunks.

**Current prototype:** primitive 3D meshes, flat-color materials, no imported art assets, two scrap pickups, a first-person player, a brief wake-up title card, and a basic HUD. The intro is a fade-in with text, not a fully animated wake-up. This is a **blockout**, not a finished level.

**Not implemented:** NPC conversations, missions, crowds, detailed textures, soundscape, actual worldspace streaming, separate-display Pip-Boy, persistence/save files and Android APK release.

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
