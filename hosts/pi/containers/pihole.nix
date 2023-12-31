{ config, pkgs, ... }:


{

#  system.activationScripts.create-podman-volumes =
#    let
#      pihole_etc = "/var/lib/services/pihole/etc";
#      pihole_dnsmasq = "/var/lib/services/pihole/etc-dnsmasq.d";
#    in
#    {
#      text = ''
#        			[[ ! -d "${pihole_etc}" ]] && mkdir -p "${pihole_etc}"
#        			[[ ! -d "${pihole_dnsmasq}" ]] && mkdir -p "${pihole_dnsmasq}"
#        		'';
#    };

  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:2023.11.0";
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "80:80/tcp"
    ];
    volumes = [
      "/zpool/services/pihole/etc:/etc/pihole"
      "/zpool/services/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
    ];
    environment = {
      TZ = "Europe/Berlin";
    };
  };
}
