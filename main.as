int min(int a, int b) {
       return a < b ? a : b ;
   }

void Render() {
    auto app = cast<CGameManiaPlanet>(GetApp());
    if (!setting_enabled || app is null || app.RootMap is null || app.Editor !is null) {
        return;
    }

    auto map = cast<CGameCtnChallenge>(app.RootMap);
    if (map is null || map.MapInfo is null || map.MapInfo.MapUid == "") {
        return;
    }

    float scale = Math::Clamp(setting_hud_scale, 0.5f, 2.0f);

    UI::SetNextWindowSize(
        Math::Clamp(int(180 * scale),150,345),
        Math::Clamp(int(60 * scale),50,120),
        UI::Cond::Always
    );

    UI::WindowFlags flags = UI::WindowFlags(
        UI::WindowFlags::NoTitleBar |
        UI::WindowFlags::NoResize |
        UI::WindowFlags::NoCollapse |
        UI::WindowFlags::NoScrollbar
    );

    if(!setting_background) {
       flags = UI::WindowFlags(flags | UI::WindowFlags::NoBackground);
    		}

    if (setting_lock_window_location) {
        flags = UI::WindowFlags(flags | UI::WindowFlags::NoMove);
    }
    if (!UI::IsOverlayShown())
    		flags = UI::WindowFlags(flags | UI::WindowFlags::NoInputs);

    if (UI::Begin("Lap HUD", flags)) {
        auto raceData = MLFeed::GetRaceData_V4();

        if (raceData is null) {
            UI::Text("Waiting for race data...");
        } else {
            auto player = raceData.GetPlayer_V4(
                MLFeed::LocalPlayersName
            );

            if (player is null) {
                UI::Text("Waiting for player...");
            } else {
                int CpsPassed = int(player.CpCount);
                int CpsPerLap = int(raceData.CPCount);
                int TotalLaps = int(raceData.LapCount);
                int CurrentLap = CpsPassed / (CpsPerLap +1 ) + 1;

            UI::PushFontSize(50.0f * scale);

            if (!setting_compact_mode) {
                vec2 labelPos = UI::GetCursorPos();

                if (setting_drop_shadow) {
                    UI::SetCursorPos(labelPos + vec2(2, 2));
                    UI::PushStyleColor(UI::Col::Text, vec4(0, 0, 0, 1));
                    UI::Text("Lap");
                    UI::PopStyleColor();
                }

                UI::SetCursorPos(labelPos);
                UI::PushStyleColor(UI::Col::Text, Setting_text_color);
                UI::Text("Lap");
                UI::PopStyleColor();
                UI::SameLine();
            }
            string lapText = "" + min(CurrentLap, TotalLaps) + " / " + TotalLaps;
            vec2 textPos = UI::GetCursorPos();

            if (setting_drop_shadow) {
                UI::SetCursorPos(textPos + vec2(2, 2));
                UI::PushStyleColor(UI::Col::Text, vec4(0, 0, 0, 1));
                UI::Text(lapText);
                UI::PopStyleColor();
            }

            UI::SetCursorPos(textPos);
            UI::PushStyleColor(UI::Col::Text, Setting_text_color);
            UI::Text(lapText);
            UI::PopStyleColor();
            UI::PopFontSize();
             }
        }
    }

    UI::End();
}
