using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using System.Xml;
using LiveSplit.Model;

namespace LiveSplit.Subnautica2
{
    public partial class Subnautica2Settings : UserControl
    {
        private readonly LiveSplitState liveSplitState;
        private bool isLoading;
        private LogSplitRowControl dragItem;
        private int dragTargetIndex = -1;
        private int insertMarkerY = -1;
        private Control insertBeforeControl;
        private Control highlightControl;
        private bool applyingLayout;

        public bool SurvivalStart { get; private set; } = true;
        public bool CreativeStart { get; private set; }
        public bool ResetOnMainMenu { get; private set; } = true;
        public bool AskForGoldSave { get; private set; }
        public bool OrderedLiveSplit { get; private set; } = true;
        public bool OrderedAutoSplits { get; private set; }
        public IReadOnlyList<LogSplitId> OrderedSplits
        {
            get
            {
                var list = new List<LogSplitId>();
                foreach (var row in GetSplitRows())
                {
                    if (row.TryGetSplitId(out var id))
                        list.Add(id);
                }
                return list;
            }
        }

        public Subnautica2Settings(LiveSplitState state)
        {
            liveSplitState = state;
            InitializeComponent();
            WireOptionHandlers();
            ApplyDynamicLayout();
        }

        private void WireOptionHandlers()
        {
            chkIntroStart.CheckedChanged += (s, e) => SyncOptionsFromUi();
            chkCreativeStart.CheckedChanged += (s, e) => SyncOptionsFromUi();
            chkReset.CheckedChanged += (s, e) => SyncOptionsFromUi();
            chkAskForGoldSave.CheckedChanged += (s, e) => SyncOptionsFromUi();
        }

        public Subnautica2Settings() : this(null)
        {
        }

        public bool IsSplitConfigured(LogSplitId id) => OrderedSplits.Contains(id);

        private IEnumerable<LogSplitRowControl> GetSplitRows() =>
            flowMain.Controls.OfType<LogSplitRowControl>();

        private int GetMinSplitIndex()
        {
            int optionsIndex = flowMain.Controls.IndexOf(flowOptions);
            if (optionsIndex < 0)
                optionsIndex = 0;
            return optionsIndex + 1;
        }

        private void btnAddSplit_Click(object sender, EventArgs e)
        {
            // Crafts are intentionally repeatable; all other split types are one-time.
            var used = new HashSet<LogSplitId>(
                OrderedSplits.Where(id => LogSplitCatalog.GetCategory(id) != LogSplitCategory.Crafts));

            using (var dialog = new SelectLogSplitForm(used))
            {
                if (dialog.ShowDialog(FindForm()) != DialogResult.OK)
                    return;
                AddSplitRow(dialog.SelectedSplit);
                ApplyDynamicLayout();
            }
        }

        private LogSplitRowControl AddSplitRow(LogSplitId id)
        {
            var row = new LogSplitRowControl();
            row.SetSplitId(id);
            row.BtnRemove.Click += (s, ev) =>
            {
                flowMain.Controls.Remove(row);
                row.Dispose();
                ApplyDynamicLayout();
            };
            flowMain.Controls.Add(row);
            return row;
        }

        private void ClearSplitRows()
        {
            for (int i = flowMain.Controls.Count - 1; i > 0; i--)
            {
                if (flowMain.Controls[i] is LogSplitRowControl row)
                {
                    flowMain.Controls.RemoveAt(i);
                    row.Dispose();
                }
            }
        }

        private void EnsureOptionsPinned()
        {
            int idx = flowMain.Controls.IndexOf(flowOptions);
            if (idx > 0)
                flowMain.Controls.SetChildIndex(flowOptions, 0);
        }

        private void ApplySplitRowWidths()
        {
            if (flowMain == null)
                return;

            int target = btnAddSplit?.Width > 0 ? btnAddSplit.Width : Options_GroupBox.Width - 12;
            foreach (var row in GetSplitRows())
                row.ApplyWidth(target);
        }

        private void ApplyDynamicLayout()
        {
            if (applyingLayout || flowMain == null || flowOptions == null || Options_GroupBox == null)
                return;
            if (IsDisposed || Disposing)
                return;

            try
            {
                applyingLayout = true;
                // Keep exact legacy sizing like the reference project so the layout is stable.
                flowOptions.Width = 472;
                Options_GroupBox.Width = 466;
                flowOptions.Height = Options_GroupBox.Height + 6;

                ApplyLegacyLayout();
                ApplySplitRowWidths();
            }
            finally
            {
                applyingLayout = false;
            }
        }

        private void cbOrderedLiveSplit_CheckedChanged(object sender, EventArgs e)
        {
            if (isLoading)
                return;
            if (cbOrderedLiveSplit.Checked && cbOrderedAutoSplits.Checked)
                cbOrderedAutoSplits.Checked = false;
            SyncOptionsFromUi();
        }

        private void cbOrderedAutoSplits_CheckedChanged(object sender, EventArgs e)
        {
            if (isLoading)
                return;
            if (cbOrderedAutoSplits.Checked && cbOrderedLiveSplit.Checked)
                cbOrderedLiveSplit.Checked = false;
            SyncOptionsFromUi();
        }

