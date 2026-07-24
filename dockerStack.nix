{ config, pkgs, ... }: {

	virtualisation.docker = {
		enable = true;
		autoPrue = {
			enable = true;
			dates = 'weekly";
		};
	};

	users.users.evelynn.extraGroups = [ "docker" ];

	networking.firewall.allowedTCPPorts = [];

	systemd.tmpfiles.rules = [
		"d /data/nextcloud 0755 evelynn users -"
		"d /data/navidrome 0755 evelynn users -"
		"d /data/blog 0755 evelynn users -"
		"d /data/media/ 0755 evelynn users -"
		"d /data/caddy 0755 evelynn users -"
	];

	virtualisation.oci-containers = {
		backend = "docker";

		containers = {
			nextcloud = {
				image = "nextcloud:latest";
				autostart = true;

				ports = [ "8080:80 ];

				volumes = [
					"/data/nextcloud:/var/www/html"
				];

				enviroment = {
					NEXTCLOUD_ADMIN_USER = "admin";

					# TODO: update domain
					NEXTCLOUD_TRUSTED_DOMAINS = "cloud.example.com";
				};
				
				# TODO: uncomment this part
				# enviromentFiles = [ config.sops.secrets."nextcloud-env".path ];
			};
			
			navidrome = {
				image = "deluan/navidrome:latest";
				autoStart = true;
				
				ports = [ "4533:4533" ];

				volumes = [
					"/data/navidrome:/data"
					"/data/media/music:/music:ro"
				];
			};

			blog = {
				image = "ghost:5-alpine";
				autoStart = true;

				ports [ "2368:2368" ];

				volumes = [
					"/data/blog:/var/lib/ghost/content"
				];

			#	enviroment.url = "https://example.com";
			};

			caddy = {
				image = "caddy:latest";
				autoStart = true;

				ports = [ "80:80" ];

				volumes = [
					"/data/caddy/Caddyfile:/etc/caddy/Caddyfile:ro"
				];
			};

			
		};
	};
}
