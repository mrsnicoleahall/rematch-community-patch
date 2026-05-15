# Rematch — Community Fork

Community-maintained patch of **Rematch 5.3.1** by Gello, with bug fixes for
WoW The War Within (Interface 11.x / 12.x).

This is a drop-in replacement that **shares the same SavedVariables** as the
original Rematch — your teams, groups, targets, notes, and settings all carry
over with zero migration.

## Installation

1. **Disable the original Rematch** in the AddOns menu on the character select
   screen (or run `/reload` after toggling). Both addons share global frame
   names like `RematchFrame` and `RematchDialog`, so they cannot run side by
   side.
2. The folder `Rematch_Community/` should live in
   `World of Warcraft/_retail_/Interface/AddOns/` (it does already).
3. Enable **Rematch [Community]** in the AddOns list. The community build
   shows a blue `[Community]` tag in the AddOns list so you can tell it apart.
4. Log in. If you forgot step 1, the addon will print a warning in chat and
   the red error frame reminding you to disable the original.

You can switch back to the original at any time — just disable
`Rematch [Community]` and re-enable `Rematch`. Your data stays put.

## What changed

Every patched line is tagged `[Community fix]` in a comment so you can find
them easily with `grep -rn "Community fix"`.

### P0 — fixes for the team rename / team delete failures

- **`savedvars/savedTeams.lua` `copyTeam`** no longer mutates `source.name`
  in place. The original `source.name = source.name:trim()` was both a crash
  vector (when `source.name` was nil) and a stealth side-effect that would
  alter live saved teams during a Reset round-trip. Now the trim writes to
  `dest` only and tolerates a nil source name.
- **`savedTeams.lua` `setter`** guards against non-string `value.name` before
  delegating to `copyTeam`.
- **`savedTeams.lua` `updateNames`** coerces `team.name` to a string before
  `:lower()`, so a single corrupt team in SavedVars no longer prevents the
  whole team list from refreshing.
- **`savedTeams.lua` `GetTeamIDByName`** does a type check before
  `name:lower()` — `IsTeamNameUsed()` no longer crashes when the EditBox text
  is coerced unexpectedly.
- **`savedTeams.lua` `GetUniqueName`** tolerates non-string and empty input.
- **`savedTeams.lua` `DeleteTeam`** no longer calls `TeamsChanged()` twice.
  The setter already dispatches `REMATCH_TEAM_DELETED` and runs the
  housekeeping pass; the duplicate call was causing the second pass to run
  against a half-cleaned `group.teams` table and occasionally throw against
  the just-deleted teamID — the exact symptom of "delete doesn't work".
- **`savedTeams.lua` `MoveTeam`** now handles group → group moves. The
  original only handled `→ favorites` and `favorites →`, silently no-op'ing
  every other move. (Drag-and-drop bypassed `MoveTeam`; menu-based moves were
  broken.)
- **`dialogs/saveDialog.lua` `Accept`**, `IsTeamNameUsed`, `OnChange`, and
  `Refresh` all gain defensive `(name or ""):lower()` / `:trim()` coercion to
  prevent the rename/save path from throwing during edge cases (mid-layout
  swap, missing `sideline.groupID`, etc.).

### P0 — fix for the empty pet list on login

- **`roster/roster.lua`** migrates from the removed `LE_PET_JOURNAL_FILTER_*`
  globals to `Enum.PetJournalFilter.Collected` /
  `Enum.PetJournalFilter.NotCollected`. The old constants returned nil in
  TWW, so `C_PetJournal.IsFilterChecked(nil)` errored on first login and
  cascaded into an empty roster.

### P1 — latent crashes around menus and the team load path

- **`menus/teamMenu.lua` `GetGroupName` / `GetTeamName`** guard against a
  stale menu opened on a just-deleted group/team.
- **`menus/teamMenu.lua` `SetOrRemoveFavorite`** guards before the `else`
  branch (the original `if team and team.favorite then … else team.homeID =
  team.groupID` would throw if `team` itself was nil).
- **`menus/teamMenu.lua` `LoadSavedTarget` / `EditSavedTarget`** guard
  `#targets` against a nil targets table.
- **`menus/teamMenu.lua` `ExportTeam`** removes a reference to an undefined
  upvalue `newTeam`.
- **`process/loadTeam.lua` `startLoad`** fixes two upvalue bugs:
  - The loop intended to walk `team.pets[i]` (lenient-rules heuristic for
    all-random teams) was reading `team.pets[slot]` — `slot` is not defined
    in that scope, so the check always took the wrong branch.
  - The `petInfo.idType=="pet" and not petInfo.isValid` branch passed
    `ability1/ability2/ability3` without ever defining them in scope. Pulled
    from `team.tags[slot]` like the sibling branch.

### P2 — small data-correctness fixes

- **`info/collectionInfo.lua`** off-by-one in the per-rarity counter:
  `info[6+rarity] = info[5+rarity]+1` was reading from the wrong slot. Now
  reads and writes the same slot.
- **`info/petInfo.lua` `Passive`** chain `:match():gsub()` would crash if
  Blizzard's localized description ever lacked the `\r\n…\r` block. Wrapped
  with nil-safety so an unrecognized passive description just resolves to
  empty rather than throwing.
- **`savedvars/savedGroups.lua` `teamWinSort`** guards against
  divide-by-zero on `winrecord.battles==0` and tolerates non-string names in
  the tiebreaker.

### Packaging changes

- TOC renamed to `Rematch_Community.toc` and titled `Rematch [Community]`.
- All texture paths (`Interface\AddOns\Rematch\textures\…`) repathed to
  `Interface\AddOns\Rematch_Community\textures\…`.
- Version-display lookups read from `Rematch_Community` first, falling back
  to `Rematch` so you still see a sane version string in the options panel.
- SavedVariables are identical to the original — same `Rematch5SavedTeams`,
  `Rematch5Settings`, etc. Your data is shared.
- New runtime warning in `main/main.lua` prints in chat and the error frame
  if the original `Rematch` addon is also loaded.

## Things deliberately not changed

- Addon message prefix is still `"Rematch"` so you can still send/receive
  teams to/from users running the original.
- LDB launcher object name is still `"Rematch"` so existing data brokers
  (Bazooka, ChocolateBar, etc.) keep their button.
- The user-facing window title still says "Rematch" — the `[Community]` tag
  is in the AddOns list, not in your gameplay UI.

## If something still breaks

If you're still hitting a Lua error after this fork:

1. Note the **exact error text and the line it references**. Without the
   error text any fix is a guess.
2. Open `/console scriptErrors 1` so the default error frame surfaces
   problems; or install BugSack/!BugGrabber for a proper log.
3. Save and share the error block (file + line + stack).

The audit that produced this patch list was thorough but bounded to known
breakage patterns. If something else is wrong, the error text will point
straight at the offender.

## Credit

Original Rematch is the work of **Gello** — a remarkable addon that this
fork only patches. All design and architecture credit belongs to the
original author.
