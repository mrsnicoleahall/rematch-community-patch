#!/usr/bin/env bash
# One-shot script to push the Rematch_Community fork to GitHub.
# Run from the addon folder on your Mac. Requires git + GitHub auth set up
# (HTTPS with a PAT in your keychain, or SSH key, or `gh auth login`).
set -euo pipefail
cd "$(dirname "$0")"
echo "==> Working in $(pwd)"

# Clean any stale partial git state from previous attempts.
if [ -d .git ]; then
  echo "==> Removing existing .git (will reinitialize)"
  rm -rf .git
fi

echo "==> git init"
git init -q -b main
git config user.name "${GIT_USER_NAME:-Nicole Hall}"
git config user.email "${GIT_USER_EMAIL:-NicoleHall@attorneyassistant.com}"

echo "==> git add -A"
git add -A

echo "==> git commit"
git commit -q -m "Initial commit: Rematch community fork v5.3.1-community.1

Community-maintained fork of Rematch 5.3.1 by Gello, with bug fixes for
WoW The War Within (Interface 11.x / 12.x).

Major fixes:
- Team rename/delete: fixed copyTeam source mutation + DeleteTeam double-fire
- Pet list empty on login: migrated LE_PET_JOURNAL_FILTER_* to Enum.PetJournalFilter
- MoveTeam: now handles group-to-group moves (was favorites-only)
- 15+ nil guards, off-by-one fixes, divide-by-zero guards, undefined-upvalue fixes

New feature:
- Inline + Create New Group option in the Save Team dialog group picker

Original Rematch by Gello. Patches tagged [Community fix] / [Community feature]."

echo "==> git remote add origin"
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/mrsnicoleahall/rematch-community-patch.git

echo "==> git push -u origin main"
git push -u origin main

echo ""
echo "Done. Repo is live at https://github.com/mrsnicoleahall/rematch-community-patch"
