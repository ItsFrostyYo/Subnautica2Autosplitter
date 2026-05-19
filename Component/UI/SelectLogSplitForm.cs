using System;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;

namespace LiveSplit.Subnautica2
{
    public sealed class SelectLogSplitForm : Form
    {
        private static readonly LogSplitCategory[] CategoryOrder =
        {
            LogSplitCategory.Adaptations,
            LogSplitCategory.Crafts,
            LogSplitCategory.EndGameTriggers,
            LogSplitCategory.OtherSplits,
        };

        private readonly ComboBox categoryCombo;
        private readonly ListBox splitList;
        private readonly Button ok;
        private readonly ToolTip toolTip;

        public LogSplitId SelectedSplit { get; private set; }

        public SelectLogSplitForm(System.Collections.Generic.HashSet<LogSplitId> alreadyUsed)
        {
            Text = "Add Split";
            FormBorderStyle = FormBorderStyle.FixedDialog;
            StartPosition = FormStartPosition.CenterParent;
            MinimizeBox = false;
            MaximizeBox = false;
            ClientSize = new Size(360, 280);
            toolTip = new ToolTip();

            var lblCategory = new Label { Text = "Category", Location = new Point(12, 12), AutoSize = true };
            categoryCombo = new ComboBox
            {
                DropDownStyle = ComboBoxStyle.DropDownList,
                FormattingEnabled = true,
                Location = new Point(12, 28),
                Width = 336
            };
            foreach (var cat in CategoryOrder)
                categoryCombo.Items.Add(cat);
            categoryCombo.Format += (s, e) =>
            {
                if (e.ListItem is LogSplitCategory cat)
                    e.Value = LogSplitCatalog.GetCategoryDisplayName(cat);
            };
            categoryCombo.SelectedIndex = 0;
            categoryCombo.SelectedIndexChanged += (s, e) => RefreshSplits(alreadyUsed);

            var lblSplit = new Label { Text = "Split", Location = new Point(12, 58), AutoSize = true };
            splitList = new ListBox
            {
                Location = new Point(12, 74),
                Width = 336,
                Height = 160,
                IntegralHeight = false
            };
            splitList.DoubleClick += (s, e) =>
            {
                if (splitList.SelectedItem is LogSplitPickerItem item)
                {
                    SelectedSplit = item.Id;
                    DialogResult = DialogResult.OK;
                    Close();
                }
            };
            splitList.SelectedIndexChanged += (s, e) =>
            {
                ok.Enabled = splitList.SelectedItem is LogSplitPickerItem;
                if (splitList.SelectedItem is LogSplitPickerItem item)
                    toolTip.SetToolTip(splitList, LogSplitCatalog.GetDescription(item.Id));
            };

            ok = new Button { Text = "OK", DialogResult = DialogResult.OK, Location = new Point(192, 244), Width = 75 };
            var cancel = new Button { Text = "Cancel", DialogResult = DialogResult.Cancel, Location = new Point(273, 244), Width = 75 };
            ok.Click += (s, e) =>
            {
                if (splitList.SelectedItem is LogSplitPickerItem item)
                    SelectedSplit = item.Id;
                else
                    DialogResult = DialogResult.None;
            };

            Controls.AddRange(new Control[] { lblCategory, categoryCombo, lblSplit, splitList, ok, cancel });
            AcceptButton = ok;
            CancelButton = cancel;

            toolTip.SetToolTip(categoryCombo, "Choose a split category.");
            toolTip.SetToolTip(splitList, "Choose a split to add.");
            toolTip.SetToolTip(ok, "Add the selected split.");
            toolTip.SetToolTip(cancel, "Close without adding a split.");

            RefreshSplits(alreadyUsed);
        }

        private void RefreshSplits(System.Collections.Generic.HashSet<LogSplitId> alreadyUsed)
        {
            splitList.Items.Clear();
            if (categoryCombo.SelectedItem is LogSplitCategory cat)
            {
                toolTip.SetToolTip(categoryCombo, LogSplitCatalog.GetCategoryDescription(cat));
                foreach (var id in LogSplitCatalog.GetByCategory(cat)
                    .Where(id => cat == LogSplitCategory.Crafts || !alreadyUsed.Contains(id)))
                    splitList.Items.Add(new LogSplitPickerItem(id));
            }
            if (splitList.Items.Count > 0)
                splitList.SelectedIndex = 0;
            ok.Enabled = splitList.Items.Count > 0;
        }

        private sealed class LogSplitPickerItem
        {
            public LogSplitId Id { get; }
            public string Text { get; }
            public LogSplitPickerItem(LogSplitId id)
            {
                Id = id;
                Text = LogSplitCatalog.GetDisplayName(id);
            }
            public override string ToString() => Text;
        }
    }
}
