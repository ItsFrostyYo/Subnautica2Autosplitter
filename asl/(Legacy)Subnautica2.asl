state("Subnautica2-Win64-Shipping")
{
}

startup
{
    vars.logsDir = System.IO.Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "Subnautica2",
        "Saved",
        "Logs"
    );
    vars.defaultLogPath = System.IO.Path.Combine(vars.logsDir, "Subnautica2.log");
    vars.rxValidRuntimeLogName = new System.Text.RegularExpressions.Regex(
        @"^Subnautica2(?:_\d+)?\.log$",
        System.Text.RegularExpressions.RegexOptions.Compiled | System.Text.RegularExpressions.RegexOptions.IgnoreCase
    );

    vars.rxCraftSucceed = new System.Text.RegularExpressions.Regex(
        @"LogCrafting: Crafting recipe .*?/([^/\.]+)\.[^\s]+ succeeded",
        System.Text.RegularExpressions.RegexOptions.Compiled
    );

    vars.Normalize = (Func<string, string>)(value =>
    {
        if (string.IsNullOrWhiteSpace(value))
            return string.Empty;
        string x = value.Trim();
        x = x.Replace(" ", "");
        x = x.Replace("_", "");
        x = x.Replace("-", "");
        x = x.Replace("/", "");
        x = x.Replace(".", "");
        x = x.Replace(":", "");
        return x.ToLowerInvariant();
    });

    vars.IsInteractPress = (Func<string, bool>)(line =>
    {
        return line.IndexOf("AbilityInput: InputPressed IA_Interact", StringComparison.OrdinalIgnoreCase) >= 0
            || line.IndexOf("AbilityInput: AbilityPressed GA_Interact", StringComparison.OrdinalIgnoreCase) >= 0;
    });

    vars.ResolveActiveLog = (Func<string>)(() =>
    {
        string fallback = vars.defaultLogPath;
        try
        {
            if (!System.IO.Directory.Exists(vars.logsDir))
                return fallback;

            var files = new System.IO.DirectoryInfo(vars.logsDir).GetFiles("Subnautica2*.log");
            System.IO.FileInfo best = null;
            for (int i = 0; i < files.Length; i++)
            {
                var f = files[i];
                if (!vars.rxValidRuntimeLogName.IsMatch(f.Name))
                    continue;

                if (best == null
                    || f.LastWriteTimeUtc > best.LastWriteTimeUtc
                    || (f.LastWriteTimeUtc == best.LastWriteTimeUtc && f.Length > best.Length))
                {
                    best = f;
                }
            }

            if (best != null)
                return best.FullName;
        }
        catch
        {
        }
        return fallback;
    });

    settings.Add("group_start_reset", true, "Start/Reset");
    settings.Add("survival_start", true, "Survival Start", "group_start_reset");
    settings.Add("creative_start", false, "Creative Start", "group_start_reset");
    settings.Add("reset_on_main_menu", true, "Reset on Main Menu", "group_start_reset");

    settings.Add("group_splits", true, "Splits");
    settings.Add("group_splits_adaptations", true, "Adaptations", "group_splits");
    settings.Add("split_pressure_adaptation", false, "Pressure Adaptation", "group_splits_adaptations");
    settings.Add("split_digestions_adaptation", false, "Digestion Adaptation", "group_splits_adaptations");
    settings.Add("split_heat_adaptation", false, "Heat Adaptation", "group_splits_adaptations");
    settings.Add("split_axum_vision_adaptation", false, "Axum Vision Adaptation", "group_splits_adaptations");

    settings.Add("group_splits_crafts", true, "Crafts", "group_splits");
    settings.Add("split_high_capacity_o2_tank", false, "High Capacity O2 Tank", "group_splits_crafts");
    settings.Add("split_feedback_resonator", false, "Feedback Resonator", "group_splits_crafts");
    settings.Add("split_bioscanner", false, "Bioscanner", "group_splits_crafts");
    settings.Add("split_habitat_builder", false, "Habitat Builder", "group_splits_crafts");

    settings.Add("group_splits_end_game_triggers", true, "End Game Triggers", "group_splits");
    settings.Add("split_translate_message", false, "Translate Message", "group_splits_end_game_triggers");
    settings.Add("split_thanks_for_playing", false, "Thanks for Playing", "group_splits_end_game_triggers");

    settings.Add("group_splits_other", true, "Other Splits", "group_splits");
    settings.Add("split_lifepod_ascend", false, "Lifepod Ascend", "group_splits_other");

    vars.ascendPauseDuration = System.TimeSpan.FromSeconds(85);
    vars.ClearAscendPause = (Action)(() =>
    {
        vars.igtPauseForAscend = false;
        vars.lifepodAscendPauseStartUtc = System.DateTime.MinValue;
        vars.ascendPauseConsumed = false;
    });
    vars.TryEndAscendPause = (Action)(() =>
    {
        if (!vars.igtPauseForAscend)
            return;
        if (vars.lifepodAscendPauseStartUtc == System.DateTime.MinValue)
            return;
        if ((System.DateTime.UtcNow - vars.lifepodAscendPauseStartUtc) >= vars.ascendPauseDuration)
        {
            vars.igtPauseForAscend = false;
            vars.lifepodAscendPauseStartUtc = System.DateTime.MinValue;
        }
    });
}

