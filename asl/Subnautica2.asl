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
    vars.sonicResonatorBlastHatchArmed = false;
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
        // Creative Start Grouping
        { "CreativeStartGroup", true, "Creative Start Types", null },
        { "CreativeStartLoadIn", true, "Start on Load In (Leaderboard)", "CreativeStartGroup" },
        { "CreativeStartFirstInteractMovement", false, "Start on First Interact or Movement (Experimental)", "CreativeStartGroup" },

        // Reset Grouping
        { "ResetGroup", true, "Reset Types", null },
        { "ResetOnMainMenu", false, "Reset on Main Menu", "ResetGroup" },
        { "ResetOnNewGameSurvival", false, "Reset on New Game Start (Survival)", "ResetGroup" },
        { "ResetOnNewGameCreative", false, "Reset on New Game Start (Creative)", "ResetGroup" },

        // Any% Splits Grouping
        { "Any%Group", true, "Any% Splits (Survival & Creative) + (Glitched & Glitchless)", null },
        // Any% Splits Individual Settings
        { "AdaptationSplit", false, "Split on Any Adaptations (Pressure, Digestion, Heat, Axum)", "Any%Group" },
        { "IntroLifepodAscend", false, "Split on Lifepod Ascend (Intro)", "Any%Group" },
        { "IntroUnlockStartingDoor", false, "Split on Unlocking Door (Intro)", "Any%Group" },
        { "IntroButtonPress", false, "Split on Analyze Button Press (Intro)", "Any%Group" },
        { "IntroLifepodLeftLeverPressed", false, "Split on Lifepod Left Lever Pressed (Intro)", "Any%Group" },
        { "IntroLifepodRightLeverPressed", false, "Split on Lifepod Right Lever Pressed (Intro)", "Any%Group" },
        { "CraftHighCapacityTank", false, "Split on Crafting High Capacity O2 Tank (Glitchless)", "Any%Group" },
        { "CraftFeedbackResonator", false, "Split on Crafting Feedback Resonator (Glitchless)", "Any%Group" },
        { "CraftBioscanner", false, "Split on Craftng Bioscanner (Glitchless + NME)", "Any%Group" },
        { "CraftScannerSplit", false, "Split on Crafting Scanner (Glitched)", "Any%Group" },
        { "CraftAirbladder", false, "Split on Crafting Airbladder (Glitched)", "Any%Group" },
        { "BuildHatchAfterSonicResonator", false, "Split on Building Hatch after Sonic Resonator Blast (NME)", "Any%Group" },
        { "EndObservatoryButtonPress", true, "Split on Observatory Button (End)", "Any%Group" },

        // Miscellaneous Splits Grouping
        { "MiscellaneousSplitsGroup", true, "Miscellaneous Splits", null },
        { "FirstCraft", false, "Split on First Craft", "MiscellaneousSplitsGroup" },
        { "FirstScan", false, "Split on First Scan (Used for Rosetta Stone in Glitched)", "MiscellaneousSplitsGroup" },
        { "SonicResonatorBlastShot", false, "Split on Sonic Resonator Blast Shot", "MiscellaneousSplitsGroup" },
        { "InteractWithSingleBed", false, "Split on Interact with Single Bed", "MiscellaneousSplitsGroup" },

        // Habitat Builder Crafts Grouping
        { "HabitatBuilderCraftsGroup", true, "Habitat Builder Crafts", null },

        // Standard Elements Grouping
        { "HabitatBuilderStandardElementsGroup", false, "Standard Elements", "HabitatBuilderCraftsGroup" },
        { "HabitatBuilderBasePiecesGroup", false, "Base Pieces", "HabitatBuilderStandardElementsGroup" },
        { "BuildHatch", false, "Split on Build Hatch", "HabitatBuilderBasePiecesGroup" },
        { "HabitatBuilderVehiclesGroup", false, "Vehicles", "HabitatBuilderStandardElementsGroup" },
        { "BuildMoonpoolDock", false, "Split on Build Moonpool Dock", "HabitatBuilderVehiclesGroup" },
        { "BuildVehicleFabricator", false, "Split on Build Vehicle Fabricator", "HabitatBuilderVehiclesGroup" },

        // Interior Facilities Grouping
        { "HabitatBuilderInteriorFacilitiesGroup", false, "Interior Facilities", "HabitatBuilderCraftsGroup" },
        { "HabitatBuilderProductionGroup", false, "Production", "HabitatBuilderInteriorFacilitiesGroup" },
        { "BuildModificationStation", false, "Split on Build Modification Station", "HabitatBuilderProductionGroup" },
        { "BuildProcessorStation", false, "Split on Build Processor Station", "HabitatBuilderProductionGroup" },
        { "BuildBioLabStation", false, "Split on Build BioLab Station", "HabitatBuilderProductionGroup" },
        { "HabitatBuilderStorageGroup", false, "Storage", "HabitatBuilderInteriorFacilitiesGroup" },
        { "BuildAnyLockerThatHasALabel", false, "Split on Build Any Locker (That has a label)", "HabitatBuilderStorageGroup" },
        { "BuildTailingChest", false, "Split on Build Tailing Chest", "HabitatBuilderStorageGroup" },
        { "BuildWallRack", false, "Split on Build Wall Rack", "HabitatBuilderStorageGroup" },
        { "HabitatBuilderLightingGroup", false, "Lighting", "HabitatBuilderInteriorFacilitiesGroup" },
        { "BuildSmallCeilingLamp", false, "Split on Build Small Ceiling Lamp", "HabitatBuilderLightingGroup" },
        { "BuildRectangularCeilingLight", false, "Split on Build Rectangular Ceiling Light", "HabitatBuilderLightingGroup" },
        { "BuildWallLightSmall", false, "Split on Build Wall Light Small", "HabitatBuilderLightingGroup" },
        { "BuildAxumWallLight", false, "Split on Build Axum Wall Light", "HabitatBuilderLightingGroup" },
        { "HabitatBuilderPowerGroup", false, "Power", "HabitatBuilderInteriorFacilitiesGroup" },
        { "BuildBatteryTerminal", false, "Split on Build Battery Terminal", "HabitatBuilderPowerGroup" },
        { "BuildBioreactor", false, "Split on Build Bioreactor", "HabitatBuilderPowerGroup" },
        { "BuildPowerStorage", false, "Split on Build Power Storage", "HabitatBuilderPowerGroup" },
        { "HabitatBuilderHabitatSystemsGroup", false, "Habitat Systems", "HabitatBuilderInteriorFacilitiesGroup" },
        { "BuildBiobed", false, "Split on Build Biobed", "HabitatBuilderHabitatSystemsGroup" },
        { "BuildNoATerminal", false, "Split on Build NoA Terminal", "HabitatBuilderHabitatSystemsGroup" },
        { "BuildScannerStation", false, "Split on Build Scanner Station", "HabitatBuilderHabitatSystemsGroup" },

        // Exterior Facilities Grouping
        { "HabitatBuilderExteriorFacilitiesGroup", false, "Exterior Facilities", "HabitatBuilderCraftsGroup" },
        { "HabitatBuilderExteriorPowerGroup", false, "Power", "HabitatBuilderExteriorFacilitiesGroup" },
        { "BuildSolarPanel", false, "Split on Build Solar Panel", "HabitatBuilderExteriorPowerGroup" },
        { "BuildHydroelectricTurbine", false, "Split on Build Hydroelectric Turbine", "HabitatBuilderExteriorPowerGroup" },
        { "BuildAndAttachPowerTransmitter", false, "Split on Build & Attach Power Transmitter", "HabitatBuilderExteriorPowerGroup" },
        { "HabitatBuilderExteriorLightingGroup", false, "Lighting", "HabitatBuilderExteriorFacilitiesGroup" },
        { "BuildAndAttachExteriorWallLight", false, "Split on Build & Attach Exterior Wall Light", "HabitatBuilderExteriorLightingGroup" },
        { "BuildOREditHabitatBeacon", false, "Split on Build OR Edit Habitat Beacon", "HabitatBuilderExteriorLightingGroup" },

        // Utility Grouping
        { "HabitatBuilderUtilityGroup", false, "Utility", "HabitatBuilderCraftsGroup" },
        { "HabitatBuilderUtilitySubGroup", false, "Utility", "HabitatBuilderUtilityGroup" },

        // Furniture and Decor Grouping
        { "HabitatBuilderFurnitureAndDecorGroup", false, "Furniture and Decor", "HabitatBuilderCraftsGroup" },
        { "HabitatBuilderDecorationGroup", false, "Decoration", "HabitatBuilderFurnitureAndDecorGroup" },
        { "BuildWallUnitSmall", false, "Split on Build Wall Unit Small", "HabitatBuilderDecorationGroup" },

        // Cultivation Grouping
        { "HabitatBuilderCultivationGroup", false, "Cultivation", "HabitatBuilderCraftsGroup" },
        { "HabitatBuilderCultivationStructuresGroup", false, "Cultivation Structures", "HabitatBuilderCultivationGroup" },
        { "BuildMetalFarm", false, "Split on Build Metal Farm", "HabitatBuilderCultivationStructuresGroup" },
        { "HabitatBuilderPlantablesGroup", false, "Plantables", "HabitatBuilderCultivationGroup" },
        { "BuildPlantMimicPylon", false, "Split on Build/Plant Mimic Pylon", "HabitatBuilderPlantablesGroup" },

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
    vars.Events.FunctionFlag("CreativeStartInteractWithStorage", "BP_Character_01_C", "BP_Character_01_C", "OnInteractWithOtherInventory");
    vars.Events.FunctionFlag("CreativeStartFirstMovement", "GA_Walk_C", "GA_Walk_C", "OnStarted_CD32F07B44EEF144D8A18C86FCFC3E47");
    vars.Events.FunctionFlag("CreativeStartInteractWithFabricator", "WBP_FabricatorScreen_C", "WBP_FabricatorScreen_C", "RecipeListEntriesRefreshed");
    vars.Events.FunctionFlag("CreativeStartFirstJump", "BP_Character_01_C", "BP_Character_01_C", "OnJumped");
    vars.Events.FunctionFlag("CreativeStartOpenPDA", "WBP_Inventory_C", "WBP_Inventory_C", "ExecuteUbergraph_WBP_Inventory");
    vars.Events.FunctionFlag("CreativeStartInteractWithNoA", "WBP_ComputerTextInterface_C", "WBP_ComputerTextInterface_C", "UpdateDialogueOptions");
    vars.Events.FunctionFlag("CreativeStartFirstSwim", "GA_Swim_C", "GA_Swim_C", "OnStarted_E7B4EFF4450EE32D27781F951D040059");
    vars.Events.FunctionFlag("CreativeStartInteractWithBiomodStation", "WBP_CharacterCustomizationScreen_C", "WBP_CharacterCustomizationScreen_C", "ValidItemsChanged");
    // Any% Event Listeners
    vars.Events.FunctionFlag("AdaptationSplit", "BP_AngelCombCore_Ripple_NotifyState_C", "BP_AngelCombCore_Ripple_NotifyState_C", "Received_NotifyBegin");
    vars.Events.FunctionFlag("IntroButtonPress", "BP_ScanningButton_C", "BP_ScanningButton_C_UAID_C87F54AE2B72FF0402", "BroadcastButtonPressed");
    vars.Events.FunctionFlag("IntroUnlockStartingDoor", "BP_ComputerTextInterface_Terminal_C", "BP_ComputerTextInterface_Terminal_C_UAID_C87F54AE2B72FF0402", "OnWidgetPopped_Event");
    vars.Events.FunctionFlag("IntroLifepodLeftLeverPressed", "BP_LifepodBay_Lever_C", "BP_LifepodBay_Lever_C_UAID_14AC60D60A5A096C02", "BroadcastButtonPressed");
    vars.Events.FunctionFlag("IntroLifepodRightLeverPressed", "BP_LifepodBay_Chunk_Hatch_C", "BP_LifepodBay_Chunk_Hatch_C_UAID_14AC60D60A5A056C02", "RightLever");
    vars.Events.FunctionFlag("CraftHighCapacityTank", "BP_OxygenTank_Medium_C", "BP_OxygenTank_Medium_C", "BPOnEquipped");
    vars.Events.FunctionFlag("CraftFeedbackResonator", "BP_SonicResonatorV2_C", "BP_SonicResonatorV2_C", "ItemPickedUp");
    vars.Events.FunctionFlag("CraftBioscanner", "BP_ScannerV2_C", "BP_ScannerV2_C", "ReceiveBeginPlay");
    vars.Events.FunctionFlag("EndObservatoryButtonPress", "BP_Hologram_AxumFinale_Button_C", "BP_HologramButton_Axum_C_UAID_A036BC2B70CF8AA502", "ToggledOn");
    vars.Events.FunctionFlag("CraftScannerSplit", "BP_Scanner_C", "BP_Scanner_C", "ReceiveBeginPlay");
    vars.Events.FunctionFlag("CraftAirbladder", "BP_AirBladder_C", "BP_AirBladder_C", "ExecuteUbergraph_BP_AirBladder");
    vars.Events.FunctionFlag("BuildHatchAfterSonicResonatorBlast", "GA_SonicResonator_Blast_C", "GA_SonicResonator_Blast_C", "OnCompleted_B65B54F241049DF1F76DA59AAF9E5B09");

    // Load Removal Event Listeners
    vars.Events.FunctionFlag("IntroLifepodAscend", "BP_NarrativeSignal_C", "BP_NarrativeSignal_C_UAID_60CF846429E036A502", "OnUnlocked_62920D1448BD71509596E5B554437304");
    vars.Events.FunctionFlag("IntroCutsceneLoadRemovalEnd", "BP_LifepodManager_C", "BP_LifepodManager_C_UAID_047C166D6A3238B502", "OnSequenceEnd");

    // Miscellaneous Event Listeners
    vars.Events.FunctionFlag("FirstCraft", "ABP_Fabricator_C", "ABP_Fabricator_C2", "OnCraftingStarted_Event");
    vars.Events.FunctionFlag("FirstScan", "GA_Scan_C", "GA_Scan_C", "OnCompleted_D22E6C2C4F34F79DF063E88A2D0679BA");
    vars.Events.FunctionFlag("SonicResonatorBlastShot", "GA_SonicResonator_Blast_C", "GA_SonicResonator_Blast_C", "OnCompleted_B65B54F241049DF1F76DA59AAF9E5B09");
    vars.Events.FunctionFlag("InteractWithSingleBed", "BP_BedSingle_C", "BP_BedSingle_C", "AttachEvent");

    // Habitat Builder Crafts Event Listeners
    vars.Events.FunctionFlag("BuildHatch", "BP_BaseHatch_C", "BP_BaseHatch_C", "BndEvt__BP_BaseHatch_UWEAttachable_K2Node_ComponentBoundEvent_0_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildMoonpoolDock", "BP_MoonPool_Dock_C", "BP_MoonPool_Dock_C", "BndEvt__BP_TadpoleDock_Blister_UWEAttachable_K2Node_ComponentBoundEvent_1_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildVehicleFabricator", "BP_VehicleFabricator_C", "BP_VehicleFabricator_C", "BndEvt__BP_DryDockFabricator_UWEAttachable_K2Node_ComponentBoundEvent_0_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildModificationStation", "BP_ModificationStation_C", "BP_ModificationStation_C", "BndEvt__BP_Fabricator_UWEAttachable_K2Node_ComponentBoundEvent_2_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildProcessorStation", "BP_ProcessorStation_C", "BP_ProcessorStation_C", "OnAttached");
    vars.Events.FunctionFlag("BuildBioLabStation", "BP_BioLab_C", "BP_BioLab_C", "BndEvt__BP_BioLab_UWEAttachable_K2Node_ComponentBoundEvent_0_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildAnyLockerThatHasALabel", "BPC_LockerLabel_C", "BPC_LockerLabel", "BeginPlayEvent");
    vars.Events.FunctionFlag("BuildTailingChest", "BP_Tailing_Chest_C", "BP_Tailing_Chest_C", "OnPlacementChanged");
    vars.Events.FunctionFlag("BuildWallRack", "BP_Carryable_WallRack_C", "BP_Carryable_WallRack_C", "OnLockAdded");
    vars.Events.FunctionFlag("BuildSmallCeilingLamp", "BP_LampCeilingBulb_C", "BP_LampCeilingBulb_C", "BndEvt__BP_LampBase_UWEAttachable_K2Node_ComponentBoundEvent_0_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildRectangularCeilingLight", "BP_CeilingLight_Rect_A_C", "BP_CeilingLight_Rect_A_C", "BndEvt__BP_CeilingLight_Rect_A_UWEPoweredAppliance_K2Node_ComponentBoundEvent_1_OnPoweredStateChanged__DelegateSignature");
    vars.Events.FunctionFlag("BuildWallLightSmall", "BP_Light_Wall_Small_C", "BP_Light_Wall_Small_C", "BndEvt__BP_LampWallBulb_UWEPoweredAppliance_K2Node_ComponentBoundEvent_1_OnPoweredStateChanged__DelegateSignature");
    vars.Events.FunctionFlag("BuildAxumWallLight", "BP_AxumWallLamp_C", "BP_AxumWallLamp_C", "BndEvt__BP_AxumWallLamp_UWEPoweredAppliance_K2Node_ComponentBoundEvent_0_OnPoweredStateChanged__DelegateSignature");
    vars.Events.FunctionFlag("BuildBatteryTerminal", "BP_BasicBatteryTerminal_C", "BP_BasicBatteryTerminal_C", "BndEvt__BP_PowerTerminalBasic_UWEAttachable_K2Node_ComponentBoundEvent_0_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildBioreactor", "BP_Bioreactor_C", "BP_Bioreactor_C", "BndEvt__BP_Bioreactor_UWEAttachable_K2Node_ComponentBoundEvent_0_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildPowerStorage", "BP_PowerGridCapacitor_C", "BP_PowerGridCapacitor_C", "BndEvt__BP_PowerGridCapacitor_UWEAttachable_K2Node_ComponentBoundEvent_0_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildBiobed", "BP_BioBed_Buildable_C", "BP_BioBed_Buildable_C", "BndEvt__BP_BioBed_UWEPoweredAppliance_K2Node_ComponentBoundEvent_1_OnPoweredStateChanged__DelegateSignature");
    vars.Events.FunctionFlag("BuildNoATerminal", "BP_ComputerTextInterface_Terminal_PlayerBuilt_C", "BP_ComputerTextInterface_Terminal_PlayerBuilt_C", "BndEvt__BP_ComputerTextInterface_Terminal_UWEAttachable_K2Node_ComponentBoundEvent_5_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildScannerStation", "BP_ScannerStation_C", "BP_ScannerStation_C", "BndEvt__BP_ScannerStation_Proto_UWEAttachable_K2Node_ComponentBoundEvent_1_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildSolarPanel", "BP_SolarPanel_C", "BP_SolarPanel_C", "BndEvt__BP_SolarPanel_UWEAttachable_K2Node_ComponentBoundEvent_1_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildHydroelectricTurbine", "BP_HydroelectricTurbine_C", "BP_HydroelectricTurbine_C", "OnPlacementChanged");
    vars.Events.FunctionFlag("BuildAndAttachPowerTransmitter", "BP_PowerTransmitter_C", "BP_PowerTransmitter_C", "BndEvt__BP_PowerTransmitter_UWEAttachable_K2Node_ComponentBoundEvent_2_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildAndAttachExteriorWallLight", "BP_LampExteriorWallBulb_C", "BP_LampExteriorWallBulb_C", "BndEvt__BP_LampBase_UWEAttachable_K2Node_ComponentBoundEvent_0_OnAttached__DelegateSignature");
    vars.Events.FunctionFlag("BuildOREditHabitatBeacon", "BP_BaseSignal_C", "BP_BaseSignal_C", "OnPingChanged_Event");
    vars.Events.FunctionFlag("BuildWallUnitSmall", "BP_Greeble_WallUnit_A_C", "BP_Greeble_WallUnit_A_C", "BndEvt__BP_CeilingLight_Rect_A_UWEPoweredAppliance_K2Node_ComponentBoundEvent_1_OnPoweredStateChanged__DelegateSignature");
    vars.Events.FunctionFlag("BuildMetalFarm", "BP_MetalFarm_C", "BP_MetalFarm_C", "BndEvt__BP_MetalFarm_UWEPowerSystem_K2Node_ComponentBoundEvent_1_PoweredStateChanged__DelegateSignature");
    vars.Events.FunctionFlag("BuildPlantMimicPylon", "BP_Farmable_FeelerTree_C", "BP_Farmable_FeelerTree_C", "BndEvt__BP_Farmable_OxygenPlant_UWESeedGrower_K2Node_ComponentBoundEvent_1_SeedSpawnedDelegate__DelegateSignature");
    // [NOT SAFE DONT ADD] Splits on Build Time of Day Display OR Time of Day Display Has new Day Changed [WBP_TimeOfDayTracker_C] [WBP_TimeOfDayTracker_C] [HandleDayPhaseChanged]
    // [NOT SAFE DONT ADD] Build Thermal Plant [BP_ThermalPlant_C] [BP_ThermalPlant_C] [ExecuteUbergraph_BP_ThermalPlant]

    vars.introCutsceneLoadRemovalActive = false;
    vars.creativeStartArmed = false;
    vars.sonicResonatorBlastHatchArmed = false;
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
        // If both are enabled, Load In wins and starts immediately.
        if (settings["CreativeStartLoadIn"])
        {
            vars.introCutsceneLoadRemovalActive = false;
            vars.ResetCraftSplits();
            vars.creativeStartArmed = false;
            return true;
        }

        if (settings["CreativeStartFirstInteractMovement"])
            vars.creativeStartArmed = true;
    }

    if (vars.creativeStartArmed && (
        vars.Resolver.CheckFlag("CreativeStartInteractWithStorage") ||
        vars.Resolver.CheckFlag("CreativeStartFirstMovement") ||
        vars.Resolver.CheckFlag("CreativeStartInteractWithFabricator") ||
        vars.Resolver.CheckFlag("CreativeStartFirstJump") ||
        vars.Resolver.CheckFlag("CreativeStartOpenPDA") ||
        vars.Resolver.CheckFlag("CreativeStartInteractWithNoA") ||
        vars.Resolver.CheckFlag("CreativeStartFirstSwim") ||
        vars.Resolver.CheckFlag("CreativeStartInteractWithBiomodStation")
    ))
    {
        vars.introCutsceneLoadRemovalActive = false;
        vars.ResetCraftSplits();
        vars.creativeStartArmed = false;
        return true;
    }

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

    if (vars.Resolver.CheckFlag("BuildHatchAfterSonicResonatorBlast"))
        vars.sonicResonatorBlastHatchArmed = true;
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
    if (vars.Resolver.CheckFlag("CraftAirbladder") && settings["CraftAirbladder"] && vars.DoCraftSplit("CraftAirbladder")) return true;
    if (vars.Resolver.CheckFlag("IntroUnlockStartingDoor") && settings["IntroUnlockStartingDoor"] && vars.DoCraftSplit("IntroUnlockStartingDoor")) return true;
    if (vars.sonicResonatorBlastHatchArmed && vars.Resolver.CheckFlag("BuildHatch") && settings["BuildHatchAfterSonicResonator"])
    {
        vars.sonicResonatorBlastHatchArmed = false;
        return true;
    }

    // Miscellaneous Splits
    if (vars.Resolver.CheckFlag("SonicResonatorBlastShot") && settings["SonicResonatorBlastShot"]) return true;
    if (vars.Resolver.CheckFlag("InteractWithSingleBed") && settings["InteractWithSingleBed"]) return true;
    if (vars.Resolver.CheckFlag("FirstCraft") && settings["FirstCraft"] && vars.DoCraftSplit("FirstCraft")) return true;
    if (vars.Resolver.CheckFlag("FirstScan") && settings["FirstScan"] && vars.DoCraftSplit("FirstScan")) return true;

    // Habitat Builder Crafts Splits
    if (vars.Resolver.CheckFlag("BuildHatch") && settings["BuildHatch"] && vars.DoCraftSplit("BuildHatch")) return true;
    if (vars.Resolver.CheckFlag("BuildMoonpoolDock") && settings["BuildMoonpoolDock"] && vars.DoCraftSplit("BuildMoonpoolDock")) return true;
    if (vars.Resolver.CheckFlag("BuildVehicleFabricator") && settings["BuildVehicleFabricator"] && vars.DoCraftSplit("BuildVehicleFabricator")) return true;
    if (vars.Resolver.CheckFlag("BuildModificationStation") && settings["BuildModificationStation"] && vars.DoCraftSplit("BuildModificationStation")) return true;
    if (vars.Resolver.CheckFlag("BuildProcessorStation") && settings["BuildProcessorStation"] && vars.DoCraftSplit("BuildProcessorStation")) return true;
    if (vars.Resolver.CheckFlag("BuildBioLabStation") && settings["BuildBioLabStation"] && vars.DoCraftSplit("BuildBioLabStation")) return true;
    if (vars.Resolver.CheckFlag("BuildAnyLockerThatHasALabel") && settings["BuildAnyLockerThatHasALabel"] && vars.DoCraftSplit("BuildAnyLockerThatHasALabel")) return true;
    if (vars.Resolver.CheckFlag("BuildTailingChest") && settings["BuildTailingChest"] && vars.DoCraftSplit("BuildTailingChest")) return true;
    if (vars.Resolver.CheckFlag("BuildWallRack") && settings["BuildWallRack"] && vars.DoCraftSplit("BuildWallRack")) return true;
    if (vars.Resolver.CheckFlag("BuildSmallCeilingLamp") && settings["BuildSmallCeilingLamp"] && vars.DoCraftSplit("BuildSmallCeilingLamp")) return true;
    if (vars.Resolver.CheckFlag("BuildRectangularCeilingLight") && settings["BuildRectangularCeilingLight"] && vars.DoCraftSplit("BuildRectangularCeilingLight")) return true;
    if (vars.Resolver.CheckFlag("BuildWallLightSmall") && settings["BuildWallLightSmall"] && vars.DoCraftSplit("BuildWallLightSmall")) return true;
    if (vars.Resolver.CheckFlag("BuildAxumWallLight") && settings["BuildAxumWallLight"] && vars.DoCraftSplit("BuildAxumWallLight")) return true;
    if (vars.Resolver.CheckFlag("BuildBatteryTerminal") && settings["BuildBatteryTerminal"] && vars.DoCraftSplit("BuildBatteryTerminal")) return true;
    if (vars.Resolver.CheckFlag("BuildBioreactor") && settings["BuildBioreactor"] && vars.DoCraftSplit("BuildBioreactor")) return true;
    if (vars.Resolver.CheckFlag("BuildPowerStorage") && settings["BuildPowerStorage"] && vars.DoCraftSplit("BuildPowerStorage")) return true;
    if (vars.Resolver.CheckFlag("BuildBiobed") && settings["BuildBiobed"] && vars.DoCraftSplit("BuildBiobed")) return true;
    if (vars.Resolver.CheckFlag("BuildNoATerminal") && settings["BuildNoATerminal"] && vars.DoCraftSplit("BuildNoATerminal")) return true;
    if (vars.Resolver.CheckFlag("BuildScannerStation") && settings["BuildScannerStation"] && vars.DoCraftSplit("BuildScannerStation")) return true;
    if (vars.Resolver.CheckFlag("BuildSolarPanel") && settings["BuildSolarPanel"] && vars.DoCraftSplit("BuildSolarPanel")) return true;
    if (vars.Resolver.CheckFlag("BuildHydroelectricTurbine") && settings["BuildHydroelectricTurbine"] && vars.DoCraftSplit("BuildHydroelectricTurbine")) return true;
    if (vars.Resolver.CheckFlag("BuildAndAttachPowerTransmitter") && settings["BuildAndAttachPowerTransmitter"] && vars.DoCraftSplit("BuildAndAttachPowerTransmitter")) return true;
    if (vars.Resolver.CheckFlag("BuildAndAttachExteriorWallLight") && settings["BuildAndAttachExteriorWallLight"] && vars.DoCraftSplit("BuildAndAttachExteriorWallLight")) return true;
    if (vars.Resolver.CheckFlag("BuildOREditHabitatBeacon") && settings["BuildOREditHabitatBeacon"] && vars.DoCraftSplit("BuildOREditHabitatBeacon")) return true;
    if (vars.Resolver.CheckFlag("BuildWallUnitSmall") && settings["BuildWallUnitSmall"] && vars.DoCraftSplit("BuildWallUnitSmall")) return true;
    if (vars.Resolver.CheckFlag("BuildMetalFarm") && settings["BuildMetalFarm"] && vars.DoCraftSplit("BuildMetalFarm")) return true;
    if (vars.Resolver.CheckFlag("BuildPlantMimicPylon") && settings["BuildPlantMimicPylon"] && vars.DoCraftSplit("BuildPlantMimicPylon")) return true;
}
onStart
{
    if (vars.MissingUhara) return;

    vars.ResetCraftSplits();
    vars.introCutsceneLoadRemovalActive = false;
    vars.creativeStartArmed = false;
    vars.sonicResonatorBlastHatchArmed = false;
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
    vars.sonicResonatorBlastHatchArmed = false;
}
// Listening to Update for load Removal
isLoading
{
    if (vars.MissingUhara) return false;

    return vars.introCutsceneLoadRemovalActive;
    // return vars.introCutsceneLoadRemovalActive || current.GSync; // Temporary Disable GSync
}
