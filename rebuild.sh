#!/usr/bin/env bash

set -e

warn() {
    echo -e "\e[1;33m$1\e[0m"
}

err() {
    echo -e "\e[1;31m$1\e[0m"
}

fatal() {
    err "$1" >&2
    exit 1
}

BUILD_SYSTEM=false
BUILD_HOME=false
FLAKE_TAG=""

usage() {
    echo "Usage: $0 [-n|--nixos] [-u|--user] [-h|--help] [FLAKE_TAG]"
    echo "  -s, --system   Build system configuration"
    echo "  -u, --user     Build home configuration"
    echo "  -h, --help     Show this help message"
    exit 0
}

OPTIONS=$(getopt -o suh --long nixos,user,help -- "$@") || exit 1
eval set -- "$OPTIONS"

while true; do
    case "$1" in
    -s | --system)
        BUILD_SYSTEM=true
        shift
        ;;
    -u | --user)
        BUILD_HOME=true
        shift
        ;;
    -h | --help) usage ;;
    --)
        shift
        break
        ;;
    *)
        FLAKE_TAG="$1"
        shift
        ;;
    esac
done

if [ -n "$FLAKE_TAG" ] && [[ ! "$FLAKE_TAG" =~ "^#" ]]; then
    FLAKE_TAG="#$FLAKE_TAG"
fi

if [ "$BUILD_SYSTEM" = false ] && [ "$BUILD_HOME" = false ]; then
    warn "No configuration specified."
    warn "Specify -s|--system and/or -u|--user to build system or home configuration."
    exit 0
fi

SCRIPT_PATH="$(realpath "$(dirname "$(realpath "$0")")")"

# Check if all git submodules have been initialized and updated
submodule_status="$(git -C "$SCRIPT_PATH" submodule status --recursive | grep "^-" || true)"
if [ -n "$submodule_status" ]; then
    warn "There are uninitialized or outdated submodules:"
    echo "$submodule_status"
    echo
    read -p "Do you want to initialize/update submodules? [yN] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git -C "$SCRIPT_PATH" submodule update --init --recursive
    else
        fatal "Aborting."
    fi
fi

if [ -n "$(git -C "$SCRIPT_PATH" ls-files --others --exclude-standard)" ]; then
    warn "There are untracked files:"
    git -C "$SCRIPT_PATH" ls-files --others --exclude-standard
    echo
    read -p "Do you want to continue? [yN] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        fatal "Aborting."
    fi
fi

if [ -n "$(git -C "$SCRIPT_PATH" status --porcelain)" ]; then
    warn "There are unstaged changes:"
    git -C "$SCRIPT_PATH" status --porcelain
    echo
    read -p "Do you want to continue? [Yn] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        fatal "Aborting."
    fi
fi

if [ "$BUILD_SYSTEM" = true ]; then
    echo "Rebuilding NixOS configuration..."
    sudo nixos-rebuild switch --impure --flake "$SCRIPT_PATH$FLAKE_TAG"
fi

if [ "$BUILD_HOME" = true ]; then
    echo "Rebuilding home-manager configuration..."
    home-manager switch --flake "$SCRIPT_PATH$FLAKE_TAG?submodules=1"
fi