init
{
    vars.logPath = vars.ResolveActiveLog();
    vars.logPos = 0L;
    vars.staleFrames = 0;
    vars.lineCounter = 0L;

    vars.startedThisAttempt = false;
    vars.isInMainMenu = true;
    vars.mode = "Survival";
    vars.characterSelectOpen = false;

    vars.survivalStartPulse = false;
    vars.creativeStartPulse = false;
    vars.mainMenuQuitPulse = false;

    vars.lifepodAscendPulse = false;
    vars.pressureAdaptationPulse = false;
    vars.digestionAdaptationPulse = false;
    vars.heatAdaptationPulse = false;
    vars.axumVisionAdaptationPulse = false;
    vars.highCapacityO2TankPulse = false;
    vars.feedbackResonatorPulse = false;
    vars.bioscannerPulse = false;
    vars.habitatBuilderPulse = false;
    vars.translateMessagePulse = false;
    vars.thanksForPlayingPulse = false;

    vars.firedLifepodAscend = false;
    vars.firedPressureAdaptation = false;
    vars.firedDigestionAdaptation = false;
    vars.firedHeatAdaptation = false;
    vars.firedAxumVisionAdaptation = false;
    vars.firedHighCapacityO2Tank = false;
    vars.firedFeedbackResonator = false;
    vars.firedBioscanner = false;
    vars.firedHabitatBuilder = false;
    vars.firedTranslateMessage = false;
    vars.firedThanksForPlaying = false;

    vars.armPressureLines = 0;
    vars.armThanksLines = 0;
    vars.translateStage = 0; // 0=idle, 1=seen Enter, 2=seen OxygenatedWater after Enter
    vars.translateEnterLine = 0L;
    vars.translateOxygenLine = 0L;
    vars.pendingStrongInteract = false;
    vars.lastInteractLineCounter = 0L;

    vars.igtPauseForAscend = false;
    vars.lifepodAscendPauseStartUtc = System.DateTime.MinValue;
    vars.ascendPauseConsumed = false;

    vars.splitNow = false;
    vars.resetNow = false;

    try
    {
        if (System.IO.File.Exists(vars.logPath))
            vars.logPos = new System.IO.FileInfo(vars.logPath).Length;

        // If script attaches while game is already open, infer current menu/in-game state
        // from recent log lines so autostart logic doesn't get stuck in default menu=true.
        if (System.IO.File.Exists(vars.logPath))
        {
            using (var fs = new System.IO.FileStream(vars.logPath, System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.ReadWrite))
            {
                long start = fs.Length > 131072 ? fs.Length - 131072 : 0L;
                fs.Seek(start, System.IO.SeekOrigin.Begin);
                using (var sr = new System.IO.StreamReader(fs))
                {
                    string line;
                    while ((line = sr.ReadLine()) != null)
                    {
                        if (line.IndexOf("Browse Started Browse:", StringComparison.OrdinalIgnoreCase) >= 0 &&
                            line.IndexOf("/Game/Maps/L_ClientLobby", StringComparison.OrdinalIgnoreCase) >= 0)
                        {
                            vars.isInMainMenu = true;
                            vars.mode = "Survival";
                        }
                        else if (line.IndexOf("Browse Started Browse:", StringComparison.OrdinalIgnoreCase) >= 0 &&
                                 line.IndexOf("/Game/Maps/Main/L_Main", StringComparison.OrdinalIgnoreCase) >= 0)
                        {
                            vars.isInMainMenu = false;
                            vars.mode = line.IndexOf("game=Creative", StringComparison.OrdinalIgnoreCase) >= 0 ? "Creative" : "Survival";
                        }
                    }
                }
            }
        }
    }
    catch
    {
        vars.logPos = 0L;
    }
}

