#!/usr/bin/env bash
set -euo pipefail

tag="${RELEASE_TAG:-}"
notes_path="${RELEASE_NOTES_PATH:-release-notes.md}"
draft="${DRAFT_RELEASE:-false}"
prerelease="${PRERELEASE:-false}"

if [ -z "${tag}" ]; then
  echo "RELEASE_TAG is required." >&2
  exit 1
fi

args=(
  "release"
  "create"
  "${tag}"
  "--title"
  "${tag}"
  "--notes-file"
  "${notes_path}"
)

if [ "${draft}" = "true" ]; then
  args+=("--draft")
fi

if [ "${prerelease}" = "true" ]; then
  args+=("--prerelease")
fi

gh "${args[@]}"
