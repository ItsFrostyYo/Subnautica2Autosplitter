namespace LiveSplit.Subnautica2
{
    partial class Subnautica2Settings
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && components != null)
                components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
            flowMain = new System.Windows.Forms.FlowLayoutPanel();
            flowOptions = new System.Windows.Forms.FlowLayoutPanel();
            Options_GroupBox = new System.Windows.Forms.GroupBox();
            Other_GroupBox = new System.Windows.Forms.GroupBox();
            cbOrderedAutoSplits = new System.Windows.Forms.CheckBox();
            cbOrderedLiveSplit = new System.Windows.Forms.CheckBox();
            chkAskForGoldSave = new System.Windows.Forms.CheckBox();
            btnAddSplit = new System.Windows.Forms.Button();
            StartReset_GroupBox = new System.Windows.Forms.GroupBox();
            chkReset = new System.Windows.Forms.CheckBox();
            chkCreativeStart = new System.Windows.Forms.CheckBox();
            chkIntroStart = new System.Windows.Forms.CheckBox();
            ToolTips = new System.Windows.Forms.ToolTip(components);
            ToolTips.AutoPopDelay = 9000;
            ToolTips.InitialDelay = 300;
            ToolTips.ReshowDelay = 180;
            ToolTips.ShowAlways = true;
            flowMain.SuspendLayout();
            flowOptions.SuspendLayout();
            Options_GroupBox.SuspendLayout();
            Other_GroupBox.SuspendLayout();
            StartReset_GroupBox.SuspendLayout();
            SuspendLayout();
            // flowMain — flowOptions at index 0; split rows added after (legacy layout)
            flowMain.AllowDrop = true;
            flowMain.AutoSize = true;
            flowMain.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            flowMain.Controls.Add(flowOptions);
            flowMain.Dock = System.Windows.Forms.DockStyle.Fill;
            flowMain.FlowDirection = System.Windows.Forms.FlowDirection.TopDown;
            flowMain.Location = new System.Drawing.Point(0, 0);
            flowMain.Margin = new System.Windows.Forms.Padding(0);
            flowMain.Name = "flowMain";
            flowMain.Size = new System.Drawing.Size(472, 152);
            flowMain.WrapContents = false;
            flowMain.DragDrop += flowMain_DragDrop;
            flowMain.DragEnter += flowMain_DragEnter;
            flowMain.DragOver += flowMain_DragOver;
            flowMain.DragLeave += flowMain_DragLeave;
            flowMain.Paint += flowMain_Paint;
            // flowOptions
            flowOptions.AutoSize = false;
            flowOptions.Controls.Add(Options_GroupBox);
            flowOptions.FlowDirection = System.Windows.Forms.FlowDirection.TopDown;
            flowOptions.Location = new System.Drawing.Point(0, 0);
            flowOptions.Margin = new System.Windows.Forms.Padding(0);
            flowOptions.Name = "flowOptions";
            flowOptions.Size = new System.Drawing.Size(472, 152);
            // Options_GroupBox — matches legacy Subnautica2Settings.Designer.cs
            Options_GroupBox.Controls.Add(Other_GroupBox);
            Options_GroupBox.Controls.Add(btnAddSplit);
            Options_GroupBox.Controls.Add(StartReset_GroupBox);
            Options_GroupBox.Location = new System.Drawing.Point(3, 3);
            Options_GroupBox.Name = "Options_GroupBox";
            Options_GroupBox.Size = new System.Drawing.Size(466, 146);
            Options_GroupBox.TabStop = false;
            Options_GroupBox.Text = "Options";
            // Other_GroupBox
            Other_GroupBox.Controls.Add(cbOrderedAutoSplits);
            Other_GroupBox.Controls.Add(cbOrderedLiveSplit);
            Other_GroupBox.Controls.Add(chkAskForGoldSave);
            Other_GroupBox.Location = new System.Drawing.Point(296, 15);
            Other_GroupBox.Name = "Other_GroupBox";
            Other_GroupBox.Size = new System.Drawing.Size(164, 98);
            Other_GroupBox.TabStop = false;
            Other_GroupBox.Text = "Others";
            // cbOrderedAutoSplits
            cbOrderedAutoSplits.AutoSize = true;
            cbOrderedAutoSplits.Location = new System.Drawing.Point(5, 73);
            cbOrderedAutoSplits.Name = "cbOrderedAutoSplits";
            cbOrderedAutoSplits.Size = new System.Drawing.Size(151, 17);
            cbOrderedAutoSplits.Text = "Ordered Splits (Auto-Splits)";
            ToolTips.SetToolTip(cbOrderedAutoSplits, "Follows the autosplitter list order only (top to bottom in the settings list), independent of split names in your LiveSplit file.");
            cbOrderedAutoSplits.UseVisualStyleBackColor = true;
            cbOrderedAutoSplits.CheckedChanged += cbOrderedAutoSplits_CheckedChanged;
            // cbOrderedLiveSplit
            cbOrderedLiveSplit.AutoSize = true;
            cbOrderedLiveSplit.Checked = true;
            cbOrderedLiveSplit.CheckState = System.Windows.Forms.CheckState.Checked;
            cbOrderedLiveSplit.Location = new System.Drawing.Point(5, 50);
            cbOrderedLiveSplit.Name = "cbOrderedLiveSplit";
            cbOrderedLiveSplit.Size = new System.Drawing.Size(141, 17);
            cbOrderedLiveSplit.Text = "Ordered Splits (LiveSplit)";
            ToolTips.SetToolTip(cbOrderedLiveSplit, "Only allows autosplits that match your current split file order.\r\nIf you skip a manual split in LiveSplit, autosplitter progression follows that skip.");
            cbOrderedLiveSplit.UseVisualStyleBackColor = true;
            cbOrderedLiveSplit.CheckedChanged += cbOrderedLiveSplit_CheckedChanged;
            // chkAskForGoldSave
            chkAskForGoldSave.AutoSize = true;
            chkAskForGoldSave.Location = new System.Drawing.Point(5, 19);
            chkAskForGoldSave.Name = "chkAskForGoldSave";
            chkAskForGoldSave.Size = new System.Drawing.Size(157, 17);
            chkAskForGoldSave.Text = "Warn On Reset If Gold Split";
            ToolTips.SetToolTip(chkAskForGoldSave, "Shows LiveSplit's save-golds prompt on auto-reset.");
            chkAskForGoldSave.UseVisualStyleBackColor = true;
            // btnAddSplit
            btnAddSplit.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F);
            btnAddSplit.Location = new System.Drawing.Point(6, 118);
            btnAddSplit.Name = "btnAddSplit";
            btnAddSplit.Size = new System.Drawing.Size(284, 23);
            btnAddSplit.Text = "Add Split";
            ToolTips.SetToolTip(btnAddSplit, "Add a split from the selected category to the active autosplit list.");
            btnAddSplit.UseVisualStyleBackColor = true;
            btnAddSplit.Click += btnAddSplit_Click;
            // StartReset_GroupBox
            StartReset_GroupBox.Controls.Add(chkReset);
            StartReset_GroupBox.Controls.Add(chkCreativeStart);
            StartReset_GroupBox.Controls.Add(chkIntroStart);
            StartReset_GroupBox.Location = new System.Drawing.Point(6, 15);
            StartReset_GroupBox.Name = "StartReset_GroupBox";
            StartReset_GroupBox.Size = new System.Drawing.Size(284, 97);
            StartReset_GroupBox.TabStop = false;
            StartReset_GroupBox.Text = "Start / Reset";
            // chkReset
            chkReset.AutoSize = true;
            chkReset.Checked = true;
            chkReset.CheckState = System.Windows.Forms.CheckState.Checked;
            chkReset.Location = new System.Drawing.Point(5, 66);
            chkReset.Name = "chkReset";
            chkReset.Size = new System.Drawing.Size(130, 17);
            chkReset.Text = "Reset on Main Menu";
            ToolTips.SetToolTip(chkReset, "Resets when you quit back to main menu.");
            chkReset.UseVisualStyleBackColor = true;
            // chkCreativeStart
            chkCreativeStart.AutoSize = true;
            chkCreativeStart.Location = new System.Drawing.Point(5, 43);
            chkCreativeStart.Name = "chkCreativeStart";
            chkCreativeStart.Size = new System.Drawing.Size(90, 17);
            chkCreativeStart.Text = "Creative Start";
            ToolTips.SetToolTip(chkCreativeStart, "Starts when you gain control in a new Creative run.");
            chkCreativeStart.UseVisualStyleBackColor = true;
            // chkIntroStart
            chkIntroStart.AutoSize = true;
            chkIntroStart.Checked = true;
            chkIntroStart.CheckState = System.Windows.Forms.CheckState.Checked;
            chkIntroStart.Location = new System.Drawing.Point(5, 20);
            chkIntroStart.Name = "chkIntroStart";
            chkIntroStart.Size = new System.Drawing.Size(140, 17);
            chkIntroStart.Text = "Survival Start";
            ToolTips.SetToolTip(chkIntroStart, "Starts when you gain control in a new Survival run.");
            chkIntroStart.UseVisualStyleBackColor = true;
            // Subnautica2Settings
            AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            AutoScroll = true;
            AutoSize = true;
            AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            Controls.Add(flowMain);
            Margin = new System.Windows.Forms.Padding(0);
            Name = "Subnautica2Settings";
            Size = new System.Drawing.Size(472, 152);
            flowMain.ResumeLayout(false);
            flowMain.PerformLayout();
            flowOptions.ResumeLayout(false);
            Options_GroupBox.ResumeLayout(false);
            Other_GroupBox.ResumeLayout(false);
            Other_GroupBox.PerformLayout();
            StartReset_GroupBox.ResumeLayout(false);
            StartReset_GroupBox.PerformLayout();
            ResumeLayout(false);
            PerformLayout();

            ApplyLegacyLayout();
        }

        private void ApplyLegacyLayout()
        {
            const int margin = 6;
            const int colGap = 8;
            const int groupTop = 15;
            const int groupHeight = 97;
            int contentWidth = Options_GroupBox.ClientSize.Width - margin * 2 - 2;
            if (contentWidth < 360)
                contentWidth = 360;
            int leftWidth = (contentWidth - colGap) / 2;
            int rightWidth = contentWidth - leftWidth - colGap;

            StartReset_GroupBox.SetBounds(margin, groupTop, leftWidth, groupHeight);
            Other_GroupBox.SetBounds(margin + leftWidth + colGap, groupTop, rightWidth, groupHeight);

            chkIntroStart.AutoSize = false;
            chkCreativeStart.AutoSize = false;
            chkReset.AutoSize = false;
            chkAskForGoldSave.AutoSize = false;
            cbOrderedLiveSplit.AutoSize = false;
            cbOrderedAutoSplits.AutoSize = false;

            chkIntroStart.Location = new System.Drawing.Point(5, 20);
            chkCreativeStart.Location = new System.Drawing.Point(5, 43);
            chkReset.Location = new System.Drawing.Point(5, 66);
            chkIntroStart.Width = StartReset_GroupBox.Width - 12;
            chkCreativeStart.Width = StartReset_GroupBox.Width - 12;
            chkReset.Width = StartReset_GroupBox.Width - 12;
            chkIntroStart.Height = 18;
            chkCreativeStart.Height = 18;
            chkReset.Height = 18;

            chkAskForGoldSave.Location = new System.Drawing.Point(5, 20);
            cbOrderedLiveSplit.Location = new System.Drawing.Point(5, 43);
            cbOrderedAutoSplits.Location = new System.Drawing.Point(5, 66);
            chkAskForGoldSave.Width = Other_GroupBox.Width - 12;
            cbOrderedLiveSplit.Width = Other_GroupBox.Width - 12;
            cbOrderedAutoSplits.Width = Other_GroupBox.Width - 12;
            chkAskForGoldSave.Height = 18;
            cbOrderedLiveSplit.Height = 18;
            cbOrderedAutoSplits.Height = 18;
            chkAskForGoldSave.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            cbOrderedLiveSplit.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            cbOrderedAutoSplits.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            chkIntroStart.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            chkCreativeStart.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            chkReset.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;

            btnAddSplit.SetBounds(margin, groupTop + groupHeight + 5, contentWidth, 23);
        }

        internal System.Windows.Forms.FlowLayoutPanel flowMain;
        internal System.Windows.Forms.FlowLayoutPanel flowOptions;
        private System.Windows.Forms.GroupBox Options_GroupBox;
        private System.Windows.Forms.GroupBox Other_GroupBox;
        private System.Windows.Forms.CheckBox cbOrderedAutoSplits;
        private System.Windows.Forms.CheckBox cbOrderedLiveSplit;
        private System.Windows.Forms.CheckBox chkAskForGoldSave;
        private System.Windows.Forms.Button btnAddSplit;
        private System.Windows.Forms.GroupBox StartReset_GroupBox;
        private System.Windows.Forms.CheckBox chkReset;
        private System.Windows.Forms.CheckBox chkCreativeStart;
        private System.Windows.Forms.CheckBox chkIntroStart;
        private System.Windows.Forms.ToolTip ToolTips;
    }
}