        private void SyncOptionsFromUi()
        {
            SurvivalStart = chkIntroStart.Checked;
            CreativeStart = chkCreativeStart.Checked;
            ResetOnMainMenu = chkReset.Checked;
            AskForGoldSave = chkAskForGoldSave.Checked;
            OrderedLiveSplit = cbOrderedLiveSplit.Checked;
            OrderedAutoSplits = cbOrderedAutoSplits.Checked;
        }

        #region Drag reorder (ported from legacy Subnautica2BaseSettings)

        private void flowMain_DragEnter(object sender, DragEventArgs e)
        {
            dragItem = GetDraggedRow(e);
            if (dragItem != null)
            {
                e.Effect = DragDropEffects.Move;
                insertMarkerY = -1;
                flowMain.Invalidate();
            }
            else
            {
                e.Effect = DragDropEffects.None;
            }
        }

        private void flowMain_DragOver(object sender, DragEventArgs e)
        {
            if (dragItem == null)
            {
                e.Effect = DragDropEffects.None;
                return;
            }

            e.Effect = DragDropEffects.Move;
            var panel = flowMain;
            Point clientPoint = panel.PointToClient(new Point(e.X, e.Y));

            int minIndex = GetMinSplitIndex();
            int targetIndex = minIndex;
            Control insertBefore = null;

            for (int i = minIndex; i < panel.Controls.Count; i++)
            {
                var c = panel.Controls[i];
                if (c == dragItem)
                    continue;

                int midY = c.Top + c.Height / 2;
                if (clientPoint.Y < midY)
                {
                    targetIndex = i;
                    insertBefore = c;
                    break;
                }
                targetIndex = i + 1;
            }

            if (targetIndex < minIndex)
                targetIndex = minIndex;

            dragTargetIndex = targetIndex;
            insertBeforeControl = insertBefore;

            Control newHighlight = insertBeforeControl as LogSplitRowControl;
            if (highlightControl != newHighlight)
            {
                if (highlightControl is LogSplitRowControl old)
                    old.BackColor = SystemColors.Control;
                highlightControl = newHighlight;
                if (highlightControl is LogSplitRowControl neu)
                    neu.BackColor = Color.FromArgb(230, 240, 255);
            }

            if (insertBeforeControl != null)
                insertMarkerY = insertBeforeControl.Top;
            else if (panel.Controls.Count > minIndex)
                insertMarkerY = panel.Controls[panel.Controls.Count - 1].Bottom;
            else
                insertMarkerY = -1;

            panel.Invalidate();
        }

        private void flowMain_DragDrop(object sender, DragEventArgs e)
        {
            if (dragItem == null || dragTargetIndex <= 0)
                return;

            flowMain.SuspendLayout();
            int minIndex = GetMinSplitIndex();
            int index = dragTargetIndex;
            if (index < minIndex)
                index = minIndex;

            int oldIndex = flowMain.Controls.IndexOf(dragItem);
            if (oldIndex >= 0 && index > oldIndex)
                index--;

            if (index >= flowMain.Controls.Count)
                index = flowMain.Controls.Count - 1;

            flowMain.Controls.SetChildIndex(dragItem, index);
            EnsureOptionsPinned();
            flowMain.ResumeLayout();

            dragItem = null;
            dragTargetIndex = -1;
            insertMarkerY = -1;
            insertBeforeControl = null;
            if (highlightControl is LogSplitRowControl h)
                h.BackColor = SystemColors.Control;
            highlightControl = null;
            flowMain.Invalidate();
        }

        private void flowMain_DragLeave(object sender, EventArgs e)
        {
            dragItem = null;
            dragTargetIndex = -1;
            insertMarkerY = -1;
            insertBeforeControl = null;
            if (highlightControl is LogSplitRowControl h)
                h.BackColor = SystemColors.Control;
            highlightControl = null;
            flowMain.Invalidate();
        }

        private void flowMain_Paint(object sender, PaintEventArgs e)
        {
            if (insertMarkerY < 0)
                return;
            using (var pen = new Pen(Color.DodgerBlue, 3))
            {
                int margin = 4;
                e.Graphics.DrawLine(pen, margin, insertMarkerY, flowMain.ClientSize.Width - margin, insertMarkerY);
            }
        }

        private static LogSplitRowControl GetDraggedRow(DragEventArgs e)
        {
            if (e.Data.GetDataPresent(typeof(LogSplitRowControl)))
                return (LogSplitRowControl)e.Data.GetData(typeof(LogSplitRowControl));
            return null;
        }

        #endregion

