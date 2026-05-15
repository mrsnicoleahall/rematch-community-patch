# rematch-community-patch

A community-maintained patch of **Rematch 5.3.1** by Gello, with bug fixes for
WoW The War Within (Interface 11.x / 12.x). Drop-in replacement that shares
SavedVariables with the original Rematch.

## What this fixes

- **Team rename / delete actually work again.** The `copyTeam` helper mutated
  the source team's name in-place (and crashed on nil names), and `DeleteTeam`
  double-fired `TeamsChanged()` which raced its own listeners against the
  just-deleted teamID.
- **Pet list isn't empty on login anymore.** Migrated the removed
  `LE_PET_JOURNAL_FILTER_COLLECTED` / `LE_PET_JOURNAL_FILTER_NOT_COLLECTED`
  globals to `Enum.PetJournalFilter.Collected` / `.NotCollected` (TWW
  removed the old constants).
- **Group-to-group team moves work.** `MoveTeam` previously only handled
  moves in/out of favorites, silently no-op'ing every other move.
- **Inline group creation in the Save Team dialog.** The group picker now
  has a `+ Create New Group...` entry, so you don't have to leave the save
  flow to create a group.
- 15+ smaller nil guards, off-by-one fixes, divide-by-zero guards, fragile
  text-parse fixes, and undefined-upvalue fixes scattered across
  `loadTeam.lua`, `petInfo.lua`, `collectionInfo.lua`, `savedGroups.lua`,
  and `teamMenu.lua`.

Every patched line is tagged `[Community fix]` or `[Community feature]` in a
comment.

## Installation

1. Place the `Rematch_Community/` folder in
   `World of Warcraft/_retail_/Interface/AddOns/`.
2. **Disable the original Rematch** on the AddOns screen (both addons share
   global frame names like `RematchFrame`).
3. Enable **Rematch [Community]**. The fork tags itself with a blue
   `[Community]` badge in the AddOns list.
4. Log in. If you forgot step 2 the addon prints a chat warning at login.

Your existing teams, groups, targets, and settings carry over — the fork
declares the same `Rematch5SavedTeams`, `Rematch5SavedGroups`, etc. in its
TOC. If WoW already created a fresh empty SavedVariables file for
`Rematch_Community.lua` and you want to recover your old teams, copy
`Rematch.lua.bak` over `Rematch_Community.lua` in your account's
SavedVariables folder while you're at character select.

## Compatibility

- **Tested against:** TOC 120000 (TWW 12.0). Should also work on 11.x.
- **Compatible with:** team-string imports from upstream Rematch, the
  cross-realm Send Team feature (addon message prefix is still `"Rematch"`),
  Rematch_TSMPetValues, tdBattlePetScript.

## Credit

Original Rematch is the work of **Gello** — a remarkable addon. This fork
only patches; all design and architecture credit belongs to the original
author.

## License

Inherits the original Rematch license. This patch is offered in the same
spirit — use it freely, fix what you find, share back if you can.
