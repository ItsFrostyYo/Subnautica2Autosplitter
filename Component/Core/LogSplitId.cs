using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;

namespace LiveSplit.Subnautica2
{
    public enum LogSplitCategory
    {
        [Description("Adaptations")]
        Adaptations,
        [Description("Crafts")]
        Crafts,
        [Description("End Game Triggers")]
        EndGameTriggers,
        [Description("Other Splits")]
        OtherSplits,
    }

    public enum LogSplitId
    {
        [Description("Pressure Adaptation")]
        PressureAdaptation,
        [Description("Digestion Adaptation")]
        DigestionAdaptation,
        [Description("Heat Adaptation")]
        HeatAdaptation,
        [Description("Axum Vision Adaptation")]
        AxumVisionAdaptation,
        [Description("High Capacity O2 Tank")]
        HighCapacityO2Tank,
        [Description("Feedback Resonator")]
        FeedbackResonator,
        [Description("Bioscanner")]
        Bioscanner,
        [Description("Habitat Builder")]
        HabitatBuilder,
        [Description("Translate Message")]
        TranslateMessage,
        [Description("Thanks for Playing")]
        ThanksForPlaying,
        [Description("Lifepod Ascend")]
        LifepodAscend,
    }

    public static class LogSplitCatalog
    {
        private static readonly Dictionary<LogSplitId, string> SplitDescriptions = new Dictionary<LogSplitId, string>
        {
            { LogSplitId.PressureAdaptation, "Splits when the Pressure adaptation interaction is triggered." },
            { LogSplitId.DigestionAdaptation, "Splits when the Digestion adaptation is unlocked." },
            { LogSplitId.HeatAdaptation, "Splits when the Heat adaptation is unlocked." },
            { LogSplitId.AxumVisionAdaptation, "Splits when the Axum Vision adaptation is unlocked." },
            { LogSplitId.HighCapacityO2Tank, "Splits when High Capacity O2 Tank crafting completes." },
            { LogSplitId.FeedbackResonator, "Splits when Feedback Resonator crafting completes." },
            { LogSplitId.Bioscanner, "Splits when Bioscanner crafting completes." },
            { LogSplitId.HabitatBuilder, "Splits when Habitat Builder crafting completes." },
            { LogSplitId.TranslateMessage, "Splits at the end-game translation interaction trigger." },
            { LogSplitId.ThanksForPlaying, "Splits when the Thanks for Playing popup is shown." },
            { LogSplitId.LifepodAscend, "Splits when lifepod ascent is activated." },
        };

        private static readonly Dictionary<LogSplitCategory, string> CategoryDescriptions = new Dictionary<LogSplitCategory, string>
        {
            { LogSplitCategory.Adaptations, "Adaptation unlock and adaptation-related interaction splits." },
            { LogSplitCategory.Crafts, "Craft completion splits for key progression items." },
            { LogSplitCategory.EndGameTriggers, "End-game interaction and completion trigger splits." },
            { LogSplitCategory.OtherSplits, "Special-case progression splits." },
        };

        private static readonly Dictionary<LogSplitId, LogSplitCategory> Categories = new Dictionary<LogSplitId, LogSplitCategory>
        {
            { LogSplitId.PressureAdaptation, LogSplitCategory.Adaptations },
            { LogSplitId.DigestionAdaptation, LogSplitCategory.Adaptations },
            { LogSplitId.HeatAdaptation, LogSplitCategory.Adaptations },
            { LogSplitId.AxumVisionAdaptation, LogSplitCategory.Adaptations },
            { LogSplitId.HighCapacityO2Tank, LogSplitCategory.Crafts },
            { LogSplitId.FeedbackResonator, LogSplitCategory.Crafts },
            { LogSplitId.Bioscanner, LogSplitCategory.Crafts },
            { LogSplitId.HabitatBuilder, LogSplitCategory.Crafts },
            { LogSplitId.TranslateMessage, LogSplitCategory.EndGameTriggers },
            { LogSplitId.ThanksForPlaying, LogSplitCategory.EndGameTriggers },
            { LogSplitId.LifepodAscend, LogSplitCategory.OtherSplits },
        };

        public static LogSplitCategory GetCategory(LogSplitId id) => Categories[id];

        public static string GetCategoryDisplayName(LogSplitCategory category)
        {
            var field = typeof(LogSplitCategory).GetField(category.ToString());
            var attr = (DescriptionAttribute)Attribute.GetCustomAttribute(field, typeof(DescriptionAttribute));
            return attr?.Description ?? category.ToString();
        }

        public static string GetDisplayName(LogSplitId id)
        {
            var field = typeof(LogSplitId).GetField(id.ToString());
            var attr = (DescriptionAttribute)Attribute.GetCustomAttribute(field, typeof(DescriptionAttribute));
            return attr?.Description ?? id.ToString();
        }

        public static IEnumerable<LogSplitId> GetByCategory(LogSplitCategory category) =>
            Categories.Where(kv => kv.Value == category).Select(kv => kv.Key);

        public static IReadOnlyList<LogSplitId> All { get; } = Enum.GetValues(typeof(LogSplitId)).Cast<LogSplitId>().ToArray();

        public static string GetDescription(LogSplitId id)
        {
            if (SplitDescriptions.TryGetValue(id, out var description))
                return description;
            return GetDisplayName(id);
        }

        public static string GetCategoryDescription(LogSplitCategory category)
        {
            if (CategoryDescriptions.TryGetValue(category, out var description))
                return description;
            return GetCategoryDisplayName(category);
        }

        public static bool TryMatchLiveSplitName(string segmentName, out LogSplitId id)
        {
            id = default;
            if (string.IsNullOrWhiteSpace(segmentName))
                return false;

            string norm = Normalize(segmentName);
            foreach (var splitId in All)
            {
                if (norm.Contains(Normalize(GetDisplayName(splitId))))
                {
                    id = splitId;
                    return true;
                }
            }
            return false;
        }

        private static string Normalize(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return string.Empty;
            var chars = value.Where(char.IsLetterOrDigit).Select(char.ToLowerInvariant).ToArray();
            return new string(chars);
        }
    }
}