        public XmlNode GetSettings(XmlDocument document)
        {
            SyncOptionsFromUi();
            var root = document.CreateElement("Settings");

            AddBool(document, root, "IntroStart", SurvivalStart);
            AddBool(document, root, "CreativeStart", CreativeStart);
            AddBool(document, root, "Reset", ResetOnMainMenu);
            AddBool(document, root, "AskForGoldSave", AskForGoldSave);
            AddBool(document, root, "OrderedLiveSplit", OrderedLiveSplit);
            AddBool(document, root, "OrderedAutoSplits", OrderedAutoSplits);

            AddBool(document, root, "survival_start", SurvivalStart);
            AddBool(document, root, "creative_start", CreativeStart);
            AddBool(document, root, "reset_on_main_menu", ResetOnMainMenu);

            var splitsNode = document.CreateElement("Splits");
            foreach (var id in OrderedSplits)
            {
                var split = document.CreateElement("Split");
                split.SetAttribute("Id", id.ToString());
                split.SetAttribute("Category", LogSplitCatalog.GetCategory(id).ToString());
                splitsNode.AppendChild(split);
            }
            root.AppendChild(splitsNode);

            return root;
        }

        public void SetSettings(XmlNode settings)
        {
            if (settings == null)
                return;

            isLoading = true;
            try
            {
                SuspendLayout();
                flowMain.SuspendLayout();
                SurvivalStart = ReadBool(settings, "IntroStart", ReadBool(settings, "survival_start", true));
                CreativeStart = ReadBool(settings, "CreativeStart", ReadBool(settings, "creative_start", false));
                ResetOnMainMenu = ReadBool(settings, "Reset", ReadBool(settings, "reset_on_main_menu", true));
                AskForGoldSave = ReadBool(settings, "AskForGoldSave", false);
                OrderedLiveSplit = ReadBool(settings, "OrderedLiveSplit", true);
                OrderedAutoSplits = ReadBool(settings, "OrderedAutoSplits", false);

                chkIntroStart.Checked = SurvivalStart;
                chkCreativeStart.Checked = CreativeStart;
                chkReset.Checked = ResetOnMainMenu;
                chkAskForGoldSave.Checked = AskForGoldSave;
                cbOrderedLiveSplit.Checked = OrderedLiveSplit;
                cbOrderedAutoSplits.Checked = OrderedAutoSplits;

                ClearSplitRows();
                var splitNodes = settings.SelectNodes("Splits/Split");
                if (splitNodes != null && splitNodes.Count > 0)
                {
                    foreach (XmlNode node in splitNodes)
                    {
                        if (Enum.TryParse(node.Attributes?["Id"]?.Value, true, out LogSplitId id))
                            AddSplitRow(id);
                    }
                }
                else
                {
                    ImportLegacyAslSplitFlags(settings);
                }

                EnsureOptionsPinned();
                ApplyDynamicLayout();
            }
            finally
            {
                flowMain.ResumeLayout();
                ResumeLayout();
                isLoading = false;
                SyncOptionsFromUi();
            }
        }

        private void ImportLegacyAslSplitFlags(XmlNode settings)
        {
            // Same order as ASL groups: Adaptations, Crafts, End Game Triggers, Other
            TryAddLegacySplit(settings, "split_pressure_adaptation", LogSplitId.PressureAdaptation);
            TryAddLegacySplit(settings, "split_digestions_adaptation", LogSplitId.DigestionAdaptation);
            TryAddLegacySplit(settings, "split_heat_adaptation", LogSplitId.HeatAdaptation);
            TryAddLegacySplit(settings, "split_axum_vision_adaptation", LogSplitId.AxumVisionAdaptation);
            TryAddLegacySplit(settings, "split_high_capacity_o2_tank", LogSplitId.HighCapacityO2Tank);
            TryAddLegacySplit(settings, "split_feedback_resonator", LogSplitId.FeedbackResonator);
            TryAddLegacySplit(settings, "split_bioscanner", LogSplitId.Bioscanner);
            TryAddLegacySplit(settings, "split_habitat_builder", LogSplitId.HabitatBuilder);
            TryAddLegacySplit(settings, "split_translate_message", LogSplitId.TranslateMessage);
            TryAddLegacySplit(settings, "split_thanks_for_playing", LogSplitId.ThanksForPlaying);
            TryAddLegacySplit(settings, "split_lifepod_ascend", LogSplitId.LifepodAscend);
        }

        private void TryAddLegacySplit(XmlNode root, string key, LogSplitId id)
        {
            if (ReadLegacySetting(root, key))
                AddSplitRow(id);
        }

        private static bool ReadLegacySetting(XmlNode root, string id)
        {
            foreach (XmlNode node in root.SelectNodes(".//Setting"))
            {
                if (string.Equals(node.Attributes?["Id"]?.Value, id, StringComparison.OrdinalIgnoreCase))
                    return string.Equals(node.Attributes?["State"]?.Value, "true", StringComparison.OrdinalIgnoreCase);
            }
            return false;
        }

        private static void AddBool(XmlDocument doc, XmlElement parent, string name, bool value)
        {
            var el = doc.CreateElement(name);
            el.InnerText = value ? "True" : "False";
            parent.AppendChild(el);
        }

        private static bool ReadBool(XmlNode root, string name, bool defaultValue)
        {
            var node = root.SelectSingleNode(name);
            if (node != null && bool.TryParse(node.InnerText, out bool b))
                return b;
            return defaultValue;
        }
    }
}
