const float BASE_WIDTH     = 155.0f;
const float BASE_HEIGHT    = 60.0f;
const float BASE_FONT_SIZE = 50.0f;
const vec2  SHADOW_OFFSET  = vec2(2, 2);

UI::WindowFlags GetWindowFlags() {
    UI::WindowFlags flags = UI::WindowFlags(
        UI::WindowFlags::NoTitleBar |
        UI::WindowFlags::NoResize |
        UI::WindowFlags::NoCollapse |
        UI::WindowFlags::NoScrollbar
    );
    if (!setting_background) {
        flags = UI::WindowFlags(flags | UI::WindowFlags::NoBackground);
    }
    if (setting_lock_window_location) {
        flags = UI::WindowFlags(flags | UI::WindowFlags::NoMove);
    }
    if (!UI::IsOverlayShown()) {
        flags = UI::WindowFlags(flags | UI::WindowFlags::NoInputs);
    }
    return flags;
}

void DrawShadowedText(const string &in text) {
    vec2 pos = UI::GetCursorPos();

    if (setting_drop_shadow) {
        UI::SetCursorPos(pos + SHADOW_OFFSET);
        UI::PushStyleColor(UI::Col::Text, vec4(0, 0, 0, 1));
        UI::Text(text);
        UI::PopStyleColor();
    }

    UI::SetCursorPos(pos);
    UI::PushStyleColor(UI::Col::Text, setting_text_color);
    UI::Text(text);
    UI::PopStyleColor();
}

void DrawLapCounter(int currentLap, int totalLaps, float scale) {
    UI::PushFontSize(BASE_FONT_SIZE * scale);

    if (!setting_compact_mode) {
        DrawShadowedText("Lap");
        UI::SameLine();
    }
    DrawShadowedText(currentLap + "/" + totalLaps);

    UI::PopFontSize();
}

bool IsMapLoaded() {
    auto app = cast<CGameManiaPlanet>(GetApp());
    return setting_enabled
        && app !is null
        && app.Editor is null
        && app.RootMap !is null
        && app.RootMap.MapInfo !is null
        && app.RootMap.MapInfo.MapUid != "";
}

void Render() {
    if (!IsMapLoaded()) return;

    auto raceData = MLFeed::GetRaceData_V4();
    if (raceData !is null && raceData.LapCount == 1 && setting_only_multilap) return;

    float scale = Math::Clamp(setting_hud_scale, 0.5f, 2.0f);
    UI::SetNextWindowSize(
        int(Math::Clamp(BASE_WIDTH * scale, 130.0f, 300.0f)),
        int(Math::Clamp(BASE_HEIGHT * scale, 50.0f, 120.0f)),
        UI::Cond::Always
    );

    if (UI::Begin("Lap HUD", GetWindowFlags())) {
        if (raceData is null) {
            UI::Text("Waiting for race data...");
        } else {
            auto player = raceData.GetPlayer_V4(MLFeed::LocalPlayersName);
            if (player is null) {
                UI::Text("Waiting for player...");
            } else {
                int totalLaps  = int(raceData.LapCount);
                int cpsPerLap  = int(raceData.CPCount) + 1; // +1 because the finish counts as checkpoint
                int currentLap = int(player.CpCount) / cpsPerLap + 1;
                DrawLapCounter(Math::Min(currentLap, totalLaps), totalLaps, scale);
            }
        }
    }
    UI::End();
}