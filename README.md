# Pure Pixel 17 platform integration for Lenovo TB132FU

This repository contains the source-only Android 17 platform patch set used by
Pure Pixel 17 R1 on the Lenovo Tab P11 Pro (2nd Gen), model TB132FU.

It complements the public projects below:

- [TB132FU Android 17 device tree](https://github.com/error311/android_device_lenovo_tb132fu)
- [TB132FU kernel #13](https://github.com/error311/tb132fu-kernel/tree/tb132fu-purepixel17-r1-k13)

The patches are final net diffs against pinned AOSP `android17-release` project
bases. They cover the legacy 4.19 BPF/ION/VINTF compatibility contract,
Bluetooth handling, charger policy, TB132FU Settings/SystemUI integration,
AOD/pen/cover behavior, refresh and cursor behavior, and the two narrow
Android 17 Pixel Launcher platform hooks used by R1.

## Scope and publication boundary

This is not a complete Android source tree or a standalone ROM. It contains no
Google or Lenovo applications, GApps payloads, Pixel Launcher APK, proprietary
vendor blobs, signing keys, partition images, device logs, recordings, or
userdata. The optional Google/Pixel package composition used by Pure Pixel is
intentionally separate and is not published here.

Thirteen projects have non-empty final patches. `system/apex` is retained in
`PROJECTS.tsv` for exact R1 provenance, but its two temporary diagnostic commits
cancel completely; its qualified tree equals the pinned AOSP base, so no patch
or diagnostic instrumentation is published.

Several changes—especially the fixed-QSB handoff and transient-taskbar endpoint
hooks in `frameworks/base`—are specific to the Android 17 CP2A/QPR baseline.
They must be reviewed and retested rather than carried blindly onto a later QPR.

## Pinned inputs

- AOSP branch family: `android17-release`
- Pure Pixel build ID: `CP2A.260605.016`
- R1 platform tag: `purepixel17-r1-platform`
- Per-project base and qualified topic revisions: `PROJECTS.tsv`
- Patch hashes: `PATCHES.sha256`

`manifest/tb132fu-platform-bases.xml` contains only public AOSP project pins.
It deliberately excludes the private Google/Pixel local manifest.

## Applying the patches

Start with a clean AOSP Android 17 checkout. Copy or symlink the included base
manifest into `.repo/local_manifests`, sync the listed projects, and run the
guarded apply helper:

```sh
mkdir -p /path/to/aosp/.repo/local_manifests
cp manifest/tb132fu-platform-bases.xml \
  /path/to/aosp/.repo/local_manifests/tb132fu-platform-bases.xml

cd /path/to/aosp
repo sync build/soong frameworks/base frameworks/native hardware/interfaces \
  kernel/configs packages/apps/Settings packages/modules/Bluetooth \
  packages/modules/Connectivity system/apex system/bpf system/bpfprogs \
  system/core system/memory/libion system/sepolicy

cd /path/to/purepixel17-tb132fu-platform
./apply-patches.sh /path/to/aosp
```

The helper fails unless every target project is clean and checked out at its
exact pinned base. It verifies `PATCHES.sha256`, checks each patch before
application, and confirms through an isolated temporary index that the result
matches the exact qualified R1 Git tree. It leaves the checkout's real index
untouched and does not commit, reset, clean, build, flash, or contact a device.

After applying this platform set, add the public TB132FU device tree at
`device/lenovo/tb132fu`, provide the locally required proprietary inputs
described by that tree, and use the separately documented kernel/boot pipeline.

## Licensing

Repository-authored documentation and helper scripts are licensed under
Apache-2.0. Each patch remains subject to the license and notices of its target
AOSP project and files. No license or redistribution permission for external
proprietary components is granted here.
