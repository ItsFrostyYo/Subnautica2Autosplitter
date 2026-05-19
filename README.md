# Subnautica2.asl (Log-Based)

This folder contains the **Scriptable Auto Splitter** version for LiveSplit:

- `Subnautica2.asl`

## What This Version Includes

- Start/Reset:
- `Survival Start` (default: ON)
- `Creative Start` (default: OFF)
- `Reset on Main Menu` (default: ON)

- Split groups:
- `Adaptations`
- `Crafts`
- `End Game Triggers`
- `Other Splits`

- Current key custom splits:
- Lifepod Ascend
- Pressure / Digestion / Heat / Axum Vision adaptations
- High Capacity O2 Tank
- Feedback Resonator
- Bioscanner
- Habitat Builder
- Translate Message
- Thanks for Playing

## Translate Message Trigger Order

`Translate Message` fires only in this order:

1. `DA_Observatory2_Enter_StoryGoal`
2. `voiceover_PDA_2D/Observatory2_OxygenatedWater`
3. Next `AbilityPressed GA_Interact_C_####`

## Notes

- This is a **log-based** autosplitter (not memory-based).
- Logs are read from:
- `%LOCALAPPDATA%\Subnautica2\Saved\Logs`
