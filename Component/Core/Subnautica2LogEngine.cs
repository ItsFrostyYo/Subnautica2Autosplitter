using System;
using System.IO;
using System.Text.RegularExpressions;
using LiveSplit.Model;

namespace LiveSplit.Subnautica2
{
    /// <summary>Log tail reader and event detection — port of Subnautica2.asl.</summary>
    public sealed class Subnautica2LogEngine
    {
        private readonly string logsDirectory;
        private readonly string defaultLogPath;
        private readonly Regex rxValidRuntimeLogName;
        private readonly Regex rxCraftSucceed;

        private string logPath;
        private long logPos;
        private int staleFrames;
        private long lineCounter;

        private bool startedThisAttempt;
        public bool IsInMainMenu { get; private set; } = true;
        private string mode = "Survival";
        private bool characterSelectOpen;

        private bool survivalStartPulse;
        private bool creativeStartPulse;
        private bool mainMenuQuitPulse;

        private bool lifepodAscendPulse;
        private bool pressureAdaptationPulse;
        private bool digestionAdaptationPulse;
        private bool heatAdaptationPulse;
        private bool axumVisionAdaptationPulse;
        private bool highCapacityO2TankPulse;
        private bool feedbackResonatorPulse;
        private bool bioscannerPulse;
        private bool habitatBuilderPulse;
        private bool translateMessagePulse;
        private bool thanksForPlayingPulse;

        private bool firedLifepodAscend;
        private bool firedPressureAdaptation;
        private bool firedDigestionAdaptation;
        private bool firedHeatAdaptation;
        private bool firedAxumVisionAdaptation;
        private bool firedHighCapacityO2Tank;
        private bool firedFeedbackResonator;
        private bool firedBioscanner;
        private bool firedHabitatBuilder;
        private bool firedTranslateMessage;
        private bool firedThanksForPlaying;
        private int orderedAutoProgress;

        private int armPressureLines;
        private int armThanksLines;
        private int translateStage;
        private int translateContextLines;
        private bool pendingStrongInteract;
        private long lastInteractLineCounter;
        private const int TranslateContextWindowLines = 12000;

        public bool MainMenuResetPending { get; private set; }

        public Subnautica2LogEngine()
        {
            logsDirectory = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "Subnautica2",
                "Saved",
                "Logs");
            defaultLogPath = Path.Combine(logsDirectory, "Subnautica2.log");
            rxValidRuntimeLogName = new Regex(
                @"^Subnautica2(?:_\d+)?\.log$",
                RegexOptions.Compiled | RegexOptions.IgnoreCase);
            rxCraftSucceed = new Regex(
                @"LogCrafting: Crafting recipe .*?/([^/\.]+)\.[^\s]+ succeeded",
                RegexOptions.Compiled);
            ResetLogPosition();
        }

        public void ApplySettings(Subnautica2Settings settings) => Settings = settings;

        public Subnautica2Settings Settings { get; private set; }

        public bool LifepodAscendTriggeredThisTick => lifepodAscendPulse;

