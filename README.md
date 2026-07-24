A simple secure nixos server

The Caddy file located at /data/caddy/Caddyfile/Caddyfile
{
        auto_https off
}

http://music.harmonichell.com:80 {
        reverse_proxy localhost:4533
}

http://cloud.harmonichell.com:80 {
        reverse_proxy localhost:8080
}

http://blog.harmonichell.com:80 {
        reverse_proxy localhost:2368
}

Cloudflaired configured in dashboard to point each domain at http://localhost:80
