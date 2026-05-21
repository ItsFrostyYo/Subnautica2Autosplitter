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

### Splits

In the Splits Grouping you can enable any of these to trigger a split automatically,

- `Adaptations` Splits when you interact with an Adaptation/Angel Comb.
- `Lifepod Ascend` Splits when you specifically launch the ascent of the lifepod at the start of the game.
- `Craft High Capacity Tank` Splits when you Craft a High Capacity O2 Tank (Specifically when its obtained in the inventory after)
- `Craft Feedback Resonator` Splits when you Craft a Feedback Resonator (Specifically when its obtained in the inventory after)
- `Craft Bioscanner` Splits when you Craft the Bioscanner for the first time (Specifically when you trigger the state of the bioscanner for the first time, typically when its first obtained)
- `Translate Message` Splits on Button Press for triggering the translation for the alien axum messages before `Thanks for Playing`

### In-Game Time

When comparing against Game Time, the Lifepod Ascend Cutscene time is removed until you gain control again (usually exactly `85 seconds`)

The Autosplitter will ask you when its loaded if you want to compare against `Game Time`, thats for Cutscene Time Removal.

If the Autosplitter does not work, EITHER an update broke it, or you must have uhara10 installed which was not automatically installed for you, you can get it [Here](https://raw.githubusercontent.com/ru-mii/uhara/main/bin/uhara10), then you must put it inside the Livesplit Components Folder "Components/uhara10".

## License

MIT License. See [LICENSE](./LICENSE).

## Credits

[Unreal Engine Logger for finding Pointers](https://github.com/ru-mii/Unreal-Logger)
[Uhara Library for Autosplitters](https://github.com/ru-mii/uhara)
