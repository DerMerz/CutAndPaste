# CutAndPaste (Cut & Place) — Localized Mac App Store Screenshots

## Status
- ASC version 1.0 has 9 locales created (en-US + 8 targets), state PREPARE_FOR_SUBMISSION
- Platform: macOS (set type APP_DESKTOP)
- en-US screenshots uploaded: 5 desktop captures (`screenshot_<N>_appstore_1440.png`)
  - screenshot_1 — "Finally. Real ⌘X." / "Cut & paste files the way it should have always worked."
  - screenshot_2 — "Cut. Navigate. Place." / "Three steps. Zero hassle." (3-step infographic with Cut/Navigate/Place labels)
  - screenshot_3 — "Lives in Your Menu Bar" / "Always ready. Never in your way." (menu bar dropdown screenshot)
  - screenshot_4 — "No Dragging. No Workarounds." / "The way you always expected it to work." (BEFORE/NOW comparison)
  - screenshot_5 — "Set Up in Seconds" / "One click. Ready to go." (Welcome window)
- AppScreens project: NONE for CutAndPaste. Existing en-US screenshots are hand-crafted compositions (Figma or similar).

## Translated headlines
Saved in `fastlane/metadata/screenshots_<locale>.json` for all 8 target locales.

Each screenshot has `headline` + `subhead`. The app UI labels in the captured Finder + menu-bar windows are largely
language-neutral or system-driven (Finder labels follow macOS system language). The custom labels in
screenshot_2 ("Cut/Navigate/Place" step badges) and screenshot_4 ("BEFORE/NOW" comparison columns)
need translation overlays.

## Workflow recommendation
Since these are non-AppScreens compositions, the practical paths are:
1. Open the original Figma/Sketch file (if available — check `/Users/kevinmerz/Apps/CutAndPaste/`)
2. Duplicate the artboard 8 times, replace headline + subhead per locale from JSON
3. Export each locale as 1440×900 PNG into `fastlane/screenshots/<locale>/`
4. fastlane deliver per Option A below

OR use a scripted compositor (Python PIL or Node sharp) to overlay translated text onto the en-US base PNGs:
- Base PNGs are at `/tmp/locscreens/dl_CutAndPaste/`
- Translated text in `fastlane/metadata/screenshots_<locale>.json`

## Per-locale upload via fastlane
(Requires `fastlane/api_key.json` to be created — currently MISSING for CutAndPaste.)
```bash
cd /Users/kevinmerz/Apps/CutAndPaste
fastlane deliver \
  --api_key_path fastlane/api_key.json \
  --app_identifier "de.merzkevin.cutandmove" \
  --screenshots_path fastlane/screenshots \
  --skip_metadata true --skip_binary_upload true --skip_app_version_update true \
  --force --overwrite_screenshots true --run_precheck_before_submit false \
  --submit_for_review false \
  --platform osx
```

## ASC locale IDs (for direct API uploads, 2026-05-16 snapshot)
- en-US: 764ac33d-b40e-4a2b-974c-d0d0d2afd41c
- de-DE: 5ba3f33b-8838-4556-b224-80f218fed2ee
- es-ES: 8db9b069-f793-4e3e-b948-a33907452775
- fr-FR: efdc1d96-bccb-48a2-890e-0ac491b500cd
- it: af92a0ea-c608-444a-bd03-07b25e01a8ae
- ja: 448f072b-3cd8-463a-9147-ce7884caecb3
- pt-BR: 1320e98e-d053-4839-bba7-7eb06ea5dd23
- zh-Hans: 2ef06e69-eb92-4aed-ba35-e6e8fd1d1c47
- ko: 85de5858-2c92-4fc6-87ed-0cdc8892c7fa
