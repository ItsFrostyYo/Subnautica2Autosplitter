# Subnautica 2 (Log-Based)

This contains the smaller **LiveSplit Component** version of the Subnautica 2 (Early Access) autosplitter.

- `Components/LiveSplit.Subnautica2.dll`

## What this version includes

### Start / Reset

- `Survival Start` starts when you gain control in a new Survival run.
- `Creative Start` starts when you gain control in a new Creative run.
- `Reset on Main Menu` resets when you quit back to main menu.

### Others

- `Warn on Reset if Gold` shows LiveSplit's save-golds prompt on auto-reset.
- `Ordered Splits (LiveSplit)` only allows autosplits that match your current split file order. If you skip a manual split in LiveSplit, autosplitter progression follows that skip.
- `Ordered Splits (Auto-Splits)` follows the autosplitter list order only (top to bottom in the settings list), independent of split names in your LiveSplit file.

### Splits:

- `Adaptations` - Splits when you unlock Certain Adapation.
  - `Pressure Adaptation`
  - `Digestion Adaptation`
  - `Heat Resistance Adaptation`
  - `Axum Vision Adaptation`
- `Crafts` Splits when you craft a Certain Item.
  - `High capacity O2 Tank`
  - `Bioscanner`
  - `Feedback Resonator`
  - `Habitat Builder`
- `End Game Triggers` Splits on Specific End Triggers.
  - `Translate Message` Splits on Button Press for triggering the translation for the alien axum messages before `Thanks for Playing`.
  - `Thanks for Playing` Splits on the "Thanks for Playing" Popup.
- `Other Splits` Other specific Splits.
  - `Lifepod Ascend` Splits when you specifically launch the ascent of the lifepod at the start of the game.

### In-Game Time

When comparing against Game Time, lifepod ascend cutscene time is removed for exactly `85` seconds.

## Notes

- This is a **log-based** autosplitter (not memory-based).
- Logs are read from `%LOCALAPPDATA%\\Subnautica2\\Saved\\Logs`.
- `Subnautica2.asl` is kept as a legacy fallback.

## License

MIT License. See [LICENSE](./LICENSE).