        public void Tick()
        {
            ClearPulses();
            if (!File.Exists(logPath))
            {
                logPath = ResolveActiveLog();
                if (!File.Exists(logPath))
                    return;
                try { logPos = new FileInfo(logPath).Length; }
                catch { logPos = 0L; }
                return;
            }

            long len;
            try { len = new FileInfo(logPath).Length; }
            catch { return; }

            if (len < logPos)
                logPos = len;

            int linesRead = 0;
            try
            {
                using (var fs = new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                {
                    fs.Seek(logPos, SeekOrigin.Begin);
                    using (var sr = new StreamReader(fs))
                    {
                        string line;
                        while ((line = sr.ReadLine()) != null)
                        {
                            linesRead++;
                            lineCounter++;
                            HandleLine(line);
                        }
                    }
                    logPos = fs.Position;
                }
            }
            catch
            {
            }

            if (linesRead > 0)
                staleFrames = 0;
            else
            {
                staleFrames++;
                if (staleFrames > 15)
                {
                    staleFrames = 0;
                    string candidate = ResolveActiveLog();
                    if (!string.Equals(candidate, logPath, StringComparison.OrdinalIgnoreCase))
                    {
                        logPath = candidate;
                        try
                        {
                            logPos = File.Exists(logPath) ? new FileInfo(logPath).Length : 0L;
                        }
                        catch
                        {
                            logPos = 0L;
                        }
                    }
                }
            }

            if (Settings != null && Settings.ResetOnMainMenu && mainMenuQuitPulse)
                MainMenuResetPending = true;
        }

        public void ClearResetPending() => MainMenuResetPending = false;

        public bool ShouldStart()
        {
            if (startedThisAttempt || IsInMainMenu)
                return false;

            if (Settings != null && Settings.SurvivalStart && mode != "Creative" && survivalStartPulse)
            {
                startedThisAttempt = true;
                return true;
            }

            if (Settings != null && Settings.CreativeStart && mode == "Creative" && creativeStartPulse)
            {
                startedThisAttempt = true;
                return true;
            }

            return false;
        }

        public bool TryConsumeSplit(LiveSplitState runState)
        {
            if (Settings == null)
                return false;

            if (Settings.OrderedAutoSplits)
                return TryConsumeOrderedAutoSplit();

            if (Settings.OrderedLiveSplit && runState != null)
            {
                int idx = runState.CurrentSplitIndex;
                if (idx < 0 || idx >= Settings.OrderedSplits.Count)
                    return false;
                var expected = Settings.OrderedSplits[idx];
                return TryFireSplit(expected);
            }

            foreach (var id in Settings.OrderedSplits)
            {
                if (TryFireSplit(id))
                    return true;
            }
            return false;
        }

        private bool TryConsumeOrderedAutoSplit()
        {
            if (Settings == null)
                return false;

            var splits = Settings.OrderedSplits;
            if (splits.Count == 0)
                return false;

            if (orderedAutoProgress < 0)
                orderedAutoProgress = 0;
            if (orderedAutoProgress >= splits.Count)
                return false;

            var expected = splits[orderedAutoProgress];
            if (!TryFireSplit(expected))
                return false;

            orderedAutoProgress++;
            return true;
        }

        private bool TryFireSplit(LogSplitId id)
        {
            if (!HasPulse(id) || HasFired(id))
                return false;
            MarkFired(id);
            return true;
        }

        private bool HasPulse(LogSplitId id)
        {
            switch (id)
            {
                case LogSplitId.LifepodAscend: return lifepodAscendPulse;
                case LogSplitId.PressureAdaptation: return pressureAdaptationPulse;
                case LogSplitId.DigestionAdaptation: return digestionAdaptationPulse;
                case LogSplitId.HeatAdaptation: return heatAdaptationPulse;
                case LogSplitId.AxumVisionAdaptation: return axumVisionAdaptationPulse;
                case LogSplitId.HighCapacityO2Tank: return highCapacityO2TankPulse;
                case LogSplitId.FeedbackResonator: return feedbackResonatorPulse;
                case LogSplitId.Bioscanner: return bioscannerPulse;
                case LogSplitId.HabitatBuilder: return habitatBuilderPulse;
                case LogSplitId.TranslateMessage: return translateMessagePulse;
                case LogSplitId.ThanksForPlaying: return thanksForPlayingPulse;
                default: return false;
            }
        }

        private bool HasFired(LogSplitId id)
        {
            switch (id)
            {
                case LogSplitId.LifepodAscend: return firedLifepodAscend;
                case LogSplitId.PressureAdaptation: return firedPressureAdaptation;
                case LogSplitId.DigestionAdaptation: return firedDigestionAdaptation;
                case LogSplitId.HeatAdaptation: return firedHeatAdaptation;
                case LogSplitId.AxumVisionAdaptation: return firedAxumVisionAdaptation;
                case LogSplitId.HighCapacityO2Tank: return firedHighCapacityO2Tank;
                case LogSplitId.FeedbackResonator: return firedFeedbackResonator;
                case LogSplitId.Bioscanner: return firedBioscanner;
                case LogSplitId.HabitatBuilder: return firedHabitatBuilder;
                case LogSplitId.TranslateMessage: return firedTranslateMessage;
                case LogSplitId.ThanksForPlaying: return firedThanksForPlaying;
                default: return true;
            }
        }

        private void MarkFired(LogSplitId id)
        {
            switch (id)
            {
                case LogSplitId.LifepodAscend: firedLifepodAscend = true; break;
                case LogSplitId.PressureAdaptation: firedPressureAdaptation = true; break;
                case LogSplitId.DigestionAdaptation: firedDigestionAdaptation = true; break;
                case LogSplitId.HeatAdaptation: firedHeatAdaptation = true; break;
                case LogSplitId.AxumVisionAdaptation: firedAxumVisionAdaptation = true; break;
                case LogSplitId.HighCapacityO2Tank: firedHighCapacityO2Tank = true; break;
                case LogSplitId.FeedbackResonator: firedFeedbackResonator = true; break;
                case LogSplitId.Bioscanner: firedBioscanner = true; break;
                case LogSplitId.HabitatBuilder: firedHabitatBuilder = true; break;
                case LogSplitId.TranslateMessage: firedTranslateMessage = true; break;
                case LogSplitId.ThanksForPlaying: firedThanksForPlaying = true; break;
            }
        }

        public void OnTimerStart()
        {
            startedThisAttempt = true;
            ClearSplitFlags();
        }

        public void OnTimerReset()
        {
            startedThisAttempt = false;
            ClearSplitFlags();
            MainMenuResetPending = false;
            pendingStrongInteract = false;
            armPressureLines = 0;
            armThanksLines = 0;
            translateStage = 0;
            translateContextLines = 0;
            ResetLogPosition();
        }

        private void ClearPulses()
        {
            survivalStartPulse = false;
            creativeStartPulse = false;
            mainMenuQuitPulse = false;
            lifepodAscendPulse = false;
            pressureAdaptationPulse = false;
            digestionAdaptationPulse = false;
            heatAdaptationPulse = false;
            axumVisionAdaptationPulse = false;
            highCapacityO2TankPulse = false;
            feedbackResonatorPulse = false;
            bioscannerPulse = false;
            habitatBuilderPulse = false;
            translateMessagePulse = false;
            thanksForPlayingPulse = false;
        }

        private void ClearSplitFlags()
        {
            firedLifepodAscend = false;
            firedPressureAdaptation = false;
            firedDigestionAdaptation = false;
            firedHeatAdaptation = false;
            firedAxumVisionAdaptation = false;
            firedHighCapacityO2Tank = false;
            firedFeedbackResonator = false;
            firedBioscanner = false;
            firedHabitatBuilder = false;
            firedTranslateMessage = false;
            firedThanksForPlaying = false;
            translateStage = 0;
            translateContextLines = 0;
            armThanksLines = 0;
            orderedAutoProgress = 0;
        }

        private void ResetLogPosition()
        {
            logPath = ResolveActiveLog();
            logPos = 0L;
            staleFrames = 0;
            lineCounter = 0L;
            try
            {
                if (File.Exists(logPath))
                {
                    logPos = new FileInfo(logPath).Length;
                    InferStateFromLogTail();
                }
            }
            catch
            {
                logPos = 0L;
            }
        }

        private void InferStateFromLogTail()
        {
            try
            {
                using (var fs = new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                {
                    long start = fs.Length > 131072 ? fs.Length - 131072 : 0L;
                    fs.Seek(start, SeekOrigin.Begin);
                    using (var sr = new StreamReader(fs))
                    {
                        string line;
                        while ((line = sr.ReadLine()) != null)
                        {
                            if (line.IndexOf("Browse Started Browse:", StringComparison.OrdinalIgnoreCase) >= 0
                                && line.IndexOf("/Game/Maps/L_ClientLobby", StringComparison.OrdinalIgnoreCase) >= 0)
                            {
                                IsInMainMenu = true;
                                mode = "Survival";
                            }
                            else if (line.IndexOf("Browse Started Browse:", StringComparison.OrdinalIgnoreCase) >= 0
                                     && line.IndexOf("/Game/Maps/Main/L_Main", StringComparison.OrdinalIgnoreCase) >= 0)
                            {
                                IsInMainMenu = false;
                                mode = line.IndexOf("game=Creative", StringComparison.OrdinalIgnoreCase) >= 0
                                    ? "Creative"
                                    : "Survival";
                            }
                        }
                    }
                }
            }
            catch
            {
            }
        }

        private string ResolveActiveLog()
        {
            try
            {
                if (!Directory.Exists(logsDirectory))
                    return defaultLogPath;

                FileInfo best = null;
                foreach (var f in new DirectoryInfo(logsDirectory).GetFiles("Subnautica2*.log"))
                {
                    if (!rxValidRuntimeLogName.IsMatch(f.Name))
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
            return defaultLogPath;
        }

        private static string Normalize(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return string.Empty;
            string x = value.Trim();
            x = x.Replace(" ", "").Replace("_", "").Replace("-", "")
                .Replace("/", "").Replace(".", "").Replace(":", "");
            return x.ToLowerInvariant();
        }

        private static bool IsInteractPress(string line)
        {
            return line.IndexOf("AbilityInput: InputPressed IA_Interact", StringComparison.OrdinalIgnoreCase) >= 0
                || line.IndexOf("AbilityInput: AbilityPressed GA_Interact", StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private void HandleLine(string line)
        {
            if (armPressureLines > 0) armPressureLines--;
            if (armThanksLines > 0) armThanksLines--;
            if (translateContextLines > 0) translateContextLines--;

            if (pendingStrongInteract && (lineCounter - lastInteractLineCounter > 8))
                pendingStrongInteract = false;

            if (line.IndexOf("Browse Started Browse:", StringComparison.OrdinalIgnoreCase) >= 0
                && line.IndexOf("/Game/Maps/L_ClientLobby", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                IsInMainMenu = true;
                characterSelectOpen = false;
                mode = "Survival";
                pendingStrongInteract = false;
                armPressureLines = 0;
                armThanksLines = 0;
                translateStage = 0;
                translateContextLines = 0;
                if (line.IndexOf("MenuReturnReason=Quit", StringComparison.OrdinalIgnoreCase) >= 0)
                    mainMenuQuitPulse = true;
            }

            if (line.IndexOf("Browse Started Browse:", StringComparison.OrdinalIgnoreCase) >= 0
                && line.IndexOf("/Game/Maps/Main/L_Main", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                IsInMainMenu = false;
                mode = "Survival";
                translateStage = 0;
                translateContextLines = 0;
                if (line.IndexOf("game=Creative", StringComparison.OrdinalIgnoreCase) >= 0)
                    mode = "Creative";
            }

            if (line.IndexOf("PushToLayer: Layer 5 Widget WBP_CharacterSelectScreen", StringComparison.OrdinalIgnoreCase) >= 0)
                characterSelectOpen = true;

            if (line.IndexOf("Pop: Layer 5 Widget WBP_CharacterSelectScreen", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                if (characterSelectOpen)
                    creativeStartPulse = true;
                characterSelectOpen = false;
            }

            if (line.IndexOf("UUWEFirstPersonCamera::EndCinematicLocation", StringComparison.OrdinalIgnoreCase) >= 0)
                survivalStartPulse = true;

            if (line.IndexOf("LogUWEGameplay: Adding global tag Gamestate.LifepodAscending", StringComparison.OrdinalIgnoreCase) >= 0
                || line.IndexOf("DA_Player_Ch1_LifepodRide1_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                lifepodAscendPulse = true;
            }

            if (line.IndexOf("DA_Storygoal_Player_Ch1_AdaptationTutorial2", StringComparison.OrdinalIgnoreCase) >= 0)
                armPressureLines = 220;

            if (IsInteractPress(line))
            {
                lastInteractLineCounter = lineCounter;
                pendingStrongInteract = true;
            }

            if (line.IndexOf("RemoveCurrentMappingContext: IMC_PlayerCharacter", StringComparison.OrdinalIgnoreCase) >= 0
                && pendingStrongInteract
                && (lineCounter - lastInteractLineCounter <= 8))
            {
                pendingStrongInteract = false;
                if (armPressureLines > 0)
                {
                    pressureAdaptationPulse = true;
                    armPressureLines = 0;
                }
            }

            if (line.IndexOf("DA_Storygoal_Player_Ch1_AdaptationTutorial_Interact", StringComparison.OrdinalIgnoreCase) >= 0
                && !firedPressureAdaptation)
            {
                pressureAdaptationPulse = true;
            }

            if (line.IndexOf("DA_Adaptation_Digestion_Acquired_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0
                || line.IndexOf("DA_Adaptation_Digestive_Acquired_1_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                digestionAdaptationPulse = true;
            }

            if (line.IndexOf("DA_Adaptation_HeatResistance_Acquired_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0)
                heatAdaptationPulse = true;

            if (line.IndexOf("DA_Adaptation_AxumGlyphs_Acquired_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0
                || line.IndexOf("DA_Ruins_AxumGlyph_DB_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                axumVisionAdaptationPulse = true;
            }

            if (line.IndexOf("DA_Observatory2_Enter_StoryGoal", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                translateStage = 1;
                translateContextLines = TranslateContextWindowLines;
            }

            if (line.IndexOf("voiceover_PDA_2D/Observatory2_Enter", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                translateStage = 1;
                translateContextLines = TranslateContextWindowLines;
            }

            if ((translateStage >= 1 || translateContextLines > 0)
                && line.IndexOf("AbilityInput: AbilityPressed GA_Interact", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                translateMessagePulse = true;
                translateStage = 2;
                translateContextLines = 0;
            }

            if ((translateStage >= 1 || translateContextLines > 0)
                && line.IndexOf("voiceover_PDA_2D/ClimateLab_Message_Line1", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                translateMessagePulse = true;
                translateStage = 2;
                translateContextLines = 0;
            }

            if (translateStage == 2
                && line.IndexOf("voiceover_PDA_2D/ClimateLab_AnalyzingMessage_Line3", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                armThanksLines = 5000;
            }

            if (translateStage == 2
                && armThanksLines > 0
                && line.IndexOf("LogUIActionRouter: Display: Applying input config for leaf-most node [WBP_PlayerModalMessage_C_", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                thanksForPlayingPulse = true;
                armThanksLines = 0;
            }

            var mc = rxCraftSucceed.Match(line);
            if (!mc.Success)
                return;

            string recipe = Normalize(mc.Groups[1].Value);
            if (recipe == Normalize("DA_MediumAirTankRecipe"))
                highCapacityO2TankPulse = true;
            else if (recipe == Normalize("DA_SonicResonatorV2Recipe"))
                feedbackResonatorPulse = true;
            else if (recipe == Normalize("DA_ScannerV2Recipe"))
                bioscannerPulse = true;
            else if (recipe == Normalize("DA_BuilderToolRecipe"))
                habitatBuilderPulse = true;
        }
    }
}
