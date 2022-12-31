#!/bin/bash
# Wordpress-teil des Skripts

# erhöht den wordpress port innerhalb der Wordpress Port datei
level_wordpress_port(){
    source $wordpress_port_file
    wordpress_port=$((wordpress_port+2))
    wordpress_phpmyadmin_port=$((wordpress_port+1))
    echo "wordpress_port=$wordpress_port" > $wordpress_port_file
}

# start und stop dateien erstellen und starten
setup_wordpress(){
    # erstellen einer start-sh fuer einfaches starten
    cat > "$working_dir/webctl/start_${domain_config}.sh" <<- EOM
cd $working_dir/$wordpress_dir
docker compose up -d
EOM
    # erstellen einer stop-sh fuer einfaches beenden
    cat > "$working_dir/webctl/stop_${domain_config}.sh" <<- EOM
cd $working_dir/$wordpress_dir
docker compose down
EOM
    # rechte aktualiaieren um das ausfuehren zu gestatten
    chmod +x "$working_dir/webctl/start_${domain_config}.sh"
    chmod +x "$working_dir/webctl/stop_${domain_config}.sh"
}

# erweitert die aktuelle NGINX konfiguration
extend_nginx_wordpress_config(){
    # erweitert die NGINX konfiguration
    cat >> $nginx_config <<- EOM
server {
    listen 443 ssl http2;
    server_name "$domain" ${sub_domains[@]};

    ssl_certificate         /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/$domain/chain.pem;
    
    # global gzip on
    gzip on;
    gzip_min_length 10240;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
    gzip_disable "MSIE [1-6]\.";

    add_header Cache-Control public;

    location / {
        proxy_pass http://$ip:$wordpress_port;
        proxy_buffering on;
        proxy_buffers 12 12k;
        proxy_redirect off;
        include /etc/nginx/cmodules/proxy.conf;
    }
}
server {
    listen 443 ssl http2;
    server_name "phpmyadmin.$domain";

    ssl_certificate         /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/$domain/chain.pem;

    location / {
        proxy_pass http://$ip:${wordpress_phpmyadmin_port};
        include /etc/nginx/cmodules/proxy.conf;
    }
}
EOM
}
