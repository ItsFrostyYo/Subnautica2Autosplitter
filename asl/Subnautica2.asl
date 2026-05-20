state("Subnautica2-Win64-Shipping"){}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.AlertLoadless(); // Sends Alert for using Game Time for Load Removal

    vars.introCutsceneLoadRemovalActive = false;

    dynamic[,] _settings =
    {
        // Normal Splits (Currently Above)
        { "ResetOnMainMenu", false, "Reset on Main Menu", null },

        // Grouped Settings (Currently Below)
        { "group_splits", true, "Splits", null }, // Group Categorizing, named "Splits"
        // Where the Grouped Splits listed are
        { "AdaptationSplits", false, "Adaptation Splits", "group_splits" },
	    { "LifepodAscend", false, "Lifepod Ascend", "group_splits" },
        { "CraftHighCapacityTank", false, "Craft - High Capcity O2 Tank", "group_splits" },
        { "CraftFeedbackResonator", false, "Craft - Feedback Resonator", "group_splits" },
        { "CraftBioscanner", false, "Craft - Bioscanner", "group_splits" },
        { "End", true, "End Split", "group_splits" },
    };
    // Creates Settings
	vars.Uhara.Settings.Create(_settings);

}
init
{
    // Uhara Initalize
    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
    vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
    vars.Utils.ExpandScanUtilitySignatures("UObject_BeginDestroy", "40 53 48 83 EC 40 8B 41 08 48 8B D9 0F BA E0 0F 72");

    vars.Utils.GEngine = vars.Uhara.ScanRel(3, "48 89 05 ?? ?? ?? ?? E8 ?? ?? ?? ?? 80 3D ?? ?? ?? ?? ?? 72 ?? 48");
    if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
    if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X")); 
    if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));
    
    // Start Event Listeners
    vars.Events.FunctionFlag("SurvivalStart","BPC_SN2SyncedAnimation_C", "BPC_SN2SyncedAnimation", "OnInterrupted_6CE57B834482AC68669FA3BD7C032291");
    vars.Events.FunctionFlag("CreativeStart", "BP_CreativeModePlayerStart_C", "BP_CreativeModePlayerStart_C_UAID_F02F74AC8D0CF16102", "OnStartConditionsApplied");
    // Split Event Listeners
    vars.Events.FunctionFlag("Adaptation", "BP_AngelCombCore_Ripple_NotifyState_C", "BP_AngelCombCore_Ripple_NotifyState_C", "Received_NotifyBegin");
    vars.Events.FunctionFlag("LifepodAscend", "BP_NarrativeSignal_C", "BP_NarrativeSignal_C_UAID_60CF846429E036A502", "OnUnlocked_62920D1448BD71509596E5B554437304");
    vars.Events.FunctionFlag("CraftHighCapacityTank", "BP_OxygenTank_Medium_C", "BP_OxygenTank_Medium_C", "BPOnEquipped");
    vars.Events.FunctionFlag("CraftFeedbackResonator", "BP_SonicResonatorV2_C", "BP_SonicResonatorV2_C", "ItemPickedUp");
    vars.Events.FunctionFlag("CraftBioscanner", "BP_ScannerV2_C", "BP_ScannerV2_C", "ExecuteUbergraph_BP_Scanner");
    vars.Events.FunctionFlag("End", "BP_Hologram_AxumFinale_Button_C", "BP_HologramButton_Axum_C_UAID_A036BC2B70CF8AA502", "ToggledOn");
    // Reset/Load Removal Event Listeners
    vars.Events.FunctionFlag("ResetOnMainMenu", "WBP_MainLobbyScreen_C", "WBP_MainLobbyScreen_C", "Construct");
    vars.Events.FunctionFlag("IntroCutsceneLoadRemovalEnd", "BP_LifepodManager_C", "BP_LifepodManager_C_UAID_047C166D6A3238B502", "OnSequenceEnd");

    vars.introCutsceneLoadRemovalActive = false;
}
// Start Checks
start
{
    if (vars.Resolver.CheckFlag("SurvivalStart")) return true;
    if (vars.Resolver.CheckFlag("CreativeStart")) return true;

}
// Update Checks
update
{
    vars.Uhara.Update();

// Updating for Load Removal Checks
    if (vars.Resolver.CheckFlag("LifepodAscend"))
        vars.introCutsceneLoadRemovalActive = true;

    if (vars.Resolver.CheckFlag("IntroCutsceneLoadRemovalEnd"))
        vars.introCutsceneLoadRemovalActive = false;
}
// Split Checks
split
{
    if (vars.Resolver.CheckFlag("Adaptation") && settings["AdaptationSplits"]) return true;
    if (vars.Resolver.CheckFlag("LifepodAscend") && settings["LifepodAscend"]) return true;
    if (vars.Resolver.CheckFlag("CraftHighCapacityTank") && settings["CraftHighCapacityTank"]) return true;
    if (vars.Resolver.CheckFlag("CraftFeedbackResonator") && settings["CraftFeedbackResonator"]) return true;
    if (vars.Resolver.CheckFlag("CraftBioscanner") && settings["CraftBioscanner"]) return true;
    if (vars.Resolver.CheckFlag("End") && settings["End"]) return true;
}
// Reset Checks
reset
{
    if (vars.Resolver.CheckFlag("ResetOnMainMenu") && settings["ResetOnMainMenu"])
    {
        vars.introCutsceneLoadRemovalActive = false;
        return true;
    }
}

onReset
{
    vars.introCutsceneLoadRemovalActive = false;
}
// Listening to Update for load Removal
isLoading
{
    return vars.introCutsceneLoadRemovalActive;
}
