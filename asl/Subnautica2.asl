state("Subnautica2-Win64-Shipping"){}
state("Subnautica2-WinGDK-Shipping"){}

startup
{
    vars.ScriptVersion = "v1.0.8";
    vars.MissingUhara = !File.Exists("Components/uharaSN2");
    if (vars.MissingUhara)
    {
        System.Windows.Forms.MessageBox.Show(
            "Missing required file: Components/uharaSN2,\n" +
            "Please Place uharaSN2 in your LiveSplit Components folder.\n" +
            "https://github.com/ItsFrostyYo/uhara/raw/refs/heads/main/bin/uharaSN2",
            "Subnautica 2 Autosplitter " + vars.ScriptVersion,
            System.Windows.Forms.MessageBoxButtons.OK,
            System.Windows.Forms.MessageBoxIcon.Error
        );
        return;
    }

    Assembly.Load(File.ReadAllBytes("Components/uharaSN2")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();

    vars.introCutsceneLoadRemovalActive = false;
    vars.hatchAfterHighCapacityTankArmed = false;
    vars.CompletedCraftSplits = new HashSet<string>();

    vars.DoCraftSplit = (Func<string, bool>)((key) =>
    {
        if (vars.CompletedCraftSplits.Contains(key)) return false;
        vars.CompletedCraftSplits.Add(key);
        return true;
    });

    vars.ResetCraftSplits = (Action)(() =>
    {
        vars.CompletedCraftSplits.Clear();
    });

    vars.ResetRunState = (Action)(() =>
    {
        vars.introCutsceneLoadRemovalActive = false;
        vars.ResetCraftSplits();
        vars.hatchAfterHighCapacityTankArmed = false;
    });

    vars.IsSurvivalStart = (Func<bool>)(() =>
    {
        return vars.Resolver.CheckFlag("SurvivalStart1") || vars.Resolver.CheckFlag("SurvivalStart2");
    });

    dynamic[,] _settings =
    {
        { "ResetGroup", true, "Reset Types", null },
        { "ResetOnMainMenu", false, "Reset on Main Menu", "ResetGroup" },
        { "ResetOnNewGameSurvival", false, "Reset on New Game Start (Survival)", "ResetGroup" },
        { "ResetOnNewGameCreative", false, "Reset on New Game Start (Creative)", "ResetGroup" },

        { "Any%Group", true, "Any% Splits (Survival & Creative) + (Glitched & Glitchless)", null },
        { "AdaptationSplit", false, "Split on Any Adaptations (Pressure, Digestion, Heat, Axum)", "Any%Group" },
        { "BiobedAdaptationSplit", false, "Splits on Any Biobed Adaptations (Endurance, Dexterity)", "Any%Group" },
        { "IntroLifepodAscend", false, "Split on Lifepod Ascend (Intro)", "Any%Group" },
        { "IntroButtonPress", false, "Split on Analyze Button Press (Intro)", "Any%Group" },
        { "IntroLifepodLeftLeverPressed", false, "Split on Lifepod Lever Pressed (Intro)", "Any%Group" },
        { "IntroLifepodRightLeverPressed", false, "Split on Lifepod Release (Intro)", "Any%Group" },
        { "BuildHatchAfterHighCapacityTank", false, "Split on 2nd Base (Glitchless) [Building Hatch after High Capacity Tank]", "Any%Group" },
        { "EndObservatoryButtonPress", true, "Split on Observatory Button (End)", "Any%Group" },

        { "MiscellaneousSplitsGroup", true, "Miscellaneous Splits", null },
        { "FirstScan", false, "Split on First Scan", "MiscellaneousSplitsGroup" },
        // { "SonicResonatorBlastShot", false, "Split on Sonic Resonator Blast Shot", "MiscellaneousSplitsGroup" },
        // { "InteractWithSingleBed", false, "Split on Interact with Single Bed", "MiscellaneousSplitsGroup" },

        { "CraftSplitsGrouping", true, "Craft Splits", null },
        { "FabricatorGroup", true, "Fabricator", "CraftSplitsGrouping" },
        { "PersonalGroup", true, "Personal", "FabricatorGroup" },
        { "EquipmentGroup", true, "Equipment", "PersonalGroup" },
        { "HighCapacityAirTank", false, "Split on Crafting High Capacity Air Tank", "EquipmentGroup" },
        { "ToolsGroup", true, "Tools", "PersonalGroup" },
        { "Scanner", false, "Split on Crafting Scanner", "ToolsGroup" },
        { "Airbladder", false, "Split on Crafting Airbladder", "ToolsGroup" },
        { "ModificationStationGroup", true, "Modification Station", "CraftSplitsGrouping" },
        { "PrototypeToolModificationsGroup", true, "Prototype Tool Modifications", "ModificationStationGroup" },
        { "PrototypeToolModificationsPrototypeToolModificationsGroup", true, "Prototype Tool Modifications", "PrototypeToolModificationsGroup" },
        { "Bioscanner", false, "Split on Crafting Bioscanner", "PrototypeToolModificationsPrototypeToolModificationsGroup" },
        { "FeedbackResonator", false, "Split on Crafting Feedback Resonator", "PrototypeToolModificationsPrototypeToolModificationsGroup" },
    };

    vars.Uhara.Settings.Create(_settings);
}

init
{
    if (vars.MissingUhara) return;

    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
    vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
    vars.Utils.ExpandScanUtilitySignatures("UObject_BeginDestroy", "40 53 48 83 EC 40 8B 41 08 48 8B D9 0F BA E0 0F 72");

    vars.Utils.GEngine = vars.Uhara.ScanRel(3, "48 89 05 ?? ?? ?? ?? E8 ?? ?? ?? ?? 80 3D ?? ?? ?? ?? ?? 72 ?? 48");
    if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
    if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X"));
    if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));

    vars.Events.FunctionFlag("SurvivalStart1", "WBP_PDAScreen_C", "WBP_PDAScreen_C", "DummyBinding");
    vars.Events.FunctionFlag("SurvivalStart2", "ABP_SN2Player_LandMotion_Linked_C", "ABP_SN2Player_LandMotion_Linked_C", "EvaluateGraphExposedInputs_ExecuteUbergraph_ABP_SN2Player_LandMotion_Linked_AnimGraphNode_TransitionResult_4D84B2574C72089535FC5D8B426BFF75");
    vars.Events.FunctionFlag("CreativeStartArm", "BP_CreativeModePlayerStart_C", "BP_CreativeModePlayerStart_C_UAID_F02F74AC8D0CF16102", "OnStartConditionsApplied");
    vars.Events.FunctionFlag("ResetOnMainMenu", "WBP_MainLobbyScreen_C", "WBP_MainLobbyScreen_C", "Construct");

    vars.Events.FunctionFlag("AdaptationSplit", "BP_AngelCombCore_Ripple_NotifyState_C", "BP_AngelCombCore_Ripple_NotifyState_C", "Received_NotifyBegin");
    vars.Events.FunctionFlag("BiobedAdaptationInventory", "SN2PlayerUpgradesPlayerStateComponent", "PlayerUpgradesComponent", "OnEventTrackerIncreaseInventoryEvent");
    vars.Events.FunctionFlag("BiobedAdaptationToolbar", "SN2PlayerUpgradesPlayerStateComponent", "PlayerUpgradesComponent", "OnEventTrackerIncreaseToolbarEvent");
    vars.Events.FunctionFlag("IntroButtonPress", "BP_ScanningButton_C", "BP_ScanningButton_C_UAID_C87F54AE2B72FF0402", "BroadcastButtonPressed");
    vars.Events.FunctionFlag("IntroLifepodLeftLeverPressed", "BP_LifepodBay_Lever_C", "BP_LifepodBay_Lever_C_UAID_14AC60D60A5A096C02", "BroadcastButtonPressed");
    vars.Events.FunctionFlag("IntroLifepodRightLeverPressed", "BP_LifepodBay_Chunk_Hatch_C", "BP_LifepodBay_Chunk_Hatch_C_UAID_14AC60D60A5A056C02", "RightLever");
    vars.Events.FunctionFlag("EndObservatoryButtonPress", "BP_Hologram_AxumFinale_Button_C", "BP_HologramButton_Axum_C_UAID_A036BC2B70CF8AA502", "ToggledOn");

    vars.Events.FunctionFlag("CraftHighCapacityTank", "BP_OxygenTank_Medium_C", "BP_OxygenTank_Medium_C", "BPOnEquipped");
    vars.Events.FunctionFlag("CraftFeedbackResonator", "BP_SonicResonatorV2_C", "BP_SonicResonatorV2_C", "ItemPickedUp");
    vars.Events.FunctionFlag("CraftBioscanner", "BP_ScannerV2_C", "BP_ScannerV2_C", "ReceiveBeginPlay");
    vars.Events.FunctionFlag("CraftScannerSplit", "BP_Scanner_C", "BP_Scanner_C", "ReceiveBeginPlay");
    vars.Events.FunctionFlag("CraftAirbladder", "BP_AirBladder_C", "BP_AirBladder_C", "ExecuteUbergraph_BP_AirBladder");

    vars.Events.FunctionFlag("IntroLifepodAscend", "BP_NarrativeSignal_C", "BP_NarrativeSignal_C_UAID_60CF846429E036A502", "OnUnlocked_62920D1448BD71509596E5B554437304");
    vars.Events.FunctionFlag("IntroCutsceneLoadRemovalEnd", "BP_LifepodManager_C", "BP_LifepodManager_C_UAID_047C166D6A3238B502", "OnSequenceEnd");

    vars.Events.FunctionFlag("FirstScan", "GA_Scan_C", "GA_Scan_C", "OnCompleted_D22E6C2C4F34F79DF063E88A2D0679BA");
    // vars.Events.FunctionFlag("SonicResonatorBlastShot", "GA_SonicResonator_Blast_C", "GA_SonicResonator_Blast_C", "OnCompleted_B65B54F241049DF1F76DA59AAF9E5B09");
    // vars.Events.FunctionFlag("InteractWithSingleBed", "BP_BedSingle_C", "BP_BedSingle_C", "AttachEvent");

    vars.Events.FunctionFlag("BuildHatch", "BP_BaseHatch_C", "BP_BaseHatch_C", "BndEvt__BP_BaseHatch_UWEAttachable_K2Node_ComponentBoundEvent_0_OnAttached__DelegateSignature");

    vars.introCutsceneLoadRemovalActive = false;
    vars.hatchAfterHighCapacityTankArmed = false;
}

