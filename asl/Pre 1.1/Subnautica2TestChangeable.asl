state("Subnautica2-Win64-Shipping"){}
state("Subnautica2-WinGDK-Shipping"){}

startup
{
    vars.ScriptVersion = "v1.0.0-unlock-test";
    vars.MissingUhara = !File.Exists("Components/uharaSN2");
    if (vars.MissingUhara)
    {
        System.Windows.Forms.MessageBox.Show(
            "Missing required file: Components/uharaSN2,\n" +
            "Please place uharaSN2 in your LiveSplit Components folder.",
            "Subnautica 2 Unlock Test " + vars.ScriptVersion,
            System.Windows.Forms.MessageBoxButtons.OK,
            System.Windows.Forms.MessageBoxIcon.Error
        );
        return;
    }

    Assembly.Load(File.ReadAllBytes("Components/uharaSN2")).CreateInstance("Main");

    dynamic[,] _settings =
    {
        { "UnlockLoggingGroup", true, "Unlock Logging", null },
        { "LogBlueprintUnlocks", false, "Log Blueprint Unlocks", "UnlockLoggingGroup" },
        { "LogDatabankUnlocks", false, "Log Databank Unlocks", "UnlockLoggingGroup" },
        { "LogStoryUnlocks", false, "Log Other Story Unlocks", "UnlockLoggingGroup" },

        { "UnlockSplitGroup", true, "Unlock Split Testing", null },
        { "ExampleUnlockSplit", false, "Split on Example Unlock (edit target in script)", "UnlockSplitGroup" }
    };
    vars.Uhara.Settings.Create(_settings);

    vars.BlueprintUnlockLogPath = "Subnautica2.BlueprintUnlocks.discovered.txt";
    vars.DatabankUnlockLogPath = "Subnautica2.DatabankUnlocks.discovered.txt";
    vars.StoryUnlockLogPath = "Subnautica2.StoryUnlocks.discovered.txt";

    vars.SeenBlueprintUnlocks = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    vars.SeenDatabankUnlocks = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    vars.SeenStoryUnlocks = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

    try
    {
        if (File.Exists(vars.BlueprintUnlockLogPath))
        {
            foreach (string line in File.ReadAllLines(vars.BlueprintUnlockLogPath))
            {
                if (string.IsNullOrWhiteSpace(line)) continue;
                vars.SeenBlueprintUnlocks.Add(line.Trim());
            }
        }

        if (File.Exists(vars.DatabankUnlockLogPath))
        {
            foreach (string line in File.ReadAllLines(vars.DatabankUnlockLogPath))
            {
                if (string.IsNullOrWhiteSpace(line)) continue;
                vars.SeenDatabankUnlocks.Add(line.Trim());
            }
        }

        if (File.Exists(vars.StoryUnlockLogPath))
        {
            foreach (string line in File.ReadAllLines(vars.StoryUnlockLogPath))
            {
                if (string.IsNullOrWhiteSpace(line)) continue;
                vars.SeenStoryUnlocks.Add(line.Trim());
            }
        }
    }
    catch { }
}

init
{
    vars.UharaSN2.UnlockFlag("RosettaStoneUnlock", "DA_Rosetta_TranslationUnlocked_StoryGoal");
}

update
{
    vars.Uhara.Update();

    if (settings["LogBlueprintUnlocks"] && vars.UharaSN2.BlueprintUnlockEvent())
    {
        try
        {
            string joinedNames = vars.UharaSN2.CurrentBlueprintUnlockNames();
            if (!string.IsNullOrWhiteSpace(joinedNames))
            {
                foreach (string rawName in joinedNames.Split('|'))
                {
                    string name = rawName == null ? null : rawName.Trim();
                    if (string.IsNullOrWhiteSpace(name)) continue;
                    if (vars.SeenBlueprintUnlocks.Contains(name)) continue;

                    vars.SeenBlueprintUnlocks.Add(name);
                    File.AppendAllText(vars.BlueprintUnlockLogPath, name + Environment.NewLine);
                }
            }
        }
        catch { }
    }

    if (settings["LogDatabankUnlocks"] && vars.UharaSN2.DatabankUnlockEvent())
    {
        try
        {
            string joinedNames = vars.UharaSN2.CurrentDatabankUnlockNames();
            if (!string.IsNullOrWhiteSpace(joinedNames))
            {
                foreach (string rawName in joinedNames.Split('|'))
                {
                    string name = rawName == null ? null : rawName.Trim();
                    if (string.IsNullOrWhiteSpace(name)) continue;
                    if (vars.SeenDatabankUnlocks.Contains(name)) continue;

                    vars.SeenDatabankUnlocks.Add(name);
                    File.AppendAllText(vars.DatabankUnlockLogPath, name + Environment.NewLine);
                }
            }
        }
        catch { }
    }

    if (settings["LogStoryUnlocks"] && vars.UharaSN2.StoryUnlockEvent())
    {
        try
        {
            string joinedNames = vars.UharaSN2.CurrentStoryUnlockNames();
            if (!string.IsNullOrWhiteSpace(joinedNames))
            {
                foreach (string rawName in joinedNames.Split('|'))
                {
                    string name = rawName == null ? null : rawName.Trim();
                    if (string.IsNullOrWhiteSpace(name)) continue;
                    if (vars.SeenStoryUnlocks.Contains(name)) continue;

                    vars.SeenStoryUnlocks.Add(name);
                    File.AppendAllText(vars.StoryUnlockLogPath, name + Environment.NewLine);
                }
            }
        }
        catch { }
    }
}

split
{
    if (settings["ExampleUnlockSplit"] && vars.UharaSN2.UnlockFlag("ExampleUnlock")) return true;
    return false;
}

reset
{
    return false;
}
