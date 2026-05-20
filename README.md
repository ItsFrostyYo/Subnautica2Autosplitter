# Subnautica 2 Autosplitter (Uhara-Memory Based)

This contains the **Uhara-Memory Based** **.asl** version of the Subnautica 2 (Early Access) autosplitter.

- `asl/Subnautica2.asl`

## What this version includes

### Start / Reset

- `Survival Start` Starts when you Gain Control in a new Survival run.
- `Creative Start` Starts when you Gain Control in a new Creative run.
- `Reset on Main Menu` Reset's when you load the main menu (specifically when the game starts contruct of the main menu)

### Splits

- `Adaptations` - Splits when you interact with an Adaptation.
- `Translate Message` Splits on Button Press for triggering the translation for the alien axum messages before `Thanks for Playing`
- `Lifepod Ascend` Splits when you specifically launch the ascent of the lifepod at the start of the game.

### In-Game Time

When comparing against Game Time, lifepod ascend cutscene time is removed until you gain control again (usually exactly `85 seconds`)

## License

MIT License. See [LICENSE](./LICENSE).

## Credits

[Unreal Engine Logger for finding Pointers](https://github.com/ru-mii/Unreal-Logger)
[Uhara Library for Autosplitters](https://github.com/ru-mii/uhara)
