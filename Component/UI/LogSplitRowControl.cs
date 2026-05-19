using System.Drawing;
using System.Windows.Forms;

namespace LiveSplit.Subnautica2
{
    /// <summary>Split row styled like legacy Subnautica2PrefabSplit.</summary>
    public sealed class LogSplitRowControl : UserControl
    {
        private static readonly ToolTip SharedToolTip = new ToolTip();
        private LogSplitId splitId;

        public ComboBox ComboBox { get; }
        public Button BtnRemove { get; }
        public Label CategoryLabel { get; }
        public Label DragHandle { get; }
        public LogSplitId SplitId => splitId;

        public LogSplitRowControl()
        {
            AutoSize = true;
            BorderStyle = BorderStyle.FixedSingle;
            Size = new Size(448, 47);
            Margin = new Padding(2, 0, 2, 2);

            DragHandle = new Label
            {
                Text = "::",
                AutoSize = false,
                Size = new Size(20, 20),
                Location = new Point(3, 13),
                Cursor = Cursors.SizeAll,
                TextAlign = ContentAlignment.MiddleCenter
            };

            CategoryLabel = new Label
            {
                AutoSize = true,
                Location = new Point(26, 2),
                Text = "Adaptations"
            };

            ComboBox = new ComboBox
            {
                DropDownStyle = ComboBoxStyle.DropDownList,
                Location = new Point(29, 18),
                Size = new Size(393, 21),
                Enabled = false
            };

            BtnRemove = new Button
            {
                Text = "X",
                Location = new Point(416, 16),
                Size = new Size(26, 23)
            };

            Controls.Add(DragHandle);
            Controls.Add(CategoryLabel);
            Controls.Add(ComboBox);
            Controls.Add(BtnRemove);

            foreach (var id in LogSplitCatalog.All)
                ComboBox.Items.Add(new LogSplitComboItem(id));

            ComboBox.DisplayMember = "Text";
            ComboBox.ValueMember = "Id";
            ComboBox.SelectedIndexChanged += (s, e) =>
            {
                if (ComboBox.SelectedItem is LogSplitComboItem item)
                    splitId = item.Id;
            };

            SharedToolTip.SetToolTip(DragHandle, "Drag to reorder this split.");
            SharedToolTip.SetToolTip(BtnRemove, "Remove this split from the active list.");

            DragHandle.MouseDown += (s, e) =>
            {
                if (e.Button == MouseButtons.Left)
                    DoDragDrop(this, DragDropEffects.Move);
            };
        }

        public void SetSplitId(LogSplitId id)
        {
            var category = LogSplitCatalog.GetCategory(id);
            CategoryLabel.Text = LogSplitCatalog.GetCategoryDisplayName(category);

            SharedToolTip.SetToolTip(CategoryLabel, LogSplitCatalog.GetCategoryDescription(category));
            SharedToolTip.SetToolTip(ComboBox, LogSplitCatalog.GetDescription(id));
            splitId = id;

            for (int i = 0; i < ComboBox.Items.Count; i++)
            {
                if (((LogSplitComboItem)ComboBox.Items[i]).Id == id)
                {
                    ComboBox.SelectedIndex = i;
                    return;
                }
            }

            // Fallback safety: keep the row valid even if id was not found.
            if (ComboBox.Items.Count > 0)
            {
                ComboBox.SelectedIndex = 0;
                if (ComboBox.SelectedItem is LogSplitComboItem item)
                    splitId = item.Id;
            }
        }

        public bool TryGetSplitId(out LogSplitId id)
        {
            if (ComboBox.SelectedItem is LogSplitComboItem selected)
            {
                id = selected.Id;
                return true;
            }

            id = splitId;
            return true;
        }

        public void ApplyWidth(int rowWidth)
        {
            if (rowWidth < 340)
                rowWidth = 340;

            Width = rowWidth;

            BtnRemove.Left = rowWidth - BtnRemove.Width - 6;
            int comboRightPadding = 6;
            int comboWidth = BtnRemove.Left - comboRightPadding - ComboBox.Left;
            if (comboWidth < 120)
                comboWidth = 120;
            ComboBox.Width = comboWidth;
        }

        protected override void OnMouseDown(MouseEventArgs e)
        {
            base.OnMouseDown(e);
            if (e.Button == MouseButtons.Left)
                DoDragDrop(this, DragDropEffects.Move);
        }

        private sealed class LogSplitComboItem
        {
            public LogSplitId Id { get; }
            public string Text { get; }
            public LogSplitComboItem(LogSplitId id)
            {
                Id = id;
                Text = LogSplitCatalog.GetDisplayName(id);
            }
            public override string ToString() => Text;
        }
    }
}
