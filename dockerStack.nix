{ config, pkgs, ... }: {

	virtualisation.docker = {
		enable = true;
		autoPrune = {
			enable = true;
			dates = "weekly";
		};
	};

	users.users.evelynn.extraGroups = [ "docker" ];

	sops.defaultSopsFile = ./secrets.yaml;
	sops.age.keyFile = "/var/lib/sops-nix/key.txt";

	sops.secrets."nextcloud-env" = { };
	sops.secrets."cloudflared-env" = { };

	networking.firewall.allowedTCPPorts = [];

	systemd.tmpfiles.rules = [
		"d /data/nextcloud 0755 evelynn users -"
		"d /data/navidrome 0755 evelynn users -"
		"d /data/blog 0755 evelynn users -"
		"d /data/media/ 0755 evelynn users -"
		"d /data/caddy 0755 evelynn users -"
		"d /data/media/music 0777 evelynn users -"
	];

	virtualisation.oci-containers = {
		backend = "docker";

		containers = {
			nextcloud = {
				image = "nextcloud:latest";
				autoStart = true;

				ports = [ "8080:80" ];

				volumes = [
					"/data/nextcloud:/var/www/html"
					"/data/media/music:/mnt/music-library"
				];

				environment = {
					NEXTCLOUD_ADMIN_USER = "admin";

					# TODO: update domain
					NEXTCLOUD_TRUSTED_DOMAINS = "cloud.harmonichell.com";
				};
				
				environmentFiles = [ config.sops.secrets."nextcloud-env".path ];
			};
			
			navidrome = {
				image = "deluan/navidrome:latest";
				autoStart = true;
				
				ports = [ "4533:4533" ];

				volumes = [
					"/data/navidrome:/data"
					"/data/media/music:/music:ro"
				];

				environment = {
					ND_SCANSCHEDULE = "1h";
				};
			};

			blog = {
				image = "ghost:5-alpine";
				autoStart = true;

				ports = [ "2368:2368" ];

				volumes = [
					"/data/blog:/var/lib/ghost/content"
				];

			#	environment.url = "https://harmonichell.com";
			};

			caddy = {
				image = "caddy:latest";
				autoStart = true;

				ports = [ "80:80" ];

				volumes = [
					"/data/caddy/Caddyfile:/etc/caddy/Caddyfile:ro"
				];
			};

		 	cloudflared = {
				image = "cloudflare/cloudflared:latest";
				autoStart = true;

				# tells cloudflared to run as a tunnel
				cmd = [ "tunnel" "--no-autoupdate" "run" ];

				#let the container access the other networks
				extraOptions = [ "--network=host" ];

				environmentFiles = [ config.sops.secrets."cloudflared-env".path ];
			};	
		};
	};
}