start
{
    if (vars.MissingUhara) return false;

    if (vars.IsSurvivalStart())
    {
        vars.ResetRunState();
        return true;
    }

    if (vars.Resolver.CheckFlag("CreativeStartArm"))
    {
        vars.ResetRunState();
        return true;
    }
}

update
{
    if (vars.MissingUhara) return;

    vars.Uhara.Update();

    if (vars.Resolver.CheckFlag("IntroLifepodAscend"))
        vars.introCutsceneLoadRemovalActive = true;

    if (vars.Resolver.CheckFlag("IntroCutsceneLoadRemovalEnd"))
        vars.introCutsceneLoadRemovalActive = false;

    if (vars.Resolver.CheckFlag("CraftHighCapacityTank"))
        vars.hatchAfterHighCapacityTankArmed = true;
}

split
{
    if (vars.MissingUhara) return false;

    if (vars.Resolver.CheckFlag("AdaptationSplit") && settings["AdaptationSplit"]) return true;
    if (vars.Resolver.CheckFlag("BiobedAdaptationInventory") && settings["BiobedAdaptationSplit"]) return true;
    if (vars.Resolver.CheckFlag("BiobedAdaptationToolbar") && settings["BiobedAdaptationSplit"]) return true;
    if (vars.Resolver.CheckFlag("IntroLifepodAscend") && settings["IntroLifepodAscend"]) return true;
    if (vars.Resolver.CheckFlag("IntroButtonPress") && settings["IntroButtonPress"]) return true;
    if (vars.Resolver.CheckFlag("IntroLifepodLeftLeverPressed") && settings["IntroLifepodLeftLeverPressed"]) return true;
    if (vars.Resolver.CheckFlag("IntroLifepodRightLeverPressed") && settings["IntroLifepodRightLeverPressed"]) return true;
    if (vars.Resolver.CheckFlag("EndObservatoryButtonPress") && settings["EndObservatoryButtonPress"]) return true;
    if (vars.hatchAfterHighCapacityTankArmed && vars.Resolver.CheckFlag("BuildHatch") && settings["BuildHatchAfterHighCapacityTank"] && vars.DoCraftSplit("BuildHatchAfterHighCapacityTank"))
    {
        vars.hatchAfterHighCapacityTankArmed = false;
        return true;
    }

    // if (vars.Resolver.CheckFlag("SonicResonatorBlastShot") && settings["SonicResonatorBlastShot"]) return true;
    // if (vars.Resolver.CheckFlag("InteractWithSingleBed") && settings["InteractWithSingleBed"]) return true;
    if (vars.Resolver.CheckFlag("FirstScan") && settings["FirstScan"] && vars.DoCraftSplit("FirstScan")) return true;

    if (vars.Resolver.CheckFlag("CraftHighCapacityTank") && settings["HighCapacityAirTank"] && vars.DoCraftSplit("HighCapacityAirTank")) return true;
    if (vars.Resolver.CheckFlag("CraftScannerSplit") && settings["Scanner"] && vars.DoCraftSplit("Scanner")) return true;
    if (vars.Resolver.CheckFlag("CraftAirbladder") && settings["Airbladder"] && vars.DoCraftSplit("Airbladder")) return true;
    if (vars.Resolver.CheckFlag("CraftBioscanner") && settings["Bioscanner"] && vars.DoCraftSplit("Bioscanner")) return true;
    if (vars.Resolver.CheckFlag("CraftFeedbackResonator") && settings["FeedbackResonator"] && vars.DoCraftSplit("FeedbackResonator")) return true;
}

onStart
{
    if (vars.MissingUhara) return;

    vars.ResetRunState();
}

reset
{
    if (vars.MissingUhara) return false;

    if (vars.Resolver.CheckFlag("ResetOnMainMenu") && settings["ResetOnMainMenu"])
    {
        vars.ResetRunState();
        return true;
    }

    if (vars.IsSurvivalStart() && settings["ResetOnNewGameSurvival"])
    {
        vars.ResetRunState();
        return true;
    }

    if (vars.Resolver.CheckFlag("CreativeStartArm") && settings["ResetOnNewGameCreative"])
    {
        vars.ResetRunState();
        return true;
    }
}

onReset
{
    if (vars.MissingUhara) return;

    vars.ResetRunState();
}

isLoading
{
    if (vars.MissingUhara) return false;

    return vars.introCutsceneLoadRemovalActive;
}
