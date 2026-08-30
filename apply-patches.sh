#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
aosp_root=${1:-}

if [[ -z "$aosp_root" || ! -d "$aosp_root/.repo" ]]; then
    echo "Usage: $0 /path/to/clean/aosp-root" >&2
    exit 2
fi

for tool in git sha256sum; do
    command -v "$tool" >/dev/null || {
        echo "Missing required host tool: $tool" >&2
        exit 1
    }
done

cd -- "$script_dir"
sha256sum --check PATCHES.sha256

temporary_index_dir=
cleanup_temporary_index() {
    if [[ -n "${temporary_index_dir:-}" && -d "$temporary_index_dir" ]]; then
        find "$temporary_index_dir" -maxdepth 1 -type f -delete
        rmdir -- "$temporary_index_dir"
    fi
}
trap cleanup_temporary_index EXIT

while IFS=$'\t' read -r project upstream base_revision topic_head qualified_tree patch_file; do
    [[ "$project" == project ]] && continue
    [[ -n "$project" && -n "$base_revision" && -n "$patch_file" ]] || {
        echo 'Malformed PROJECTS.tsv row.' >&2
        exit 1
    }

    project_dir="$aosp_root/$project"
    [[ -d "$project_dir/.git" || -f "$project_dir/.git" ]] || {
        echo "Missing AOSP project: $project" >&2
        exit 1
    }

    observed_head=$(git -C "$project_dir" rev-parse HEAD)
    [[ "$observed_head" == "$base_revision" ]] || {
        echo "$project is not at its pinned base." >&2
        echo "Expected: $base_revision" >&2
        echo "Observed: $observed_head" >&2
        exit 1
    }

    [[ -z $(git -C "$project_dir" status --porcelain) ]] || {
        echo "$project has local changes; refusing to apply patches." >&2
        exit 1
    }

    if [[ "$patch_file" == NONE ]]; then
        observed_tree=$(git -C "$project_dir" rev-parse 'HEAD^{tree}')
        [[ "$observed_tree" == "$qualified_tree" ]] || {
            echo "$project base tree does not match its qualified no-op tree." >&2
            exit 1
        }
        echo "$project: no net release-line patch required (qualified topic $topic_head)."
        continue
    fi

    absolute_patch="$script_dir/$patch_file"
    [[ -f "$absolute_patch" ]]
    git -C "$project_dir" apply --check "$absolute_patch"

    temporary_index_dir=$(mktemp -d "${TMPDIR:-/tmp}/tb132fu-platform-index.XXXXXX")
    temporary_index="$temporary_index_dir/index"
    GIT_INDEX_FILE="$temporary_index" git -C "$project_dir" read-tree "$base_revision"
    GIT_INDEX_FILE="$temporary_index" git -C "$project_dir" update-index --refresh
    GIT_INDEX_FILE="$temporary_index" git -C "$project_dir" apply --index "$absolute_patch"
    observed_tree=$(GIT_INDEX_FILE="$temporary_index" git -C "$project_dir" write-tree)
    cleanup_temporary_index
    temporary_index_dir=

    [[ "$observed_tree" == "$qualified_tree" ]] || {
        echo "$project applied tree does not match its qualified tree." >&2
        echo "Expected: $qualified_tree" >&2
        echo "Observed: $observed_tree" >&2
        exit 1
    }

    echo "$project: applied $patch_file"
done < PROJECTS.tsv

echo 'All pinned Pure Pixel 17 platform patches applied successfully.'
echo 'No commit, build, flash, reset, clean, or device operation was performed.'
