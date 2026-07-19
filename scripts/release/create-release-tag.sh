#!/usr/bin/env bash
set -euo pipefail

initial_tag="${INITIAL_TAG:-v0.1.0}"
tag_pattern="${TAG_PATTERN:-v[0-9]*.[0-9]*.[0-9]*}"
bump="${BUMP:-patch}"
notes_path="${RELEASE_NOTES_PATH:-release-notes.md}"
push_tag="${PUSH_TAG:-true}"

latest_tag="$(git tag --list "${tag_pattern}" --sort=-v:refname | head -n 1)"

if [ -z "${latest_tag}" ]; then
  next_tag="${initial_tag}"
else
  version="${latest_tag#v}"
  IFS='.' read -r major minor patch <<< "${version}"

  case "${bump}" in
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    patch)
      patch=$((patch + 1))
      ;;
    *)
      echo "Unsupported BUMP value: ${bump}. Use major, minor, or patch." >&2
      exit 1
      ;;
  esac

  next_tag="v${major}.${minor}.${patch}"
fi

{
  echo "## Changes"
  echo
  if [ -z "${latest_tag}" ]; then
    git log --pretty=format:'- %s (%h)' --no-merges
  else
    git log "${latest_tag}..HEAD" --pretty=format:'- %s (%h)' --no-merges
  fi
} > "${notes_path}"

git tag "${next_tag}"

if [ "${push_tag}" = "true" ]; then
  git push origin "${next_tag}"
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "latest_tag=${latest_tag}" >> "${GITHUB_OUTPUT}"
  echo "next_tag=${next_tag}" >> "${GITHUB_OUTPUT}"
  echo "release_notes_path=${notes_path}" >> "${GITHUB_OUTPUT}"
fi

echo "Created release tag ${next_tag}"
