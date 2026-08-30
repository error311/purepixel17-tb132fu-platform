# Pure Pixel 17 platform patches for TB132FU

This is the Android platform side of Pure Pixel 17 for the Lenovo Tab P11 Pro
(2nd Gen), model TB132FU.

The device needs more than a device tree and kernel to run Android 17 properly.
These patches are the framework and system changes retained in the public R5
release plus the current R6 development-line additions. They are kept here
separately because they belong to existing AOSP projects rather than
`device/lenovo/tb132fu`.

The other two source repositories are:

- [TB132FU device tree](https://github.com/error311/android_device_lenovo_tb132fu)
- [TB132FU kernel](https://github.com/error311/tb132fu-kernel)

## What is included

The patch set covers:

- the audited August 2026 platform security-level declaration
- Android 17 support for the tablet's legacy 4.19 kernel
- BPF, ION and VINTF compatibility
- Bluetooth, Bluetooth-audio compatibility and charger fixes
- TB132FU Settings and SystemUI features
- pen, keyboard-cover and AOD behavior
- refresh-rate, cursor and display behavior
- battery-health details and MediaTek picture-quality color modes
- AOD mode handling and landscape unlock-side placement
- immediate double-tap wake across AOD entry and the post-wake false-touch fix
- rotation-safe camera privacy-indicator placement when immersive UI hides the
  status bar
- rotation-aware power-button light-reveal placement for the tablet chassis
- optional camera-based convenience face unlock
- themed face-enrollment feedback, tablet wording, and removal of stale
  fingerprint wording from credential/PIN setup
- pen attach, detach and battery-status polish
- the factory-reset-qualified Pixel Setup language/region selector and its
  no-action-bar crash guard
- optional TB132FU-only convenience Face enrollment after creating a screen
  lock in Pixel Setup, with the temporary Gatekeeper handle kept inside
  Settings
- native Settings placement for refresh rate, double-tap wake, AOD daytime
  scheduling, Precision Pen, and pogo keyboard/touchpad controls
- the exact Pure Pixel incremental build identity on Android version
- Pure Pixel updater branding in locale-visible labels
- cacheless, signed A-only recovery updates on the active slot
- the small platform hooks used to synchronize the Pixel Launcher landscape
  QSB return animation and its live dock owner

These are the accepted release-line diffs, not the full bring-up history. Temporary tests and
reverted experiments were left out. `system/apex` is listed in `PROJECTS.tsv`
because it was part of the bring-up, but its final tree matches clean AOSP and
there is no patch to apply.

## R5 base

- AOSP branch: `android17-release`
- Android build: `CP2A.260605.016`
- Android platform security patch: `2026-08-01`
- Release line: `purepixel17-tb132fu-r5`
- Project revisions and expected trees: `PROJECTS.tsv`
- Patch checksums: `PATCHES.sha256`

The QSB/taskbar changes in `frameworks/base` are tied to this Android 17
release. Check whether Google has fixed the original problem before carrying
them into a later QPR.

## Applying the patches

Start with a clean AOSP checkout. Add the pinned manifest, sync the affected
projects, and run the helper:

```sh
mkdir -p /path/to/aosp/.repo/local_manifests
cp manifest/tb132fu-platform-bases.xml \
  /path/to/aosp/.repo/local_manifests/tb132fu-platform-bases.xml

cd /path/to/aosp
repo sync build/release build/soong frameworks/base frameworks/native hardware/interfaces \
  bootable/recovery build/make kernel/configs packages/apps/FaceUnlock \
  packages/apps/Settings packages/apps/Updater packages/modules/Bluetooth \
  packages/modules/Connectivity system/apex system/bpf system/bpfprogs \
  system/core system/memory/libion system/sepolicy

cd /path/to/purepixel17-tb132fu-platform
./apply-patches.sh /path/to/aosp
```

The script intentionally refuses to patch a dirty or mismatched source tree.
It checks the patch hashes and confirms that the result matches the exact R5
Git trees. It does not commit anything, erase source, start a build or touch a
connected device.

Afterward, add the device tree at `device/lenovo/tb132fu` and supply the vendor
files required for your own build.

## What is not included

This is source code only. It does not contain a ROM, GApps, Pixel Launcher,
Google or Lenovo APKs, vendor blobs, signing keys, device logs or user data.

## License

The README and helper script are Apache-2.0 licensed. Individual patches keep
the licensing terms of the AOSP projects and files they modify.
