# Subnautica 2 Autosplitter (Uhara-Memory Based)

This contains the **Uhara-memory based** `.asl` version of the Subnautica 2 autosplitter.

- `asl/Subnautica2.asl`

It currently supports these game processes:

- `Subnautica2-Win64-Shipping`
- `Subnautica2-WinGDK-Shipping`

## Settings

### Start

The script starts Survival automatically.

For Creative, the current `Creative Start` settings are:

- `Start on Load In (Priority)` Starts Creative as soon as the Creative start event is hit.
- `Start on First Interact or Movement` Arms the Creative start first, then starts on the first valid follow-up action.

If both Creative settings are enabled, `Start on Load In (Priority)` wins.

The current Creative follow-up actions are:

- `Interact with Storage`
- `First Movement`
- `Interact with Fabricator`
- `First Jump`
- `Open PDA`
- `Interact with NoA`
- `First Swim`
- `Interact with Biomod Station`

### Reset

The current `Reset Types` settings are:

- `Reset on Main Menu` Resets when the main menu construct event is hit.
- `Reset on New Game Start (Survival)` Resets when a new Survival start event is hit.
- `Reset on New Game Start (Creative)` Resets when a new Creative start event is hit.

### Splits

The current split groups are:

- `Any% Splits (Survival & Creative) + (Glitched & Glitchless)`
- `Miscellaneous Splits`

#### Any% Splits

- `Split on Any Adaptations (Pressure, Digestion, Heat, Axum)` Splits when any adaptation event is hit.
- `Split on Lifepod Ascend` Splits when the intro lifepod ascend event is hit.
- `Split on Unlocking Door (Intro)` Splits when you close the NoA Menu after unlocking the door in the starting room.
- `Split on Analyze Button Press` Splits on the intro analyze/scanning button press.
- `Split on Lifepod Left Lever Pressed` Splits when the left lifepod lever is pressed.
- `Split on Lifepod Right Lever Pressed` Splits when the right lifepod right lever event is hit.
- `Split on Crafting High Capacity O2 Tank` Splits when the High Capacity O2 Tank equip/craft event is hit.
- `Split on Crafting Feedback Resonator` Splits when the Feedback Resonator craft/pickup event is hit.
- `Split on Craftng Bioscanner` Splits when the Bioscanner craft/equip event is hit.
- `Split on Crafting Scanner` Splits when the Scanner equip event is hit.
- `Split on Crafting Airbladder` Splits when the Airbladder event is hit.
- `Split on Observatory Button (End)` Splits on the end Observatory button press.

#### Miscellaneous Splits

Inside `Crafting Splits`, the current settings are:

- `Split on First Craft` Splits on the first craft event of the attempt.
- `Split on First Scan` Splits on the first scan event of the attempt.

The crafting-related split settings are one-time per attempt.

### In-Game Time

When comparing against Game Time, only the `Lifepod Ascend` intro cutscene is removed until control is returned.

The autosplitter will ask whether you want to compare against `Game Time`, which is what enables the cutscene time removal behavior.

## Uhara

If the autosplitter does not work, either a game update broke it or `uhara10` is missing.

Download `uhara10` here:

- `https://github.com/ru-mii/uhara/raw/refs/heads/main/bin/uhara10`

Then place it in your LiveSplit `Components` folder as:

- `Components/uhara10`

## License

MIT License. See [LICENSE](./LICENSE).

## Credits

[Unreal Engine Logger for finding pointers](https://github.com/ru-mii/Unreal-Logger)
[Uhara Library for autosplitters](https://github.com/ru-mii/uhara)
