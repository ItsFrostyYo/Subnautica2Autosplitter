using System;
using System.Reflection;
using LiveSplit.Model;
using LiveSplit.UI.Components;

namespace LiveSplit.Subnautica2
{
    public sealed class Factory : IComponentFactory
    {
        public string ComponentName => "Subnautica 2 Autosplitter";

        public string Description => "Log-based autosplitter for Subnautica 2 (Early Access).";

        public ComponentCategory Category => ComponentCategory.Control;

        public string UpdateName => ComponentName;

        public string XMLURL => UpdateURL + "Components/Subnautica2.Updates.xml";

        public string UpdateURL => "https://raw.githubusercontent.com/ItsFrostyYo/Subnautica2Autosplitter/main/";

        public Version Version => Assembly.GetExecutingAssembly().GetName().Version;

        public IComponent Create(LiveSplitState state) => new Subnautica2Component(state);
    }
}
