# Budget League Tracker – User Flows

High-level description of the main user journeys. Useful for developers and support.

## Creating a tournament

The user starts from the **Tournaments** tab and taps to create a new tournament. After confirming (and acknowledging that starting fresh clears or resets data as applicable), they reach the **New Tournament** flow: they add or select players, set the number of weeks and how many random achievements to roll each week, then start the tournament. On start, the app creates the tournament, rolls active achievements for week 1, and either opens **Attendance** for the first week or returns to the tournaments list, depending on flow. The new tournament becomes the active one; navigation state is updated so the user can continue into the weekly flow.

## Running a week

For each week, the user first sees **Attendance**: they mark who is present, choose whether achievements count this week, and can add a new player (who joins the league and is marked present). After confirming attendance, they go to **Pods**. There they generate pods for the current round (round 1 is random; later rounds are grouped by weekly points). For each pod they set placement (1st–4th) for each player and, if achievements are on, check which players earned which active achievements. They save each pod; they can undo the last saved pod if needed. When all pods are saved, they advance to the next round (up to three rounds per week). After round 3, **Weekly Standings** is shown: a ranking of present players by that week’s points. The user can continue to the next week (or to **Tournament Standings** if it was the last week) or exit back to Pods without advancing.

## Viewing results and data

**Weekly Standings** shows the current week’s ranking (placement + achievement points). **Tournament Standings** is shown when the tournament is finished (after the last week); it lists all players by total placement and achievement points; the user closes it to return to the Tournaments list. The **Stats** tab shows a summary of each player’s cumulative performance (wins, placement points, achievement points). The **Achievements** tab lists all achievements (name, points, always-on) and lets the user add, edit, or remove them. The **Players** tab lists all players; tapping one opens a detail view with that player’s stats and history. The **Tournaments** tab lists tournaments; tapping one opens tournament detail (e.g. current week/round, standings, option to run attendance/pods or view standings).

## Settings

The **Settings** tab shows app credit (author), app name, version, and build number. It is the place for future app-wide settings (e.g. toggles, links to privacy or support).
