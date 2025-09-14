# Audio Setup

This directory contains a basic audio pipeline for the project.

## Mixer
`Mixers/GameAudioMixer.mixer` defines the master mixer with groups
`Master`, `Music`, `SFX`, `Ambience`, `UI` and a `FX_Returns/ReverbReturn`
bus. Group volumes and the low‑pass cutoff are exposed parameters.

## Scripts
- **DistanceLowpass** – drives the `SFX_LPF_Cutoff` parameter based on distance
  from the listener so far sounds are slightly muffled.
- **SimpleOcclusion** – raycasts to the listener and applies additional
  volume and low‑pass when an obstacle blocks the sound.
- **AudioSnapshotsController** – switches between Outdoor, Indoor and Pause
  snapshots on the mixer.
- **AudioSetupWizard** – editor window under `Tools/Audio Setup Wizard`
  to unify listeners and route selected AudioSources.

## Prefab and Test Scene
`Prefabs/AudioRoot.prefab` and `Test/AudioTestScene.unity` are placeholders for
integration. Drop `AudioRoot` in a scene to get snapshot control and a baseline
AudioListener.

## Usage
1. Ensure there is only one active `AudioListener` (usually on `MainCamera`).
2. Route music and SFX sources to the appropriate mixer groups.
3. Attach `DistanceLowpass` and `SimpleOcclusion` to 3D sound emitters as needed.
4. Use `AudioSnapshotsController` to transition between Outdoor, Indoor and
   Pause states.

Refer to comments in the scripts for further details.
