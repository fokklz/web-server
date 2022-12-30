#!/bin/bash
# Webpage-teil des Skripts

# erstellt die basis inhalte fuer die webseite
create_webpage_base_structure(){
    if [ ! -f "$pages_dir/index.html" ]; then
        cat > "$pages_dir/index.html" <<- EOM
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Willkommen auf $domain</title>
</head>
<body>
    <h1>$domain</h1>
    <p>auch erreichbar unter: ${sub_domains[@]}<p>
</body>
</html>
EOM
    fi
}

# erweitert die aktuelle NGINX konfiguration
extend_nginx_webpage_config(){
    # erweitert die NGINX konfiguration
    cat >> $nginx_config <<- EOM
server {
    listen 443 ssl http2;
    server_name "$domain" ${sub_domains[@]};
    root /var/www/pages/$domain_config;

    include /etc/nginx/cmodules/general.conf;
    include /etc/nginx/cmodules/ssl.conf;

    ssl_certificate         /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/$domain/chain.pem;

    include /etc/nginx/cmodules/security.conf;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}           
EOM
}