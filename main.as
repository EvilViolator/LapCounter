
bool g_ShowHUD = true;

int min(int a, int b) {
       return a < b ? a : b;
   }

void RenderMenu() {
    if (UI::MenuItem("Lap HUD", "", g_ShowHUD)) {
        g_ShowHUD = !g_ShowHUD;
    }
}

void Render() {
    if (!g_ShowHUD) {
        return;
    }

    UI::SetNextWindowSize(240, 100, UI::Cond::FirstUseEver);

    if (UI::Begin("Lap HUD",
    UI::WindowFlags::NoTitleBar |
    UI::WindowFlags::NoResize |
    UI::WindowFlags::NoCollapse |
    UI::WindowFlags::NoScrollbar |
    UI::WindowFlags::NoBackground)) {
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

            UI::PushFontSize(50.0f);
            UI::Text("Lap");
            UI::SameLine();
            UI::Text("" + min(CurrentLap,TotalLaps) + " / " + TotalLaps);
            UI::PopFontSize();
            }
        }
    }

    UI::End();
}
