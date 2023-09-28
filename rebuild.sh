#!/run/current-system/sw/bin/bash -e

if [[ -z "$1" || "$1" == "help" ]]; then
    script_name="$(basename "$0")"
    echo -e "Control script for nixos-rebuild\n"
    echo -e "Usage: ${script_name} <command>\n"
    echo "Commands:"
    echo -e "\tswitch"
    echo -e "\tboot"

elif [[ "$1" == "switch" ]]; then
    sudo cp *.nix /etc/nixos/ && sudo nixos-rebuild switch
elif [[ "$1" == "boot" ]]; then
    sudo cp *.nix /etc/nixos/ && sudo nixos-rebuild boot
else
    echo "ERROR: Command $1 not found. Aborting!"
    echo "Use help"
    exit 1
fi

exit 0
