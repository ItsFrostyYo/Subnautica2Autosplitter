# Subnautica 2 Autosplitter (Uhara-Memory Based)

This contains the **Uhara-Memory Based** **.asl** version of the Subnautica 2 (Early Access) autosplitter.

- `asl/Subnautica2.asl`

## What this version includes

### Start

Enabling `Start` at the top allows you to have these 2 starts enabled

- `Survival Start` Starts when you Gain Control in a new Survival run.
- `Creative Start` Starts when you Gain Control in a new Creative run.

### Reset

Having `Reset` Enabled allows the timer to reset, and allows this setting below to work,

- `Reset on Main Menu` Reset's when you load the main menu (specifically when the game starts construct of the main menu)
- `Reset on New Game Start (Survival)` Reset's when you start a new Survival game.
- `Reset on New Game Start (Creative)` Reset's when you start a new Creative game.

### Splits

In the `Any%` grouping you can enable any of these to trigger a split automatically,

- `Any Adaptations` Splits when you interact with an Adaptation/Angel Comb.
- `Lifepod Ascend` Splits when you specifically launch the ascent of the lifepod at the start of the game.
- `Button Press` Splits on the intro scanning button press.
- `Lifepod Left Lever Pressed` Splits when the left lifepod lever is pressed.
- `Lifepod Right Lever Pressed` Splits when the right lifepod lever is pressed.
- `Craft High Capacity O2 Tank` Splits when you craft and obtain the High Capacity O2 Tank.
- `Craft Feedback Resonator` Splits when you craft and obtain the Feedback Resonator.
- `Craft Bioscanner` Splits when you craft and obtain the Bioscanner.
- `Craft Scanner` Splits when the Scanner equip event is triggered.
- `Biomod Station Close` Splits when the Biomod Station UI closes.
- `Observatory Button` Splits on the end Observatory button press.

In the `Other Splits (Miscellaneous)` grouping you can also enable,

- `Biomod Equip` Splits when a passive biomod is selected.
- `Biomod Unequip` Splits when a passive biomod is deselected.

### In-Game Time

When comparing against Game Time, the Lifepod Ascend Cutscene time is removed until you gain control again (usually exactly `85 seconds`)

The Autosplitter will ask you when its loaded if you want to compare against `Game Time`, thats for Cutscene Time Removal.

If the Autosplitter does not work, EITHER an update broke it, or you must have uhara10 installed which was not automatically installed for you, you can get it [Here](https://raw.githubusercontent.com/ru-mii/uhara/main/bin/uhara10), then you must put it inside the Livesplit Components Folder "Components/uhara10".

## License

MIT License. See [LICENSE](./LICENSE).

## Credits

[Unreal Engine Logger for finding Pointers](https://github.com/ru-mii/Unreal-Logger)
[Uhara Library for Autosplitters](https://github.com/ru-mii/uhara)
