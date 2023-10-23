#! /usr/bin/env bash

if [[ -z "$1" || "$1" == "help" ]]; then
    script_name="$(basename "$0")"
    echo -e "Control script for nixos-rebuild\n"
    echo -e "Usage: ${script_name} <command>\n"
    echo "Commands:"
    echo -e "\tswitch"
    echo -e "\ttest"
    echo -e "\tclean"
    echo -e "\pi-image"

elif [[ "$1" == "switch" ]]; then
    sudo nixos-rebuild switch --flake .
elif [[ "$1" == "test" ]]; then
    sudo nixos-rebuild test --flake .
elif [[ "$1" == "clean" ]]; then
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system
    sudo nix store gc --debug
elif [[ "$1" == "pi-image" ]]; then
    nix build .#nixosConfigurations.pi.config.system.build.sdImage
else
    echo "ERROR: Command $1 not found. Aborting!"
    echo "Use help"
    exit 1
fi

exit 0
