# Subnautica2.asl (Log-Based)

This contains the **Scriptable Auto Splitter** version of Subnautica 2 Autosplitter for LiveSplit:

- `Subnautica2.asl`

## What This Version Includes

## Start/Reset:
- `Survival Start` Starts when you first Gain Control in new Survival Mode saves
- `Creative Start` Starts when you first Gain Control in new Creative Mode saves
- `Reset on Main Menu` - Reset when you Quit to Main Menu

## Splits:
- `Adaptations` - Splits when you unlock specific Adapation
  - `Pressure Adaptation`
  - `Digestion Adaptation`
  - `Heat Resistance Adaptation`
  - `Axum Vision Adaptation`
- `Crafts` Splits when you craft a Certain Item
  - `High capacity O2 Tank`
  - `Bioscanner`
  - `Feedback Resonator`
  - `Habitat Builder`
- `End Game Triggers` Splits on Specific End Triggers
  - `Translate Message` Splits on Button Press for triggering the translation for the alien axum messages before `Thanks for Playing`
  - `Thanks for Playing` Splits on the "Thanks for Playing" Popup
- `Other Splits` Other specific Splits
  - `Lifepod Ascend` Splits when you specifically launch the ascent of the lifepod at the start of the game.


## Notes

- This is a **log-based** autosplitter (not memory-based).
- Logs are read from:
- `%LOCALAPPDATA%\Subnautica2\Saved\Logs`
- `Translate Message` autosplit can sometimes split incorrectly if you dont restart the game to start new logs after a completion
