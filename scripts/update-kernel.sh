#!/usr/bin/env bash
#
# Update the flake inputs and report whether that actually moved the kernel or
# the ZFS module.
#
# The kernel is not pinned anywhere: neuland-kernel.nix picks the newest LTS
# kernel in nixpkgs that still has a working ZFS module, so "is there a new
# kernel?" is answered by bumping flake.lock and re-evaluating.
#
# flake.lock is left modified when something moved and restored when nothing
# did, so a caller can update, build and commit without a second check.
#
#   scripts/update-kernel.sh          # check, update flake.lock if it matters
#   FORCE=true scripts/update-kernel.sh   # keep the new lock either way
#   SYSTEM=aarch64-linux scripts/update-kernel.sh
#
# When $GITHUB_OUTPUT is set (Forgejo/GitHub Actions), these are written to it:
#   updated         true|false
#   kernel_before   kernel_after
#   zfs_before      zfs_after
#   nixpkgs_before  nixpkgs_after
#   subject         one-line commit subject
#   message_file    path to the full commit message

set -euo pipefail

system="${SYSTEM:-x86_64-linux}"
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

case "${FORCE:-}" in
  true | 1 | yes) force=true ;;
  *) force=false ;;
esac

if ! git diff --quiet -- flake.lock; then
  echo "error: flake.lock has uncommitted changes, refusing to overwrite them" >&2
  exit 1
fi

version_of() {
  nix eval --raw ".#packages.${system}.$1.version"
}

locked_rev() {
  nix eval --raw --impure \
    --expr "(builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.$1.locked.rev"
}

kernel_before="$(version_of neuland-kernel)"
zfs_before="$(version_of neuland-zfs)"
nixpkgs_before="$(locked_rev nixpkgs)"

echo "current: linux ${kernel_before}, zfs ${zfs_before} (nixpkgs ${nixpkgs_before:0:7})"

nix flake update

kernel_after="$(version_of neuland-kernel)"
zfs_after="$(version_of neuland-zfs)"
nixpkgs_after="$(locked_rev nixpkgs)"

echo "updated: linux ${kernel_after}, zfs ${zfs_after} (nixpkgs ${nixpkgs_after:0:7})"

changes=""
if [ "$kernel_before" != "$kernel_after" ]; then
  changes="kernel ${kernel_before} -> ${kernel_after}"
fi
if [ "$zfs_before" != "$zfs_after" ]; then
  changes="${changes:+${changes}, }zfs ${zfs_before} -> ${zfs_after}"
fi

updated=true
if [ -z "$changes" ]; then
  if [ "$force" = true ]; then
    changes="nixpkgs ${nixpkgs_before:0:7} -> ${nixpkgs_after:0:7}"
    echo "no kernel or zfs change, but FORCE is set: keeping the new lock"
  else
    updated=false
    git checkout -- flake.lock
    echo "no kernel or zfs change, flake.lock restored"
  fi
fi

subject="chore: ${changes:-nothing to update}"

message_file="${MESSAGE_FILE:-${RUNNER_TEMP:-${TMPDIR:-/tmp}}/neuland-kernel-update-msg}"
{
  echo "$subject"
  echo
  echo "linux:   ${kernel_before} -> ${kernel_after}"
  echo "zfs:     ${zfs_before} -> ${zfs_after}"
  echo "nixpkgs: ${nixpkgs_before} -> ${nixpkgs_after}"
} >"$message_file"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "updated=${updated}"
    echo "kernel_before=${kernel_before}"
    echo "kernel_after=${kernel_after}"
    echo "zfs_before=${zfs_before}"
    echo "zfs_after=${zfs_after}"
    echo "nixpkgs_before=${nixpkgs_before}"
    echo "nixpkgs_after=${nixpkgs_after}"
    echo "subject=${subject}"
    echo "message_file=${message_file}"
  } >>"$GITHUB_OUTPUT"
fi

if [ "$updated" = true ]; then
  echo
  echo "$subject"
fi
