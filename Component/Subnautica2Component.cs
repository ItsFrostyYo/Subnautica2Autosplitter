using System;
using System.Diagnostics;
using System.Windows.Forms;
using System.Xml;
using LiveSplit.Model;
using LiveSplit.Options;
using LiveSplit.UI;
using LiveSplit.UI.Components;

namespace LiveSplit.Subnautica2
{
    public sealed class Subnautica2Component : LogicComponent
    {
        private readonly LiveSplitState state;
        private readonly TimerModel timer;
        private readonly Subnautica2LogEngine engine;
        private readonly Subnautica2Settings settings;
        private bool gameTimeInitialized;
        private bool resetQueued;
        private bool hardAscendPauseActive;
        private bool hardAscendPauseConsumedThisRun;
        private int hardAscendForceUnpauseFramesRemaining;
        private long hardAscendPauseStartTicks;
        private long lastEngineTickTicks;
        private static readonly long HardAscendPauseDurationTicks =
            (long)(Stopwatch.Frequency * 85.0);
        private static readonly long EngineTickIntervalTicks =
            (long)(Stopwatch.Frequency * 0.03); // ~33 Hz log polling
        private const int HardAscendForceUnpauseFrames = 600;

        public Subnautica2Component(LiveSplitState state)
        {
            this.state = state;
            timer = new TimerModel { CurrentState = state };
            engine = new Subnautica2LogEngine();
            settings = new Subnautica2Settings(state);
            engine.ApplySettings(settings);

            this.state.OnStart += OnStart;
            this.state.OnReset += OnReset;
            EnsureGameTimeMode();
        }

        public override string ComponentName => "Subnautica 2 Autosplitter";

        public override Control GetSettingsControl(LayoutMode mode) => settings;

        public override XmlNode GetSettings(XmlDocument document) => settings.GetSettings(document);

        public override void SetSettings(XmlNode xml) => settings.SetSettings(xml);

        public override void Update(IInvalidator invalidator, LiveSplitState state, float width, float height, LayoutMode mode)
        {
            try
            {
                engine.ApplySettings(settings);
                long nowTicks = Stopwatch.GetTimestamp();
                if (nowTicks - lastEngineTickTicks >= EngineTickIntervalTicks)
                {
                    engine.Tick();
                    lastEngineTickTicks = nowTicks;
                }

                if (state.CurrentPhase == TimerPhase.Running
                    && !hardAscendPauseActive
                    && !hardAscendPauseConsumedThisRun
                    && engine.LifepodAscendTriggeredThisTick)
                {
                    hardAscendPauseActive = true;
                    hardAscendPauseStartTicks = Stopwatch.GetTimestamp();
                }

                if (state.CurrentPhase == TimerPhase.Running)
                {
                    state.IsGameTimePaused = Loading();
                    if (hardAscendForceUnpauseFramesRemaining > 0)
                    {
                        state.IsGameTimePaused = false;
                        hardAscendForceUnpauseFramesRemaining--;
                    }
                }
                else
                {
                    state.IsGameTimePaused = false;
                }

                if (state.CurrentSplitIndex >= 0)
                {
                    if (engine.MainMenuResetPending)
                        TryResetOnMainMenu();
                    else if (engine.TryConsumeSplit(state))
                        timer.Split();
                }

                if (state.CurrentSplitIndex < 0)
                {
                    if ((settings.SurvivalStart || settings.CreativeStart) && engine.ShouldStart())
                        timer.Start();
                }
            }
            catch
            {
                // Prevent repeated LiveSplit error popups from transient UI/runtime issues.
            }
        }

        public override void Dispose()
        {
            state.OnStart -= OnStart;
            state.OnReset -= OnReset;
        }

        private void OnStart(object sender, EventArgs e)
        {
            hardAscendForceUnpauseFramesRemaining = 0;
            lastEngineTickTicks = 0;
            state.IsGameTimePaused = Loading();
            state.SetGameTime(TimeSpan.Zero);
            engine.OnTimerStart();
        }

        private void OnReset(object sender, TimerPhase e)
        {
            resetQueued = false;
            hardAscendPauseActive = false;
            hardAscendPauseConsumedThisRun = false;
            hardAscendForceUnpauseFramesRemaining = 0;
            hardAscendPauseStartTicks = 0;
            lastEngineTickTicks = 0;
            state.IsGameTimePaused = false;
            engine.OnTimerReset();
        }

        private bool Loading()
        {
            bool pauseForAscend = false;
            if (hardAscendPauseActive)
            {
                long elapsedTicks = Stopwatch.GetTimestamp() - hardAscendPauseStartTicks;
                if (elapsedTicks >= HardAscendPauseDurationTicks)
                {
                    hardAscendPauseActive = false;
                    hardAscendPauseConsumedThisRun = true;
                    hardAscendForceUnpauseFramesRemaining = HardAscendForceUnpauseFrames;
                    hardAscendPauseStartTicks = 0;
                }
                else
                {
                    pauseForAscend = true;
                }
            }

            return pauseForAscend;
        }

        private void TryResetOnMainMenu()
        {
            if (resetQueued)
                return;

            engine.ClearResetPending();

            Form ui = state.Form;
            Action doReset = () =>
            {
                try
                {
                    bool goldSegment = false;
                    for (int i = 0; i < state.Run.Count; i++)
                    {
                        if (LiveSplitStateHelper.CheckBestSegment(state, i, state.CurrentTimingMethod))
                        {
                            goldSegment = true;
                            break;
                        }
                    }

                    bool save = true;
                    if (settings.AskForGoldSave && goldSegment)
                    {
                        DialogResult r = ui != null
                            ? MessageBox.Show(
                                ui,
                                "Save splits before resetting?",
                                "Reset",
                                MessageBoxButtons.YesNoCancel,
                                MessageBoxIcon.Question)
                            : MessageBox.Show(
                                "Save splits before resetting?",
                                "Reset",
                                MessageBoxButtons.YesNoCancel,
                                MessageBoxIcon.Question);

                        if (r == DialogResult.Cancel)
                            return;

                        save = r == DialogResult.Yes;
                    }

                    timer.Reset(save);
                }
                finally
                {
                    resetQueued = false;
                }
            };

            resetQueued = true;
            if (ui != null && ui.InvokeRequired)
                ui.BeginInvoke(doReset);
            else
                doReset();
        }

        private void EnsureGameTimeMode()
        {
            if (gameTimeInitialized)
                return;
            gameTimeInitialized = true;
            timer.InitializeGameTime();

            if (state.CurrentTimingMethod != TimingMethod.RealTime)
                return;

            var result = MessageBox.Show(
                "Subnautica 2 uses Game Time (with a fixed 85 second pause during lifepod ascend).\r\n\r\n"
                + "LiveSplit is currently comparing against Real Time.\r\n"
                + "Set the timing method to Game Time? (Recommended)",
                "Subnautica 2 Timing Method",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);

            if (result == DialogResult.Yes)
                state.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }
}
