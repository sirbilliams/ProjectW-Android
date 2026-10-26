# Project Wasteland — Android

A Fallout-inspired (original IP) first-person wasteland RPG prototype for the **AYN Thor MAX**, built in **Godot 4** with GDScript.

## Milestone 1
- First-person movement with keyboard/mouse and gamepad
- Small procedural roadside level
- Collectible scrap and a hostile scavenger
- Hitscan combat and a basic HUD

**Status:** early prototype, not yet tested on hardware or exported to APK.

## Run
1. Open `project.godot` using Godot 4.x (standard/GDScript edition).
2. Press F5 to run the project.
3. WASD / left stick: move; mouse / right stick: look; Space / A: jump; E / X: interact; F / right shoulder: shoot; Escape: release mouse.

## Android
Install Android export templates matching your Godot version and configure JDK 17 + Android SDK under Editor Settings → Export → Android. Then add an Android export preset in Project → Export and export a debug APK. Test it on the Thor MAX before setting a performance target.

## Dual-screen note
The **bottom-screen Pip-Boy is a planned feature, not implemented yet**. Rendering into two independent Android displays requires device/firmware validation and likely native Android integration, beyond the initial Godot prototype.

This project is an original wasteland setting, not affiliated with Bethesda or Fallout.