state("Subnautica2-Win64-Shipping"){}
state("Subnautica2-WinGDK-Shipping"){}

startup
{
    vars.ScriptVersion = "v1.0.7";
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
    vars.Uhara.AlertLoadless(); // Sends Alert for using Game Time for Load Removal

    vars.introCutsceneLoadRemovalActive = false;
    vars.creativeStartArmed = false;
    vars.hatchAfterTadpoleArmed = false;
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

    dynamic[,] _settings =
    {
        // Load Removal Testing Grouping
        //{ "ExperimentalGrouping", true, "Experimental Features (Not Leaderboard Legal)", null },
        //{ "RespawnLoadRemoval", false, "Unstuck/Death Respawn Load Removal", "ExperimentalGrouping" },
        //{ "CreativeStartFirstInteractMovement", false, "Creative Start on First Interact or Movement", "ExperimentalGrouping" },
        //{ "EnableGSyncLoadRemoval", false, "Enable GSync Load Removal", "ExperimentalGrouping" },

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
        { "IntroLifepodLeftLeverPressed", false, "Split on Lifepod Lever Pressed (Intro)", "Any%Group" },
        { "IntroLifepodRightLeverPressed", false, "Split on Lifepod Release (Intro)", "Any%Group" },
        { "BuildHatchAfterTadpole", false, "Split on 2nd Base (NME) [Building Hatch after Tadpole]", "Any%Group" },
        { "BuildHatchAfterHighCapacityTank", false, "Split on 2nd Base (Glitchless) [Building Hatch after High Capacity Tank]", "Any%Group" },
        { "RosettaStoneUnlock", false, "Rosetta Stone Scan", "Any%Group" },
        { "EndObservatoryButtonPress", true, "Split on Observatory Button (End)", "Any%Group" },

        // Miscellaneous Splits Grouping
        { "MiscellaneousSplitsGroup", true, "Miscellaneous Splits", null },
        { "FirstCraft", false, "Split on First Craft", "MiscellaneousSplitsGroup" },
        { "FirstScan", false, "Split on First Scan", "MiscellaneousSplitsGroup" },
        { "SonicResonatorBlastShot", false, "Split on Sonic Resonator Blast Shot", "MiscellaneousSplitsGroup" },
        { "InteractWithSingleBed", false, "Split on Interact with Single Bed", "MiscellaneousSplitsGroup" },

        // Craft Splits Grouping
        { "CraftSplitsGrouping", true, "Craft Splits", null },

        // Fabricator Grouping
        { "FabricatorGroup", true, "Fabricator", "CraftSplitsGrouping" },

        // Personal Grouping
        { "PersonalGroup", true, "Personal", "FabricatorGroup" },

        // Equipment Grouping
        { "EquipmentGroup", true, "Equipment", "PersonalGroup" },
        // Equipment Individual Settings
        { "Rebreather", false, "Split on Crafting Rebreather", "EquipmentGroup" },
        { "BasicFins", false, "Split on Crafting Basic Fins", "EquipmentGroup" },
        { "ImprovedFins", false, "Split on Crafting Improved Fins", "EquipmentGroup" },
        { "StandardAirTank", false, "Split on Crafting Standard Air Tank", "EquipmentGroup" },
        { "HighCapacityAirTank", false, "Split on Crafting High Capacity Air Tank", "EquipmentGroup" },
        { "UltraHighCapacityAirTank", false, "Split on Crafting Ultra High Capacity Air Tank", "EquipmentGroup" },

        // Tools Grouping
        { "ToolsGroup", true, "Tools", "PersonalGroup" },
        // Tools Individual Settings
        { "SurvivalMultitool", false, "Split on Crafting Survival Multitool", "ToolsGroup" },
        { "Flashlight", false, "Split on Crafting Flashlight", "ToolsGroup" },
        { "Scanner", false, "Split on Crafting Scanner", "ToolsGroup" },
        { "HabitatBuilder", false, "Split on Crafting Habitat Builder", "ToolsGroup" },
        { "RepairTool", false, "Split on Crafting Repair Tool", "ToolsGroup" },
        { "SonicResonator", false, "Split on Crafting Sonic Resonator", "ToolsGroup" },
        { "Wakemaker", false, "Split on Crafting Wakemaker", "ToolsGroup" },
        { "Airbladder", false, "Split on Crafting Airbladder", "ToolsGroup" },

        // Resources Grouping
        { "ResourcesGroup", true, "Resources", "FabricatorGroup" },

        // Basic Materials Grouping
        { "BasicMaterialsGroup", true, "Basic Materials", "ResourcesGroup" },
        // Basic Materials Individual Settings
        { "MildAcid", false, "Split on Crafting Mild Acid", "BasicMaterialsGroup" },
        { "SalvagedTitanium", false, "Split on Crafting Salvaged Titanium", "BasicMaterialsGroup" },
        { "Glass", false, "Split on Crafting Glass", "BasicMaterialsGroup" },
        { "EnameledGlass", false, "Split on Crafting Enameled Glass", "BasicMaterialsGroup" },
        { "Fiber", false, "Split on Crafting Fiber", "BasicMaterialsGroup" },
        { "FiberMesh", false, "Split on Crafting Fiber Mesh", "BasicMaterialsGroup" },
        { "Rubber", false, "Split on Crafting Rubber", "BasicMaterialsGroup" },
        { "Grease", false, "Split on Crafting Grease", "BasicMaterialsGroup" },

        // Electronics Grouping
        { "ElectronicsGroup", true, "Electronics", "ResourcesGroup" },
        // Electronics Individual Settings
        { "BasicBattery", false, "Split on Crafting Basic Battery", "ElectronicsGroup" },
        { "AdvancedBattery", false, "Split on Crafting Advanced Battery", "ElectronicsGroup" },
        { "CopperWire", false, "Split on Crafting Copper Wire", "ElectronicsGroup" },
        { "PowerCell", false, "Split on Crafting Power Cell", "ElectronicsGroup" },
        { "EntangledPowerCell", false, "Split on Crafting Entangled Power Cell", "ElectronicsGroup" },
        { "WiringKit", false, "Split on Crafting Wiring Kit", "ElectronicsGroup" },
        { "AdvancedWiringKit", false, "Split on Crafting Advanced Wiring Kit", "ElectronicsGroup" },
        { "SystemChip", false, "Split on Crafting System Chip", "ElectronicsGroup" },
        { "DedicatedCore", false, "Split on Crafting Dedicated Core", "ElectronicsGroup" },

        // Sustenance Grouping
        { "SustenanceGroup", true, "Sustenance", "FabricatorGroup" },

        // Prepared Meals Grouping
        { "PreparedMealsGroup", true, "Prepared Meals", "SustenanceGroup" },
        // Prepared Meals Individual Settings
        { "SugarofSaturn", false, "Split on Crafting Sugar of Saturn", "PreparedMealsGroup" },
        { "HalfmoonJerky", false, "Split on Crafting Halfmoon Jerky", "PreparedMealsGroup" },
        { "ThreemoonTemaki", false, "Split on Crafting Threemoon Temaki", "PreparedMealsGroup" },
        { "HoverthornSouvlaki", false, "Split on Crafting Hoverthorn Souvlaki", "PreparedMealsGroup" },
        { "CherimoyaChutney", false, "Split on Crafting Cherimoya Chutney", "PreparedMealsGroup" },
        { "Pavlova", false, "Split on Crafting Pavlova", "PreparedMealsGroup" },

        // Cooked Food Grouping
        { "CookedFoodGroup", true, "Cooked Food", "SustenanceGroup" },
        // Cooked Food Individual Settings
        { "CookedHalfmoon", false, "Split on Crafting Cooked Halfmoon", "CookedFoodGroup" },
        { "OilySalad", false, "Split on Crafting Oily Salad", "CookedFoodGroup" },
        { "CookedHarvestmoon", false, "Split on Crafting Cooked Harvestmoon", "CookedFoodGroup" },
        { "CookedBluemoon", false, "Split on Crafting Cooked Bluemoon", "CookedFoodGroup" },
        { "CookedQuadrate", false, "Split on Crafting Cooked Quadrate", "CookedFoodGroup" },
        { "CookedGeordie", false, "Split on Crafting Cooked Geordie", "CookedFoodGroup" },
        { "CookedElectricGeordie", false, "Split on Crafting Cooked Electric Geordie", "CookedFoodGroup" },
        { "CookedHoverthorn", false, "Split on Crafting Cooked Hoverthorn", "CookedFoodGroup" },
        { "CookedBlackHoverthorn", false, "Split on Crafting Cooked Black Hoverthorn", "CookedFoodGroup" },
        { "CookedPneuma", false, "Split on Crafting Cooked Pneuma", "CookedFoodGroup" },
        { "NutrientBlock", false, "Split on Crafting Nutrient Block", "CookedFoodGroup" },
        { "CoralMash", false, "Split on Crafting Coral Mash", "CookedFoodGroup" },

        // Water Grouping
        { "WaterGroup", true, "Water", "SustenanceGroup" },
        // Water Individual Settings
        { "IsotonicWater", false, "Split on Crafting Isotonic Water", "WaterGroup" },
        { "Water", false, "Split on Crafting Water", "WaterGroup" },

        // Consumables Grouping
        { "ConsumablesGroup", true, "Consumables", "FabricatorGroup" },

        // Consumables Grouping
        { "ConsumablesConsumablesGroup", true, "Consumables", "ConsumablesGroup" },
        // Consumables Individual Settings
        { "BasicFirstAidKit", false, "Split on Crafting Basic First Aid Kit", "ConsumablesConsumablesGroup" },
        { "EnhancedFirstAidKit", false, "Split on Crafting Enhanced First Aid Kit", "ConsumablesConsumablesGroup" },
        { "DistractionFlare", false, "Split on Crafting Distraction Flare", "ConsumablesConsumablesGroup" },

        // Modification Station Grouping
        { "ModificationStationGroup", true, "Modification Station", "CraftSplitsGrouping" },

        // Tadpole Upgrade Modules Grouping
        { "TadpoleUpgradeModulesGroup", true, "Tadpole Upgrade Modules", "ModificationStationGroup" },

        // Tadpole Upgrade Modules Grouping
        { "TadpoleUpgradeModulesTadpoleUpgradeModulesGroup", true, "Tadpole Upgrade Modules", "TadpoleUpgradeModulesGroup" },
        // Tadpole Upgrade Modules Individual Settings
        { "EngineEfficiency", false, "Split on Crafting Engine Efficiency", "TadpoleUpgradeModulesTadpoleUpgradeModulesGroup" },
        { "StrikeArmor", false, "Split on Crafting Strike Armor", "TadpoleUpgradeModulesTadpoleUpgradeModulesGroup" },
        { "CavitationMuffler", false, "Split on Crafting Cavitation Muffler", "TadpoleUpgradeModulesTadpoleUpgradeModulesGroup" },
        { "PhotovoltaicCharger", false, "Split on Crafting Photovoltaic Charger", "TadpoleUpgradeModulesTadpoleUpgradeModulesGroup" },
        { "TadpoleDepthModuleMk.1", false, "Split on Crafting Tadpole Depth Module Mk. 1", "TadpoleUpgradeModulesTadpoleUpgradeModulesGroup" },
        { "TadpoleDepthModuleMk.2", false, "Split on Crafting Tadpole Depth Module Mk. 2", "TadpoleUpgradeModulesTadpoleUpgradeModulesGroup" },

        // Prototype Tool Modifications Grouping
        { "PrototypeToolModificationsGroup", true, "Prototype Tool Modifications", "ModificationStationGroup" },

        // Prototype Tool Modifications Grouping
        { "PrototypeToolModificationsPrototypeToolModificationsGroup", true, "Prototype Tool Modifications", "PrototypeToolModificationsGroup" },
        // Prototype Tool Modifications Individual Settings
        { "Bioscanner", false, "Split on Crafting Bioscanner", "PrototypeToolModificationsPrototypeToolModificationsGroup" },
        { "FeedbackResonator", false, "Split on Crafting Feedback Resonator", "PrototypeToolModificationsPrototypeToolModificationsGroup" },

        // Vehicle Fabricator Grouping
        { "VehicleFabricatorGroup", true, "Vehicle Fabricator", "CraftSplitsGrouping" },

        // Vehicles Grouping
        { "VehiclesGroup", true, "Vehicles", "VehicleFabricatorGroup" },
        // Vehicles Individual Settings
        { "Tadpole", false, "Split on Crafting Tadpole", "VehiclesGroup" },
        { "ScoutRayChassis", false, "Split on Crafting Scout Ray Chassis", "VehiclesGroup" },
        { "TadpoleHaulChassis", false, "Split on Crafting Tadpole Haul Chassis", "VehiclesGroup" },

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
    //vars.Resolver.Watch<bool>("GSync", vars.Utils.GSync);
    
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
    // Old Crafting Splits
    // vars.Events.FunctionFlag("CraftHighCapacityTank", "BP_OxygenTank_Medium_C", "BP_OxygenTank_Medium_C", "BPOnEquipped");
    // vars.Events.FunctionFlag("CraftFeedbackResonator", "BP_SonicResonatorV2_C", "BP_SonicResonatorV2_C", "ItemPickedUp");
    // vars.Events.FunctionFlag("CraftBioscanner", "BP_ScannerV2_C", "BP_ScannerV2_C", "ReceiveBeginPlay");
    vars.Events.FunctionFlag("EndObservatoryButtonPress", "BP_Hologram_AxumFinale_Button_C", "BP_HologramButton_Axum_C_UAID_A036BC2B70CF8AA502", "ToggledOn");
    // vars.Events.FunctionFlag("CraftScannerSplit", "BP_Scanner_C", "BP_Scanner_C", "ReceiveBeginPlay");
    // vars.Events.FunctionFlag("CraftAirbladder", "BP_AirBladder_C", "BP_AirBladder_C", "ExecuteUbergraph_BP_AirBladder");

    // Load Removal Event Listeners
    vars.Events.FunctionFlag("IntroLifepodAscend", "BP_NarrativeSignal_C", "BP_NarrativeSignal_C_UAID_60CF846429E036A502", "OnUnlocked_62920D1448BD71509596E5B554437304");
    vars.Events.FunctionFlag("IntroCutsceneLoadRemovalEnd", "BP_LifepodManager_C", "BP_LifepodManager_C_UAID_047C166D6A3238B502", "OnSequenceEnd");
    //vars.Events.FunctionFlag("RespawnLoadRemovalStart", "WBP_RespawnScreen_C", "WBP_RespawnScreen_C", "BndEvt__WBP_RespawnScreen_BackButton_K2Node_ComponentBoundEvent_0_CommonButtonBaseClicked__DelegateSignature");
    //vars.Events.FunctionFlag("RespawnLoadRemovalStartEnd", "WBP_RespawnScreen_C", "WBP_RespawnScreen_C", "ExecuteUbergraph_WBP_RespawnScreen");

    // Miscellaneous Event Listeners
    vars.Events.FunctionFlag("FirstCraft", "ABP_Fabricator_C", "ABP_Fabricator_C2", "OnCraftingStarted_Event");
    vars.Events.FunctionFlag("FirstScan", "GA_Scan_C", "GA_Scan_C", "OnCompleted_D22E6C2C4F34F79DF063E88A2D0679BA");
    vars.Events.FunctionFlag("SonicResonatorBlastShot", "GA_SonicResonator_Blast_C", "GA_SonicResonator_Blast_C", "OnCompleted_B65B54F241049DF1F76DA59AAF9E5B09");
    vars.Events.FunctionFlag("InteractWithSingleBed", "BP_BedSingle_C", "BP_BedSingle_C", "AttachEvent");

    // Craft Splits Event Listeners
    // Fabricator > Personal > Equipment Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("Rebreather", "DA_Rebreather_Recipe");
    vars.UharaSN2.CraftRecipeFlag("BasicFins", "DA_FinsRecipe");
    vars.UharaSN2.CraftRecipeFlag("ImprovedFins", "DA_ImprovedFinsRecipe");
    vars.UharaSN2.CraftRecipeFlag("StandardAirTank", "DA_SmallAirTankRecipe");
    vars.UharaSN2.CraftRecipeFlag("HighCapacityAirTank", "DA_MediumAirTankRecipe");
    vars.UharaSN2.CraftRecipeFlag("UltraHighCapacityAirTank", "DA_LargeAirTankRecipe");
    // Fabricator > Personal > Tools Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("SurvivalMultitool", "DA_SurvivalMultiTool_Recipe");
    vars.UharaSN2.CraftRecipeFlag("Flashlight", "DA_FlashlightRecipe");
    vars.UharaSN2.CraftRecipeFlag("Scanner", "DA_ScannerRecipe");
    vars.UharaSN2.CraftRecipeFlag("HabitatBuilder", "DA_BuilderToolRecipe");
    vars.UharaSN2.CraftRecipeFlag("RepairTool", "DA_RepairToolRecipe");
    vars.UharaSN2.CraftRecipeFlag("SonicResonator", "DA_SonicResonatorRecipe");
    vars.UharaSN2.CraftRecipeFlag("Wakemaker", "DA_WakemakerRecipe");
    vars.UharaSN2.CraftRecipeFlag("Airbladder", "DA_AirBladderRecipe");
    // Fabricator > Resources > Basic Materials Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("MildAcid", "DA_MildAcid_Recipe");
    vars.UharaSN2.CraftRecipeFlag("SalvagedTitanium", "DA_MetalSalvageRecipe");
    vars.UharaSN2.CraftRecipeFlag("Glass", "DA_GlassRecipe");
    vars.UharaSN2.CraftRecipeFlag("EnameledGlass", "DA_EnameledGlassRecipe");
    vars.UharaSN2.CraftRecipeFlag("Fiber", "DA_FiberRecipe");
    vars.UharaSN2.CraftRecipeFlag("FiberMesh", "DA_FiberMeshRecipe");
    vars.UharaSN2.CraftRecipeFlag("Rubber", "DA_RubberRecipe");
    vars.UharaSN2.CraftRecipeFlag("Grease", "DA_GreaseRecipe");
    // Fabricator > Resources > Electronics Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("BasicBattery", "DA_BasicBatteryRecipe");
    vars.UharaSN2.CraftRecipeFlag("AdvancedBattery", "DA_BatteryV2Recipe");
    vars.UharaSN2.CraftRecipeFlag("CopperWire", "DA_CopperWireRecipe");
    vars.UharaSN2.CraftRecipeFlag("PowerCell", "DA_PowerCellRecipe");
    vars.UharaSN2.CraftRecipeFlag("EntangledPowerCell", "DA_PowerCellV2Recipe");
    vars.UharaSN2.CraftRecipeFlag("WiringKit", "DA_WiringKitRecipe");
    vars.UharaSN2.CraftRecipeFlag("AdvancedWiringKit", "DA_AdvancedWiringKitRecipe");
    vars.UharaSN2.CraftRecipeFlag("SystemChip", "DA_ComputerChipRecipe");
    vars.UharaSN2.CraftRecipeFlag("DedicatedCore", "DA_ComputerChipMk2Recipe");
    // Fabricator > Sustenance > Prepared Meals Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("SugarofSaturn", "DA_SugarAnalog_Recipe");
    vars.UharaSN2.CraftRecipeFlag("HalfmoonJerky", "DA_HalfmoonJerkyRecipe");
    vars.UharaSN2.CraftRecipeFlag("ThreemoonTemaki", "DA_ThreemoonTemakiRecipe");
    vars.UharaSN2.CraftRecipeFlag("HoverthornSouvlaki", "DA_HoverthornSouvlaki_Recipe");
    vars.UharaSN2.CraftRecipeFlag("CherimoyaChutney", "DA_CherimoyaChutney_Recipe");
    vars.UharaSN2.CraftRecipeFlag("Pavlova", "DA_Pavlova_Recipe");
    // Fabricator > Sustenance > Cooked Food Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("CookedHalfmoon", "DA_CookedHalfMoonRecipe");
    vars.UharaSN2.CraftRecipeFlag("OilySalad", "DA_OilySalad_Recipe");
    vars.UharaSN2.CraftRecipeFlag("CookedHarvestmoon", "DA_CookedHarvestMoonRecipe");
    vars.UharaSN2.CraftRecipeFlag("CookedBluemoon", "DA_CookedBlueMoonRecipe");
    vars.UharaSN2.CraftRecipeFlag("CookedQuadrate", "DA_CookedQuadrateRecipe");
    vars.UharaSN2.CraftRecipeFlag("CookedGeordie", "DA_CookedGeordieRecipe");
    vars.UharaSN2.CraftRecipeFlag("CookedElectricGeordie", "DA_CookedElectricGeordieRecipe");
    vars.UharaSN2.CraftRecipeFlag("CookedHoverthorn", "DA_CookedSpineyTail_Recipe");
    vars.UharaSN2.CraftRecipeFlag("CookedBlackHoverthorn", "DA_CookedSpineyTail_Variant01_Recipe");
    vars.UharaSN2.CraftRecipeFlag("CookedPneuma", "DA_CookedPneumoRecipe");
    vars.UharaSN2.CraftRecipeFlag("NutrientBlock", "DA_NutrientBlockRecipe");
    vars.UharaSN2.CraftRecipeFlag("CoralMash", "DA_CoralCookieRecipe");
    // Fabricator > Sustenance > Water Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("IsotonicWater", "DA_IsotonicDrinkRecipe");
    vars.UharaSN2.CraftRecipeFlag("Water", "DA_WaterRecipe");
    // Fabricator > Consumables > Consumables Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("BasicFirstAidKit", "DA_BasicFirstAidKitRecipe");
    vars.UharaSN2.CraftRecipeFlag("EnhancedFirstAidKit", "DA_FirstAidKit_Enhanced_Recipe");
    vars.UharaSN2.CraftRecipeFlag("DistractionFlare", "DA_FlareRecipe");
    // Modification Station > Tadpole Upgrade Modules > Tadpole Upgrade Modules Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("EngineEfficiency", "DA_Tadpole_EngineEfficiency_Recipe");
    vars.UharaSN2.CraftRecipeFlag("StrikeArmor", "DA_Tadpole_HullReinforcement_Recipe");
    vars.UharaSN2.CraftRecipeFlag("CavitationMuffler", "DA_Tadpole_HydraulicMuffler_Recipe");
    vars.UharaSN2.CraftRecipeFlag("PhotovoltaicCharger", "DA_Tadpole_PhotovoltaicCharger_Recipe");
    vars.UharaSN2.CraftRecipeFlag("TadpoleDepthModuleMk.1", "DA_Tadpole_CrushDepthUpgrade_01_Recipe");
    vars.UharaSN2.CraftRecipeFlag("TadpoleDepthModuleMk.2", "DA_Tadpole_CrushDepthUpgrade_02_Recipe");
    // Modification Station > Prototype Tool Modifications > Prototype Tool Modifications Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("Bioscanner", "DA_ScannerV2Recipe");
    vars.UharaSN2.CraftRecipeFlag("FeedbackResonator", "DA_SonicResonatorV2Recipe");
    // Vehicle Fabricator > Vehicles Craft Recipe Event Listeners
    vars.UharaSN2.CraftRecipeFlag("Tadpole", "DA_TadpoleRecipe");
    vars.UharaSN2.CraftRecipeFlag("ScoutRayChassis", "DA_Tadpole_ScoutRay_Chassis_Recipe");
    vars.UharaSN2.CraftRecipeFlag("TadpoleHaulChassis", "DA_Tadpole_HAUL_Chassis_Recipe");

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

    vars.UharaSN2.UnlockFlag("RosettaStoneUnlock", "DA_Rosetta_TranslationUnlocked_StoryGoal");

    vars.introCutsceneLoadRemovalActive = false;
    vars.creativeStartArmed = false;
    vars.hatchAfterTadpoleArmed = false;
    vars.hatchAfterHighCapacityTankArmed = false;
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
        vars.hatchAfterTadpoleArmed = false;
        vars.hatchAfterHighCapacityTankArmed = false;
        return true;
    }
    
    if (vars.Resolver.CheckFlag("CreativeStartArm"))
    {
        vars.introCutsceneLoadRemovalActive = false;
        vars.ResetCraftSplits();
        vars.hatchAfterTadpoleArmed = false;
        vars.hatchAfterHighCapacityTankArmed = false;

        if (settings["CreativeStartFirstInteractMovement"])
        {
            vars.creativeStartArmed = true;
        }
        else
        {
            vars.creativeStartArmed = false;
            return true;
        }
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
        vars.hatchAfterTadpoleArmed = false;
        vars.hatchAfterHighCapacityTankArmed = false;
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

    //if (settings["RespawnLoadRemoval"] && vars.Resolver.CheckFlag("RespawnLoadRemovalStart"))
    //    vars.introCutsceneLoadRemovalActive = true;

    //if (settings["RespawnLoadRemoval"] && vars.Resolver.CheckFlag("RespawnLoadRemovalStartEnd"))
    //    vars.introCutsceneLoadRemovalActive = false;

    if (vars.UharaSN2.CraftRecipeFlag("Tadpole"))
        vars.hatchAfterTadpoleArmed = true;

    if (vars.UharaSN2.CraftRecipeFlag("HighCapacityAirTank"))
        vars.hatchAfterHighCapacityTankArmed = true;
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
    if (vars.hatchAfterTadpoleArmed && vars.Resolver.CheckFlag("BuildHatch") && settings["BuildHatchAfterTadpole"] && vars.DoCraftSplit("BuildHatchAfterTadpole"))
    {
        vars.hatchAfterTadpoleArmed = false;
        return true;
    }
    if (vars.hatchAfterHighCapacityTankArmed && vars.Resolver.CheckFlag("BuildHatch") && settings["BuildHatchAfterHighCapacityTank"] && vars.DoCraftSplit("BuildHatchAfterHighCapacityTank"))
    {
        vars.hatchAfterHighCapacityTankArmed = false;
        return true;
    }

    // Miscellaneous Splits
    if (vars.Resolver.CheckFlag("SonicResonatorBlastShot") && settings["SonicResonatorBlastShot"]) return true;
    if (vars.Resolver.CheckFlag("InteractWithSingleBed") && settings["InteractWithSingleBed"]) return true;
    if (vars.Resolver.CheckFlag("FirstCraft") && settings["FirstCraft"] && vars.DoCraftSplit("FirstCraft")) return true;
    if (vars.Resolver.CheckFlag("FirstScan") && settings["FirstScan"] && vars.DoCraftSplit("FirstScan")) return true;

    // Craft Splits
    // Fabricator > Personal > Equipment Splits
    if (vars.UharaSN2.CraftRecipeFlag("Rebreather") && settings["Rebreather"] && vars.DoCraftSplit("Rebreather")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("BasicFins") && settings["BasicFins"] && vars.DoCraftSplit("BasicFins")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("ImprovedFins") && settings["ImprovedFins"] && vars.DoCraftSplit("ImprovedFins")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("StandardAirTank") && settings["StandardAirTank"] && vars.DoCraftSplit("StandardAirTank")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("HighCapacityAirTank") && settings["HighCapacityAirTank"] && vars.DoCraftSplit("HighCapacityAirTank")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("UltraHighCapacityAirTank") && settings["UltraHighCapacityAirTank"] && vars.DoCraftSplit("UltraHighCapacityAirTank")) return true;
    // Fabricator > Personal > Tools Splits
    if (vars.UharaSN2.CraftRecipeFlag("SurvivalMultitool") && settings["SurvivalMultitool"] && vars.DoCraftSplit("SurvivalMultitool")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("Flashlight") && settings["Flashlight"] && vars.DoCraftSplit("Flashlight")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("Scanner") && settings["Scanner"] && vars.DoCraftSplit("Scanner")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("HabitatBuilder") && settings["HabitatBuilder"] && vars.DoCraftSplit("HabitatBuilder")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("RepairTool") && settings["RepairTool"] && vars.DoCraftSplit("RepairTool")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("SonicResonator") && settings["SonicResonator"] && vars.DoCraftSplit("SonicResonator")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("Wakemaker") && settings["Wakemaker"] && vars.DoCraftSplit("Wakemaker")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("Airbladder") && settings["Airbladder"] && vars.DoCraftSplit("Airbladder")) return true;
    // Fabricator > Resources > Basic Materials Splits
    if (vars.UharaSN2.CraftRecipeFlag("MildAcid") && settings["MildAcid"] && vars.DoCraftSplit("MildAcid")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("SalvagedTitanium") && settings["SalvagedTitanium"] && vars.DoCraftSplit("SalvagedTitanium")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("Glass") && settings["Glass"] && vars.DoCraftSplit("Glass")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("EnameledGlass") && settings["EnameledGlass"] && vars.DoCraftSplit("EnameledGlass")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("Fiber") && settings["Fiber"] && vars.DoCraftSplit("Fiber")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("FiberMesh") && settings["FiberMesh"] && vars.DoCraftSplit("FiberMesh")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("Rubber") && settings["Rubber"] && vars.DoCraftSplit("Rubber")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("Grease") && settings["Grease"] && vars.DoCraftSplit("Grease")) return true;
    // Fabricator > Resources > Electronics Splits
    if (vars.UharaSN2.CraftRecipeFlag("BasicBattery") && settings["BasicBattery"] && vars.DoCraftSplit("BasicBattery")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("AdvancedBattery") && settings["AdvancedBattery"] && vars.DoCraftSplit("AdvancedBattery")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CopperWire") && settings["CopperWire"] && vars.DoCraftSplit("CopperWire")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("PowerCell") && settings["PowerCell"] && vars.DoCraftSplit("PowerCell")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("EntangledPowerCell") && settings["EntangledPowerCell"] && vars.DoCraftSplit("EntangledPowerCell")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("WiringKit") && settings["WiringKit"] && vars.DoCraftSplit("WiringKit")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("AdvancedWiringKit") && settings["AdvancedWiringKit"] && vars.DoCraftSplit("AdvancedWiringKit")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("SystemChip") && settings["SystemChip"] && vars.DoCraftSplit("SystemChip")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("DedicatedCore") && settings["DedicatedCore"] && vars.DoCraftSplit("DedicatedCore")) return true;
    // Fabricator > Sustenance > Prepared Meals Splits
    if (vars.UharaSN2.CraftRecipeFlag("SugarofSaturn") && settings["SugarofSaturn"] && vars.DoCraftSplit("SugarofSaturn")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("HalfmoonJerky") && settings["HalfmoonJerky"] && vars.DoCraftSplit("HalfmoonJerky")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("ThreemoonTemaki") && settings["ThreemoonTemaki"] && vars.DoCraftSplit("ThreemoonTemaki")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("HoverthornSouvlaki") && settings["HoverthornSouvlaki"] && vars.DoCraftSplit("HoverthornSouvlaki")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CherimoyaChutney") && settings["CherimoyaChutney"] && vars.DoCraftSplit("CherimoyaChutney")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("Pavlova") && settings["Pavlova"] && vars.DoCraftSplit("Pavlova")) return true;
    // Fabricator > Sustenance > Cooked Food Splits
    if (vars.UharaSN2.CraftRecipeFlag("CookedHalfmoon") && settings["CookedHalfmoon"] && vars.DoCraftSplit("CookedHalfmoon")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("OilySalad") && settings["OilySalad"] && vars.DoCraftSplit("OilySalad")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CookedHarvestmoon") && settings["CookedHarvestmoon"] && vars.DoCraftSplit("CookedHarvestmoon")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CookedBluemoon") && settings["CookedBluemoon"] && vars.DoCraftSplit("CookedBluemoon")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CookedQuadrate") && settings["CookedQuadrate"] && vars.DoCraftSplit("CookedQuadrate")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CookedGeordie") && settings["CookedGeordie"] && vars.DoCraftSplit("CookedGeordie")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CookedElectricGeordie") && settings["CookedElectricGeordie"] && vars.DoCraftSplit("CookedElectricGeordie")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CookedHoverthorn") && settings["CookedHoverthorn"] && vars.DoCraftSplit("CookedHoverthorn")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CookedBlackHoverthorn") && settings["CookedBlackHoverthorn"] && vars.DoCraftSplit("CookedBlackHoverthorn")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CookedPneuma") && settings["CookedPneuma"] && vars.DoCraftSplit("CookedPneuma")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("NutrientBlock") && settings["NutrientBlock"] && vars.DoCraftSplit("NutrientBlock")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CoralMash") && settings["CoralMash"] && vars.DoCraftSplit("CoralMash")) return true;
    // Fabricator > Sustenance > Water Splits
    if (vars.UharaSN2.CraftRecipeFlag("IsotonicWater") && settings["IsotonicWater"] && vars.DoCraftSplit("IsotonicWater")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("Water") && settings["Water"] && vars.DoCraftSplit("Water")) return true;
    // Fabricator > Consumables > Consumables Splits
    if (vars.UharaSN2.CraftRecipeFlag("BasicFirstAidKit") && settings["BasicFirstAidKit"] && vars.DoCraftSplit("BasicFirstAidKit")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("EnhancedFirstAidKit") && settings["EnhancedFirstAidKit"] && vars.DoCraftSplit("EnhancedFirstAidKit")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("DistractionFlare") && settings["DistractionFlare"] && vars.DoCraftSplit("DistractionFlare")) return true;
    // Modification Station > Tadpole Upgrade Modules > Tadpole Upgrade Modules Splits
    if (vars.UharaSN2.CraftRecipeFlag("EngineEfficiency") && settings["EngineEfficiency"] && vars.DoCraftSplit("EngineEfficiency")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("StrikeArmor") && settings["StrikeArmor"] && vars.DoCraftSplit("StrikeArmor")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("CavitationMuffler") && settings["CavitationMuffler"] && vars.DoCraftSplit("CavitationMuffler")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("PhotovoltaicCharger") && settings["PhotovoltaicCharger"] && vars.DoCraftSplit("PhotovoltaicCharger")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("TadpoleDepthModuleMk.1") && settings["TadpoleDepthModuleMk.1"] && vars.DoCraftSplit("TadpoleDepthModuleMk.1")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("TadpoleDepthModuleMk.2") && settings["TadpoleDepthModuleMk.2"] && vars.DoCraftSplit("TadpoleDepthModuleMk.2")) return true;
    // Modification Station > Prototype Tool Modifications > Prototype Tool Modifications Splits
    if (vars.UharaSN2.CraftRecipeFlag("Bioscanner") && settings["Bioscanner"] && vars.DoCraftSplit("Bioscanner")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("FeedbackResonator") && settings["FeedbackResonator"] && vars.DoCraftSplit("FeedbackResonator")) return true;
    // Vehicle Fabricator > Vehicles Splits
    if (vars.UharaSN2.CraftRecipeFlag("Tadpole") && settings["Tadpole"] && vars.DoCraftSplit("Tadpole")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("ScoutRayChassis") && settings["ScoutRayChassis"] && vars.DoCraftSplit("ScoutRayChassis")) return true;
    if (vars.UharaSN2.CraftRecipeFlag("TadpoleHaulChassis") && settings["TadpoleHaulChassis"] && vars.DoCraftSplit("TadpoleHaulChassis")) return true;

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

    // Other Splits
    if (vars.UharaSN2.UnlockFlag("RosettaStoneUnlock") && settings["RosettaStoneUnlock"] && vars.DoCraftSplit("RosettaStoneUnlock")) return true;

}
onStart
{
    if (vars.MissingUhara) return;

    vars.ResetCraftSplits();
    vars.introCutsceneLoadRemovalActive = false;
    vars.creativeStartArmed = false;
    vars.hatchAfterTadpoleArmed = false;
    vars.hatchAfterHighCapacityTankArmed = false;
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
        vars.hatchAfterTadpoleArmed = false;
        vars.hatchAfterHighCapacityTankArmed = false;
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
    vars.hatchAfterTadpoleArmed = false;
    vars.hatchAfterHighCapacityTankArmed = false;
}
// Listening to Update for load Removal
isLoading
{
    if (vars.MissingUhara) return false;

    return vars.introCutsceneLoadRemovalActive;
    // return vars.introCutsceneLoadRemovalActive || (settings["EnableGSyncLoadRemoval"] && current.GSync);
}
