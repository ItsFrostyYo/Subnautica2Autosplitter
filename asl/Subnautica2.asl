state("Subnautica2-Win64-Shipping"){}
state("Subnautica2-WinGDK-Shipping"){}

startup
{
    vars.ScriptVersion = "v1.0.7";
    vars.MissingUhara = !File.Exists("Components/uhara10");
    if (vars.MissingUhara)
    {
        System.Windows.Forms.MessageBox.Show(
            "Missing required file: Components/uhara10,\n" +
            "Please Place uhara10 in your LiveSplit Components folder.\n" +
            "https://github.com/ru-mii/uhara/raw/refs/heads/main/bin/uhara10",
            "Subnautica 2 Autosplitter " + vars.ScriptVersion,
            System.Windows.Forms.MessageBoxButtons.OK,
            System.Windows.Forms.MessageBoxIcon.Error
        );
        return;
    }

    Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.AlertLoadless(); // Sends Alert for using Game Time for Load Removal

    vars.introCutsceneLoadRemovalActive = false;
    vars.creativeStartArmed = false;
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

    dynamic[,] _settings =
    {
        // Reset Grouping
        { "ResetGroup", true, "Reset Types", null },
        { "ResetOnMainMenu", false, "Reset on Main Menu", "ResetGroup" },
        { "ResetOnNewGameSurvival", false, "Reset on New Game Start (Survival)", "ResetGroup" },
        { "ResetOnNewGameCreative", false, "Reset on New Game Start (Creative)", "ResetGroup" },

        // Any% Splits Grouping
        { "Any%Group", true, "Any% Splits (Survival & Creative) + (Glitched & Glitchless)", null },
        // Any% Splits Individual Settings
        { "AdaptationSplit", false, "Any Adaptations", "Any%Group" },
        { "IntroLifepodAscend", false, "Lifepod Ascend", "Any%Group" },
        { "IntroButtonPress", false, "Button Press", "Any%Group" },
        { "IntroLifepodLeftLeverPressed", false, "Lifepod Left Lever Pressed", "Any%Group" },
        { "IntroLifepodRightLeverPressed", false, "Lifepod Right Lever Pressed", "Any%Group" },
        { "CraftHighCapacityTank", false, "Craft High Capacity O2 Tank", "Any%Group" },
        { "CraftFeedbackResonator", false, "Craft Feedback Resonator", "Any%Group" },
        { "CraftBioscanner", false, "Craft Bioscanner", "Any%Group" },
        { "CraftScannerSplit", false, "Craft Scanner", "Any%Group" },
        { "EndObservatoryButtonPress", true, "Observatory Button (End)", "Any%Group" },

        // Miscellaneous Splits Grouping
        { "MiscellaneousSplitsGroup", true, "Miscellaneous Splits", null },
        { "CraftingSplits", true, "Crafting Splits", "MiscellaneousSplitsGroup" },
        { "FirstCraft", false, "Split on First Craft", "CraftingSplits" },
        // Other in th Future
        // { "Nothing1", false, "More Coming in the Future", "MiscellaneousSplitsGroup" },

    };
    // Creates Settings
	vars.Uhara.Settings.Create(_settings);

}
init
{
    if (vars.MissingUhara) return;

    // Uhara Initalize
    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
    vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
    vars.Utils.ExpandScanUtilitySignatures("UObject_BeginDestroy", "40 53 48 83 EC 40 8B 41 08 48 8B D9 0F BA E0 0F 72");

    vars.Utils.GEngine = vars.Uhara.ScanRel(3, "48 89 05 ?? ?? ?? ?? E8 ?? ?? ?? ?? 80 3D ?? ?? ?? ?? ?? 72 ?? 48");
    if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
    if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X")); 
    if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));
    // vars.Resolver.Watch<bool>("GSync", vars.Utils.GSync); // Temporary Disable GSync
    
    // Start/Reset Event Listeners
    vars.Events.FunctionFlag("SurvivalStart","BPC_SN2SyncedAnimation_C", "BPC_SN2SyncedAnimation", "OnInterrupted_6CE57B834482AC68669FA3BD7C032291");
    vars.Events.FunctionFlag("CreativeStartArm", "BP_CreativeModePlayerStart_C", "BP_CreativeModePlayerStart_C_UAID_F02F74AC8D0CF16102", "OnStartConditionsApplied");
    vars.Events.FunctionFlag("ResetOnMainMenu", "WBP_MainLobbyScreen_C", "WBP_MainLobbyScreen_C", "Construct");
    // Creative Start Follow-Up Event Listeners
    // Interact with Storage Start [BP_Character_01_C] [BP_Character_01_C] [OnInteractWithOtherInventory]
    vars.Events.FunctionFlag("CreativeStartInteractWithStorage", "BP_Character_01_C", "BP_Character_01_C", "OnInteractWithOtherInventory");
    // First Movement Start [GA_Walk_C] [GA_Walk_C] [OnStarted_CD32F07B44EEF144D8A18C86FCFC3E47]
    vars.Events.FunctionFlag("CreativeStartFirstMovement", "GA_Walk_C", "GA_Walk_C", "OnStarted_CD32F07B44EEF144D8A18C86FCFC3E47");
    // Interact with Fabricator Start [WBP_FabricatorScreen_C] [WBP_FabricatorScreen_C] [RecipeListEntriesRefreshed]
    vars.Events.FunctionFlag("CreativeStartInteractWithFabricator", "WBP_FabricatorScreen_C", "WBP_FabricatorScreen_C", "RecipeListEntriesRefreshed");
    // First Jump Start [BP_Character_01_C] [BP_Character_01_C] [OnJumped]
    vars.Events.FunctionFlag("CreativeStartFirstJump", "BP_Character_01_C", "BP_Character_01_C", "OnJumped");
    // Open PDA Start [WBP_Inventory_C] [WBP_Inventory_C] [ExecuteUbergraph_WBP_Inventory]
    vars.Events.FunctionFlag("CreativeStartOpenPDA", "WBP_Inventory_C", "WBP_Inventory_C", "ExecuteUbergraph_WBP_Inventory");
    // Interact with NoA Start [WBP_ComputerTextInterface_C] [WBP_ComputerTextInterface_C] [UpdateDialogueOptions]
    vars.Events.FunctionFlag("CreativeStartInteractWithNoA", "WBP_ComputerTextInterface_C", "WBP_ComputerTextInterface_C", "UpdateDialogueOptions");
    // First Swim Start [GA_Swim_C] [GA_Swim_C] [OnStarted_E7B4EFF4450EE32D27781F951D040059]
    vars.Events.FunctionFlag("CreativeStartFirstSwim", "GA_Swim_C", "GA_Swim_C", "OnStarted_E7B4EFF4450EE32D27781F951D040059");
    // Any% Event Listeners
    vars.Events.FunctionFlag("AdaptationSplit", "BP_AngelCombCore_Ripple_NotifyState_C", "BP_AngelCombCore_Ripple_NotifyState_C", "Received_NotifyBegin");
    vars.Events.FunctionFlag("IntroButtonPress", "BP_ScanningButton_C", "BP_ScanningButton_C_UAID_C87F54AE2B72FF0402", "BroadcastButtonPressed");
    vars.Events.FunctionFlag("IntroLifepodLeftLeverPressed", "BP_LifepodBay_Lever_C", "BP_LifepodBay_Lever_C_UAID_14AC60D60A5A096C02", "BroadcastButtonPressed");
    vars.Events.FunctionFlag("IntroLifepodRightLeverPressed", "BP_LifepodBay_Chunk_Hatch_C", "BP_LifepodBay_Chunk_Hatch_C_UAID_14AC60D60A5A056C02", "RightLever");
    vars.Events.FunctionFlag("CraftHighCapacityTank", "BP_OxygenTank_Medium_C", "BP_OxygenTank_Medium_C", "BPOnEquipped");
    vars.Events.FunctionFlag("CraftFeedbackResonator", "BP_SonicResonatorV2_C", "BP_SonicResonatorV2_C", "ItemPickedUp");
    vars.Events.FunctionFlag("CraftBioscanner", "BP_ScannerV2_C", "BP_ScannerV2_C", "ReceiveBeginPlay");
    vars.Events.FunctionFlag("EndObservatoryButtonPress", "BP_Hologram_AxumFinale_Button_C", "BP_HologramButton_Axum_C_UAID_A036BC2B70CF8AA502", "ToggledOn");
    vars.Events.FunctionFlag("CraftScannerSplit", "BP_Scanner_C", "BP_Scanner_C", "ReceiveBeginPlay");
    vars.Events.FunctionFlag("FirstCraft", "ABP_Fabricator_C", "ABP_Fabricator_C2", "OnCraftingStarted_Event");
    // Load Removal Event Listeners
    vars.Events.FunctionFlag("IntroLifepodAscend", "BP_NarrativeSignal_C", "BP_NarrativeSignal_C_UAID_60CF846429E036A502", "OnUnlocked_62920D1448BD71509596E5B554437304");
    vars.Events.FunctionFlag("IntroCutsceneLoadRemovalEnd", "BP_LifepodManager_C", "BP_LifepodManager_C_UAID_047C166D6A3238B502", "OnSequenceEnd");

    vars.introCutsceneLoadRemovalActive = false;
    vars.creativeStartArmed = false;
}
// Start Checks
start
{
    if (vars.MissingUhara) return false;

    if (vars.Resolver.CheckFlag("SurvivalStart"))
    {
        vars.introCutsceneLoadRemovalActive = false;
        vars.ResetCraftSplits();
        vars.creativeStartArmed = false;
        return true;
    }
    
    if (vars.Resolver.CheckFlag("CreativeStartArm"))
{
    vars.introCutsceneLoadRemovalActive = false;
    vars.ResetCraftSplits();
    vars.creativeStartArmed = false;
    return true;
}

    // if (vars.Resolver.CheckFlag("CreativeStartArm"))
    //     vars.creativeStartArmed = true;

    // if (vars.creativeStartArmed && (
    //     vars.Resolver.CheckFlag("CreativeStartInteractWithStorage") ||
    //    vars.Resolver.CheckFlag("CreativeStartFirstMovement") ||
    //    vars.Resolver.CheckFlag("CreativeStartInteractWithFabricator") ||
    //    vars.Resolver.CheckFlag("CreativeStartFirstJump") ||
    //    vars.Resolver.CheckFlag("CreativeStartOpenPDA") ||
    //    vars.Resolver.CheckFlag("CreativeStartInteractWithNoA") ||
    //    vars.Resolver.CheckFlag("CreativeStartFirstSwim")
    //))
    //{
    //    vars.introCutsceneLoadRemovalActive = false;
    //    vars.ResetCraftSplits();
    //    vars.creativeStartArmed = false;
    //    return true;
    //}

}
// Update Checks
update
{
    if (vars.MissingUhara) return;

    vars.Uhara.Update();

// Updating for Load Removal Checks
    if (vars.Resolver.CheckFlag("IntroLifepodAscend"))
        vars.introCutsceneLoadRemovalActive = true;

    if (vars.Resolver.CheckFlag("IntroCutsceneLoadRemovalEnd"))
        vars.introCutsceneLoadRemovalActive = false;
}
// Split Checks
split
{
    if (vars.MissingUhara) return false;

    // Any% Splits
    if (vars.Resolver.CheckFlag("AdaptationSplit") && settings["AdaptationSplit"]) return true;
    if (vars.Resolver.CheckFlag("IntroLifepodAscend") && settings["IntroLifepodAscend"]) return true;
    if (vars.Resolver.CheckFlag("IntroButtonPress") && settings["IntroButtonPress"]) return true;
    if (vars.Resolver.CheckFlag("IntroLifepodLeftLeverPressed") && settings["IntroLifepodLeftLeverPressed"]) return true;
    if (vars.Resolver.CheckFlag("IntroLifepodRightLeverPressed") && settings["IntroLifepodRightLeverPressed"]) return true;
    if (vars.Resolver.CheckFlag("CraftHighCapacityTank") && settings["CraftHighCapacityTank"] && vars.DoCraftSplit("CraftHighCapacityTank")) return true;
    if (vars.Resolver.CheckFlag("CraftFeedbackResonator") && settings["CraftFeedbackResonator"] && vars.DoCraftSplit("CraftFeedbackResonator")) return true;
    if (vars.Resolver.CheckFlag("CraftBioscanner") && settings["CraftBioscanner"] && vars.DoCraftSplit("CraftBioscanner")) return true;
    if (vars.Resolver.CheckFlag("EndObservatoryButtonPress") && settings["EndObservatoryButtonPress"]) return true;
    if (vars.Resolver.CheckFlag("CraftScannerSplit") && settings["CraftScannerSplit"] && vars.DoCraftSplit("CraftScannerSplit")) return true;
	if (vars.Resolver.CheckFlag("FirstCraft") && settings["FirstCraft"] && vars.DoCraftSplit("FirstCraft")) return true;
}
onStart
{
    if (vars.MissingUhara) return;

    vars.ResetCraftSplits();
    vars.introCutsceneLoadRemovalActive = false;
    vars.creativeStartArmed = false;
}
// Reset Checks
reset
{
    if (vars.MissingUhara) return false;

    if (vars.Resolver.CheckFlag("ResetOnMainMenu") && settings["ResetOnMainMenu"])
    {
        vars.introCutsceneLoadRemovalActive = false;
        vars.ResetCraftSplits();
        vars.creativeStartArmed = false;
        return true;
    }
    if (vars.Resolver.CheckFlag("SurvivalStart") && settings["ResetOnNewGameSurvival"])
    {
        vars.introCutsceneLoadRemovalActive = false;
        vars.ResetCraftSplits();
        vars.creativeStartArmed = false;
        return true;
    }
    if (vars.Resolver.CheckFlag("CreativeStartArm") && settings["ResetOnNewGameCreative"])
    {
        vars.introCutsceneLoadRemovalActive = false;
        vars.ResetCraftSplits();
        vars.creativeStartArmed = false;
        return true;
    }
}
// Reset load removal on normal reset
onReset
{
    if (vars.MissingUhara) return;

    vars.introCutsceneLoadRemovalActive = false;
    vars.ResetCraftSplits();
    vars.creativeStartArmed = false;
}
// Listening to Update for load Removal
isLoading
{
    if (vars.MissingUhara) return false;

    return vars.introCutsceneLoadRemovalActive;
    // return vars.introCutsceneLoadRemovalActive || current.GSync; // Temporary Disable GSync
}