update
{
    vars.splitNow = false;
    vars.resetNow = false;

    vars.survivalStartPulse = false;
    vars.creativeStartPulse = false;
    vars.mainMenuQuitPulse = false;

    vars.lifepodAscendPulse = false;
    vars.pressureAdaptationPulse = false;
    vars.digestionAdaptationPulse = false;
    vars.heatAdaptationPulse = false;
    vars.axumVisionAdaptationPulse = false;
    vars.highCapacityO2TankPulse = false;
    vars.feedbackResonatorPulse = false;
    vars.bioscannerPulse = false;
    vars.habitatBuilderPulse = false;
    vars.translateMessagePulse = false;
    vars.thanksForPlayingPulse = false;

    vars.TryEndAscendPause();

    bool runActiveNow = false;
    try
    {
        runActiveNow = (int)timer.CurrentPhase == 1;
    }
    catch
    {
        runActiveNow = false;
    }

    if (!System.IO.File.Exists(vars.logPath))
    {
        vars.logPath = vars.ResolveActiveLog();
        if (!System.IO.File.Exists(vars.logPath))
            return;

        try
        {
            vars.logPos = new System.IO.FileInfo(vars.logPath).Length;
        }
        catch
        {
            vars.logPos = 0L;
        }
        return;
    }

    long len = 0L;
    try
    {
        len = new System.IO.FileInfo(vars.logPath).Length;
    }
    catch
    {
        return;
    }

    if (len < vars.logPos)
        vars.logPos = len;

    int linesRead = 0;
    try
    {
        using (var fs = new System.IO.FileStream(vars.logPath, System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.ReadWrite))
        {
            fs.Seek(vars.logPos, System.IO.SeekOrigin.Begin);
            using (var sr = new System.IO.StreamReader(fs))
            {
                string line;
                while ((line = sr.ReadLine()) != null)
                {
                    linesRead++;
                    vars.lineCounter++;

                    if (vars.armPressureLines > 0) vars.armPressureLines--;
                    if (vars.armThanksLines > 0) vars.armThanksLines--;
                    
                    if (vars.pendingStrongInteract && (vars.lineCounter - vars.lastInteractLineCounter > 8))
                        vars.pendingStrongInteract = false;

                    if (line.IndexOf("Browse Started Browse:", StringComparison.OrdinalIgnoreCase) >= 0 &&
                        line.IndexOf("/Game/Maps/L_ClientLobby", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        vars.isInMainMenu = true;
                        vars.characterSelectOpen = false;
                        vars.mode = "Survival";
                        vars.pendingStrongInteract = false;
                        vars.armPressureLines = 0;
                        vars.armThanksLines = 0;
                        vars.translateStage = 0;
                        vars.translateEnterLine = 0L;
                        vars.translateOxygenLine = 0L;
                        vars.ClearAscendPause();
                        if (line.IndexOf("MenuReturnReason=Quit", StringComparison.OrdinalIgnoreCase) >= 0)
                            vars.mainMenuQuitPulse = true;
                    }

                    if (line.IndexOf("Browse Started Browse:", StringComparison.OrdinalIgnoreCase) >= 0 &&
                        line.IndexOf("/Game/Maps/Main/L_Main", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        vars.isInMainMenu = false;
                        vars.mode = "Survival";
                        vars.translateStage = 0;
                        vars.translateEnterLine = 0L;
                        vars.translateOxygenLine = 0L;
                        if (line.IndexOf("game=Creative", StringComparison.OrdinalIgnoreCase) >= 0)
                            vars.mode = "Creative";
                    }

                    if (line.IndexOf("PushToLayer: Layer 5 Widget WBP_CharacterSelectScreen", StringComparison.OrdinalIgnoreCase) >= 0)
                        vars.characterSelectOpen = true;

                    if (line.IndexOf("Pop: Layer 5 Widget WBP_CharacterSelectScreen", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        if (vars.characterSelectOpen)
                            vars.creativeStartPulse = true;
                        vars.characterSelectOpen = false;
                    }

                    if (line.IndexOf("UUWEFirstPersonCamera::EndCinematicLocation", StringComparison.OrdinalIgnoreCase) >= 0)
                        vars.survivalStartPulse = true;

                    if ((line.IndexOf("LogUWEGameplay: Adding global tag Gamestate.LifepodAscending", StringComparison.OrdinalIgnoreCase) >= 0
                        || line.IndexOf("DA_Player_Ch1_LifepodRide1_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0))
                    {
                        vars.lifepodAscendPulse = true;
                    }

                    if (line.IndexOf("LogUWEGameplay: Adding global tag Gamestate.LifepodAscending", StringComparison.OrdinalIgnoreCase) >= 0
                        && !vars.igtPauseForAscend
                        && !vars.ascendPauseConsumed
                        && !vars.isInMainMenu)
                    {
                        vars.igtPauseForAscend = true;
                        vars.lifepodAscendPauseStartUtc = System.DateTime.UtcNow;
                        vars.ascendPauseConsumed = true;
                    }

                    if (line.IndexOf("DA_Storygoal_Player_Ch1_AdaptationTutorial2", StringComparison.OrdinalIgnoreCase) >= 0)
                        vars.armPressureLines = 220;

                    if (vars.IsInteractPress(line))
                    {
                        vars.lastInteractLineCounter = vars.lineCounter;
                        vars.pendingStrongInteract = true;
                    }

                    if (line.IndexOf("RemoveCurrentMappingContext: IMC_PlayerCharacter", StringComparison.OrdinalIgnoreCase) >= 0
                        && vars.pendingStrongInteract
                        && (vars.lineCounter - vars.lastInteractLineCounter <= 8))
                    {
                        vars.pendingStrongInteract = false;
                        if (vars.armPressureLines > 0)
                        {
                            vars.pressureAdaptationPulse = true;
                            vars.armPressureLines = 0;
                        }
                    }

                    if (line.IndexOf("DA_Storygoal_Player_Ch1_AdaptationTutorial_Interact", StringComparison.OrdinalIgnoreCase) >= 0
                        && !vars.firedPressureAdaptation)
                    {
                        vars.pressureAdaptationPulse = true;
                    }

                    if ((line.IndexOf("DA_Adaptation_Digestion_Acquired_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0
                        || line.IndexOf("DA_Adaptation_Digestive_Acquired_1_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0))
                    {
                        vars.digestionAdaptationPulse = true;
                    }

                    if (line.IndexOf("DA_Adaptation_HeatResistance_Acquired_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0)
                        vars.heatAdaptationPulse = true;

                    if ((line.IndexOf("DA_Adaptation_AxumGlyphs_Acquired_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0
                        || line.IndexOf("DA_Ruins_AxumGlyph_DB_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0))
                    {
                        vars.axumVisionAdaptationPulse = true;
                    }

                    if (line.IndexOf("DA_Observatory2_Enter_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        vars.translateStage = 1;
                        vars.translateEnterLine = vars.lineCounter;
                        vars.translateOxygenLine = 0L;
                    }

                    if (vars.translateStage == 1
                        && line.IndexOf("voiceover_PDA_2D/Observatory2_OxygenatedWater", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        vars.translateStage = 2;
                        vars.translateOxygenLine = vars.lineCounter;
                    }

                    if (vars.translateStage == 2
                        && vars.translateEnterLine > 0
                        && vars.translateOxygenLine > 0
                        && vars.translateOxygenLine > vars.translateEnterLine
                        && vars.lineCounter > vars.translateOxygenLine
                        && line.IndexOf("AbilityInput: AbilityPressed GA_Interact_C_", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        vars.translateMessagePulse = true;
                        vars.translateStage = 0;
                        vars.translateEnterLine = 0L;
                        vars.translateOxygenLine = 0L;
                    }

                    if (vars.translateStage == 2
                        && line.IndexOf("voiceover_PDA_2D/ClimateLab_AnalyzingMessage_Line3", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        vars.armThanksLines = 5000;
                    }

                    if (vars.translateStage == 2
                        && vars.armThanksLines > 0
                        && line.IndexOf("LogUIActionRouter: Display: Applying input config for leaf-most node [WBP_PlayerModalMessage_C_", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        vars.thanksForPlayingPulse = true;
                        vars.armThanksLines = 0;
                    }

                    var mc = vars.rxCraftSucceed.Match(line);
                    if (mc.Success)
                    {
                        string recipe = vars.Normalize(mc.Groups[1].Value);
                        if (recipe == vars.Normalize("DA_MediumAirTankRecipe"))
                            vars.highCapacityO2TankPulse = true;
                        else if (recipe == vars.Normalize("DA_SonicResonatorV2Recipe"))
                            vars.feedbackResonatorPulse = true;
                        else if (recipe == vars.Normalize("DA_ScannerV2Recipe"))
                            vars.bioscannerPulse = true;
                        else if (recipe == vars.Normalize("DA_BuilderToolRecipe"))
                            vars.habitatBuilderPulse = true;
                    }
                }
            }

            vars.logPos = fs.Position;
        }
    }
    catch
    {
    }

    if (linesRead > 0)
    {
        vars.staleFrames = 0;
    }
    else
    {
        vars.staleFrames++;
        if (vars.staleFrames > 15)
        {
            vars.staleFrames = 0;
            string candidate = vars.ResolveActiveLog();
            if (!string.Equals(candidate, vars.logPath, StringComparison.OrdinalIgnoreCase))
            {
                vars.logPath = candidate;
                try
                {
                    vars.logPos = System.IO.File.Exists(vars.logPath) ? new System.IO.FileInfo(vars.logPath).Length : 0L;
                }
                catch
                {
                    vars.logPos = 0L;
                }
            }
        }
    }

    if (settings["reset_on_main_menu"] && vars.mainMenuQuitPulse)
    {
        try
        {
            if ((int)timer.CurrentPhase != 0)
                vars.resetNow = true;
        }
        catch
        {
        }
    }

    if (!runActiveNow)
        return;

    if (settings["split_lifepod_ascend"] && vars.lifepodAscendPulse && !vars.firedLifepodAscend)
    {
        vars.firedLifepodAscend = true;
        vars.splitNow = true;
        return;
    }
    if (settings["split_pressure_adaptation"] && vars.pressureAdaptationPulse && !vars.firedPressureAdaptation)
    {
        vars.firedPressureAdaptation = true;
        vars.splitNow = true;
        return;
    }
    if (settings["split_digestions_adaptation"] && vars.digestionAdaptationPulse && !vars.firedDigestionAdaptation)
    {
        vars.firedDigestionAdaptation = true;
        vars.splitNow = true;
        return;
    }
    if (settings["split_heat_adaptation"] && vars.heatAdaptationPulse && !vars.firedHeatAdaptation)
    {
        vars.firedHeatAdaptation = true;
        vars.splitNow = true;
        return;
    }
    if (settings["split_axum_vision_adaptation"] && vars.axumVisionAdaptationPulse && !vars.firedAxumVisionAdaptation)
    {
        vars.firedAxumVisionAdaptation = true;
        vars.splitNow = true;
        return;
    }
    if (settings["split_high_capacity_o2_tank"] && vars.highCapacityO2TankPulse && !vars.firedHighCapacityO2Tank)
    {
        vars.firedHighCapacityO2Tank = true;
        vars.splitNow = true;
        return;
    }
    if (settings["split_feedback_resonator"] && vars.feedbackResonatorPulse && !vars.firedFeedbackResonator)
    {
        vars.firedFeedbackResonator = true;
        vars.splitNow = true;
        return;
    }
    if (settings["split_bioscanner"] && vars.bioscannerPulse && !vars.firedBioscanner)
    {
        vars.firedBioscanner = true;
        vars.splitNow = true;
        return;
    }
    if (settings["split_habitat_builder"] && vars.habitatBuilderPulse && !vars.firedHabitatBuilder)
    {
        vars.firedHabitatBuilder = true;
        vars.splitNow = true;
        return;
    }
    if (settings["split_translate_message"] && vars.translateMessagePulse && !vars.firedTranslateMessage)
    {
        vars.firedTranslateMessage = true;
        vars.splitNow = true;
        return;
    }
    if (settings["split_thanks_for_playing"] && vars.thanksForPlayingPulse && !vars.firedThanksForPlaying)
    {
        vars.firedThanksForPlaying = true;
        vars.splitNow = true;
        return;
    }
}

start
{
    try
    {
        if ((int)timer.CurrentPhase != 0)
            return false;
    }
    catch
    {
    }

    if (vars.startedThisAttempt)
        return false;
    if (vars.isInMainMenu)
        return false;

    if (settings["survival_start"] && vars.mode != "Creative" && vars.survivalStartPulse)
    {
        vars.startedThisAttempt = true;
        return true;
    }

    if (settings["creative_start"] && vars.mode == "Creative" && vars.creativeStartPulse)
    {
        vars.startedThisAttempt = true;
        return true;
    }

    return false;
}

split
{
    try
    {
        if ((int)timer.CurrentPhase != 1)
        {
            vars.splitNow = false;
            return false;
        }
    }
    catch
    {
    }

    bool fire = vars.splitNow;
    vars.splitNow = false;
    return fire;
}

reset
{
    if (!vars.resetNow)
        return false;
    vars.resetNow = false;
    return true;
}

isLoading
{
    vars.TryEndAscendPause();
    return vars.igtPauseForAscend;
}

onStart
{
    vars.startedThisAttempt = true;
    vars.firedLifepodAscend = false;
    vars.firedPressureAdaptation = false;
    vars.firedDigestionAdaptation = false;
    vars.firedHeatAdaptation = false;
    vars.firedAxumVisionAdaptation = false;
    vars.firedHighCapacityO2Tank = false;
    vars.firedFeedbackResonator = false;
    vars.firedBioscanner = false;
    vars.firedHabitatBuilder = false;
    vars.firedTranslateMessage = false;
    vars.firedThanksForPlaying = false;
    vars.translateStage = 0;
    vars.armThanksLines = 0;
    vars.translateEnterLine = 0L;
    vars.translateOxygenLine = 0L;
    vars.ClearAscendPause();
}

onReset
{
    vars.startedThisAttempt = false;

    vars.firedLifepodAscend = false;
    vars.firedPressureAdaptation = false;
    vars.firedDigestionAdaptation = false;
    vars.firedHeatAdaptation = false;
    vars.firedAxumVisionAdaptation = false;
    vars.firedHighCapacityO2Tank = false;
    vars.firedFeedbackResonator = false;
    vars.firedBioscanner = false;
    vars.firedHabitatBuilder = false;
    vars.firedTranslateMessage = false;
    vars.firedThanksForPlaying = false;

    vars.splitNow = false;
    vars.resetNow = false;
    vars.pendingStrongInteract = false;
    vars.armPressureLines = 0;
    vars.armThanksLines = 0;
    vars.translateStage = 0;
    vars.translateEnterLine = 0L;
    vars.translateOxygenLine = 0L;
    vars.ClearAscendPause();

    try
    {
        vars.logPath = vars.ResolveActiveLog();
        vars.logPos = System.IO.File.Exists(vars.logPath) ? new System.IO.FileInfo(vars.logPath).Length : 0L;
    }
    catch
    {
        vars.logPos = 0L;
    }
}
