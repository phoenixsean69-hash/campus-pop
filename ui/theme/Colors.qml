import QtQuick
QtObject {
    readonly property string themeKey: settingsBridge.themeKey
    readonly property bool dark: settingsBridge.isDark
    readonly property bool ocean: themeKey === "ocean"
    readonly property bool slate: themeKey === "slate"

    readonly property color canvas: packStudio ? (dark ? "#1C2023" : "#E9EDF0") : packPaper ? (dark ? "#2D2A24" : "#EAE2D2") : (dark ? "#0F172A" : ocean ? "#F3F7FF" : slate ? "#F5F7FA" : "#FFF8F0")
    readonly property color surface: packStudio ? (dark ? "#252B31" : "#FCFDFE") : packPaper ? (dark ? "#383129" : "#FBF6EB") : (dark ? "#182233" : "#FFFFFF")
    readonly property color elevated: packStudio ? (dark ? "#303943" : "#E2E7EB") : packPaper ? (dark ? "#443A2E" : "#F0E7D8") : (dark ? "#223047" : "#F8FAFD")
    readonly property color surfaceSoft: packStudio ? (dark ? "#303943" : "#F1F4F6") : packPaper ? (dark ? "#3A322B" : "#F6EEE1") : (dark ? "#203047" : ocean ? "#F8FBFF" : slate ? "#F8FAFC" : "#FFFDF9")
    readonly property color inputSurface: packStudio ? (dark ? "#222A31" : "#FFFFFF") : packPaper ? (dark ? "#342F29" : "#FFFCF4") : (dark ? "#1D2A3D" : "#FFFFFF")
    readonly property color ink: packStudio ? (dark ? "#EFF3F7" : "#1C2933") : packPaper ? (dark ? "#F1E6D5" : "#302C24") : (dark ? "#F6F8FD" : ocean ? "#142542" : slate ? "#192233" : "#171B35")
    readonly property color muted: packStudio ? (dark ? "#B4C2CE" : "#5B6976") : packPaper ? (dark ? "#C5B69D" : "#756B5D") : (dark ? "#B7C5D9" : ocean ? "#73829B" : slate ? "#6F7C90" : "#7F88A0")
    readonly property color line: packStudio ? (dark ? "#4A5965" : "#BFC9D0") : packPaper ? (dark ? "#655A49" : "#CDBFAC") : (dark ? "#33465F" : ocean ? "#DEE7F6" : slate ? "#E1E7ED" : "#EFE7E2")
    readonly property color orange: packStudio ? (dark ? "#7394A7" : "#547184") : packPaper ? (dark ? "#BE9161" : "#A07549") : (ocean ? "#2563EB" : slate ? "#64748B" : "#FF7113")
    readonly property color orangeDark: packStudio ? (dark ? "#A8C2D1" : "#3A586B") : packPaper ? (dark ? "#DFC198" : "#765234") : (dark ? (ocean ? "#A9CBFF" : slate ? "#E1E7EF" : "#FFB98E") : ocean ? "#1D4ED8" : slate ? "#334155" : "#C64609")
    readonly property color orangeSoft: packStudio ? (dark ? "#30404B" : "#D9E4EA") : packPaper ? (dark ? "#534536" : "#EEE0CF") : (dark ? (ocean ? "#17365F" : slate ? "#344153" : "#3B2A22") : ocean ? "#EAF1FF" : slate ? "#E9EEF3" : "#FFF0E5")
    readonly property color amberSoft: packStudio ? (dark ? "#42413A" : "#E6E4D8") : packPaper ? (dark ? "#4E4537" : "#F0E6D4") : (dark ? "#3F3325" : "#FFF2CD")
    readonly property color purple: packStudio ? (dark ? "#A0ADB8" : "#617482") : packPaper ? (dark ? "#CFB68F" : "#94704D") : (dark ? "#C4A6FF" : "#8B4DF6")
    readonly property color purpleSoft: packStudio ? (dark ? "#333D47" : "#E3EAF0") : packPaper ? (dark ? "#4D4337" : "#F2E8D9") : (dark ? "#2A2440" : "#F2E8FF")
    readonly property color teal: packStudio ? (dark ? "#93B1AE" : "#667E7C") : packPaper ? (dark ? "#B5A37E" : "#80704D") : (dark ? "#55D8C4" : "#0DBFA8")
    readonly property color tealSoft: packStudio ? (dark ? "#314342" : "#E1E8E6") : packPaper ? (dark ? "#4B4535" : "#ECE5D3") : (dark ? "#163D39" : "#DEF9F1")
    readonly property color success: packStudio ? (dark ? "#8FC3AC" : "#42735D") : packPaper ? (dark ? "#A8C09C" : "#5C7356") : (dark ? "#55D8A5" : "#19AA63")
    readonly property color successSoft: packStudio ? (dark ? "#294035" : "#E0EDE6") : packPaper ? (dark ? "#364B36" : "#E4EBDA") : (dark ? "#203C35" : "#DFF6E9")
    readonly property color danger: packStudio ? (dark ? "#E8A6A3" : "#A34F4F") : packPaper ? (dark ? "#DEA5A0" : "#9A514A") : (dark ? "#FFAEA7" : "#C73F45")
    readonly property color dangerSoft: packStudio ? (dark ? "#472F35" : "#F5E7E6") : packPaper ? (dark ? "#533734" : "#F5E2DA") : (dark ? "#41262A" : "#FFE8E9")

    // CAMPUS_POP_PACKS_V33 – shared design language, independent of accent and appearance mode.
    readonly property string packKey: settingsBridge.packKey
    readonly property bool packPop: packKey === "pop"
    readonly property bool packPaper: packKey === "paper"
    readonly property bool packStudio: packKey === "studio"
    readonly property bool compact: settingsBridge.layoutDensity === "compact"
    readonly property bool showArt: settingsBridge.showIllustrations
    readonly property real typeScale: settingsBridge.fontScale / 100.0
    readonly property string uiFont: packStudio ? "Bahnschrift" : packPaper ? "Georgia" : appFontFamily
    readonly property string headlineFont: packStudio ? "Bahnschrift SemiBold" : packPaper ? "Georgia" : appFontFamily
    readonly property int panelRadius: packStudio ? 4 : packPaper ? 6 : 18
    readonly property int buttonRadius: packStudio ? 4 : packPaper ? 6 : 13
    readonly property int controlRadius: packStudio ? 5 : packPaper ? 7 : 12
    readonly property int buttonDepth: packPop ? 4 : 0
    readonly property int sectionGap: compact ? 9 : 14
    readonly property int pagePadding: compact ? 10 : 15
    readonly property color heroSurface: packStudio ? (dark ? "#28323B" : "#D9E2E7") : packPaper ? (dark ? "#484033" : "#E9D9C1") : orangeSoft
    readonly property color navSurface: packStudio ? (dark ? "#1B252D" : "#E1E7EB") : packPaper ? (dark ? "#302A23" : "#E7DCCA") : surface
    readonly property color cardSurface: packStudio ? (dark ? "#262F36" : "#F8FAFB") : packPaper ? (dark ? "#383129" : "#FBF5E9") : surface
    readonly property color cardBorder: packStudio ? (dark ? "#4F626E" : "#B4C2CB") : packPaper ? (dark ? "#75644C" : "#D2C2AB") : line
    readonly property color navHover: packStudio ? (dark ? "#354550" : "#D4DEE4") : packPaper ? (dark ? "#4A3F30" : "#E2D3BE") : orangeSoft
    readonly property color navSelected: packStudio ? (dark ? "#3D5260" : "#C6D7E1") : packPaper ? (dark ? "#554632" : "#DAC6A9") : orangeSoft
    // CAMPUS_POP_PACKS_V34
    readonly property string paperIntensity: settingsBridge.paperIntensity
    readonly property real paperTextureOpacity: !packPaper ? 0 : (paperIntensity === "strong" ? 1.0 : paperIntensity === "soft" ? 0.35 : 0.64)
    readonly property bool reduceArtwork: packStudio
    readonly property color hairline: packStudio ? (dark ? "#607584" : "#9CAEB9") : packPaper ? (dark ? "#877358" : "#BDAA91") : line
}
