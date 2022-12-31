#!/bin/bash
# Hauptteil des Webctl Scripts

# user Menu fuer die Core-Funktion des Skriptes
user_menu(){
    clear
    if [ ! -n "$1" ]; then
        echo "1 - Normale Webseite (HTML)"
        echo "2 - WordPress Webseite (Docker & Reverse Proxy)"
        echo "3 - Webseite Löschen"
        read -p 'Wähle eine Aktion: ' action
    else
        action=$1
    fi

    # alle nicht nummerischen zeichen von der eingabe entfernen
    action=${action//[!0-9]/:-0}

    # sicherstellen das die einhabe nicht ueber 3 liegt, da wir nicht mehr als 3 Optionen haben
    if [ "$action" -gt 3 ]; then
        # menu erneut öffnen
        user_menu
    fi

    # sicherstellen das die eingabe nicht unter 1 liegt, da wir keine negativen Menu einträge haben
    if [ "$action" -lt 1 ]; then
        # menu erneut öffnen
        user_menu
    fi

    case "$action" in
        "1")
            type="Normal"
        ;;
        "2")
            type="Wordpress"
        ;;
        "3")
            type="Delete"
        ;;
        *)
            type="ANY"
        ;;
    esac
}

# hilft beim auslesen der domain
read_domain() {
    clear
    if [ ! -n "$1" ]; then
        read -p 'Domain: ' domain
    else
        domain=$1
    fi

    # domain muss minimal 5 Zeichen lang sein
    if [ ${#domain} -lt 5 ]; then
        read_domain
    fi

    # domain muss minimal einen . beinhalten
    if [ ! $domain =~ "." ]; then
        read_domain
    fi

}
# hilft beim hochzaehlen eines existierenden namens
add_one_if_exists(){
    local name=$1
    local num=$2
    if [ -f "$config_base_dir/${name}_${num}.conf" ]; then
        add_one_if_exists $name $((num+1))
    else
        domain_config="${name}_${num}"
    fi
}
# hilft beim auslesen des Config Names
read_config_name() {
    clear
    # erstellt den namen basierend auf der domain
    temp_domain_config=$(echo "$domain" | cut -d "." -f 1)

    if [ ! -n "$1" ]; then
        # gibt die option den namen zu ueberschreiben
        read -p "Config-Name ($temp_domain_config):" domain_config
        if [ ${#domain_config} -le 1 ]; then
            domain_config=$temp_domain_config
        fi
    else
        domain_config=$1
    fi
    
    domain_config=${domain_config,,}

    # ueberpruefen das der Config Name länger als 1 Zeichen ist
    if [ ! ${#domain_config} -gt 1 ]; then
        read_config_name
    fi

    # erlaubt das direkte nutzen der config
    # wird von delete verwendet
    if [ "$2" = true ]; then
        build_vars
        if [ -f $config_file ]; then
            source $config_file
        fi
        build_vars
    else
        # ueberprueft ob die konfiguration bereits exisitiert
        if [ -f "$config_base_dir/$domain_config.conf" ]; then
            # zaehlen den namen fuer die config hoch wenn er bereits existiert
            add_one_if_exists $domain_config 1
        fi
    fi
}
# hilft beim auslesen der alternativen domains (subdomains)
read_subdomains() {
    clear
    if [ ! -n "$1" ]; then
        echo "Leerlassen um das Hinzufuegen von alternativ Domains zu beenden"
        sub_domains=()
        while true; do
            # nach weiteren sub domains fragen so lange bis die eingabe leer ist 
            read -p "Sub-Domain: " alt_domain
            if [ ${#alt_domain} -ge 1 ]; then
                sub_domains+=($alt_domain)
            else
                break
            fi
        done
    else
        # wenn alt. domains als parameter uebergeben werden, sollten diese mit comma getrennt werden
        IFS=',' read -ra sub_domains <<< "$1"
    fi
}

# erstellt alle benötigten variabeln
build_vars(){
    # konfigurations datei fuer die seite
    config_file="$config_base_dir/$domain_config.conf"
    # nginx konfiguration fuer die seite
    nginx_config="config/sites-enabled/$domain_config.conf"

    # for files (relative)
    pages_dir="pages/$domain_config"
    # wordpress daten
    wordpress_dir="$wordpress_base_dir/$domain_config"
    # wordpress port
    wordpress_port_file="$wordpress_base_dir/port"
    # ordner wo der gelöschte inhanlt hin soll
    deleted_dir="webctl/deleted/${domain_config}_${current_time}_${type,,}/"
}

write_initial_config(){
    mkdir -p $config_base_dir
    printf -v date '%(%Y-%m-%d %H:%M:%S)T\n' -1 
    cat > $config_file <<- EOM
domain=$domain
domain_config=$domain_config
sub_domains=${sub_domains[@]}
created="$date"
action=$action
type=$type
EOM
}

# erstellt die config datei fuer eine seite
write_config() {
    write_initial_config
    if [ "$action" = "2" ]; then
        cat > $config_file <<- EOM
domain=$domain
domain_config=$domain_config
sub_domains=${sub_domains[@]}
created="$date"
action=$action
type=$type
wordpress_port=$wordpress_port
wordpress_phpmyadmin_port=$wordpress_phpmyadmin_port
wordpress_db_user=${domain_config}_admin
wordpress_generated_db_password=$wordpress_generated_db_password
EOM
    fi
}

print_final() {
    clear
    echo ""
    echo "---- Seite Konfiguriert ----"
    echo ""
    echo "erreichbar unter: $domain"
    echo ""
    if [ -n "$sub_domains" ]; then
        echo "alternativ erreichbar unter:"
        echo "  ${sub_domains[@]}" 
    fi
    echo ""
    if [ "$action" = "2" ]; then
        echo "Wordpress muss Konfiguriert werden"
        echo "dies sollten sie sofort tun da dies sonnst jeder fremde tun kann wenn er die Seite kennt"
        echo ""
        echo "die MySQL datenbank kann unter phpmyadmin.$domain verwaltet werden"
        echo "  Nutzername: ${domain_config}_admin"
        echo "  Passwort: $wordpress_generated_db_password"
    fi
    echo ""
    echo "--------------------------"
}

print_config() {
    clear
    echo ""
    echo "--- Konfigurations Zusammenfassung ---"
    echo ""
    echo "Type: $type"
    echo "Domain: $domain"
    echo "Name: $domain_config"

    if [ -n "$sub_domains" ]; then
        # gibt alle elemente des arrays mit leerzeichen getrennt aus
        echo "Sub-Domains: ${sub_domains[@]}"
    fi
    echo ""
    echo "--------------------------------------"
    read -p "Sicher das die Seite so Konfiguriert werden soll? [y/n] " confirm_config
    if [ "${confirm_config,,}" = "${confirm,,}" ]; then
        build_vars
        echo "Seite $domain_config wird erstellt..."
        write_initial_config
        echo "initiale Konfiguration gespeichert!"
    fi
}

# hilft den NGINX container neu zu laden
reload_nginx(){
    docker compose exec nginx nginx -s reload
}

# basis command fuer certbot, muss mit zusätzlichen argmumenten ausgefuert werden
run_certbot(){
    docker run --rm --name certbot -v "$working_dir/data/certbot/letsencrypt":/etc/letsencrypt -v "$working_dir/data/certbot/www":/tmp/letsencrypt certbot/certbot $@
}

# hilft beim erstellen des zertifikates
generate_cert(){
    reload_nginx
    local staging_arg=""
    local domain_arg="-d $domain"
    local default_args="--email $email --rsa-key-size $rsa_key_size --agree-tos --force-renewal --non-interactive"
    
    if [ "$staging" = true ]; then
        staging_arg="--staging "
    fi

    for sub_domain in "${sub_domains[@]}"; do
        domain_arg+=" -d $sub_domain"
    done

    if [ "$action" = "2" ]; then
        domain_arg+=" -d phpmyadmin.$domain"
    fi
    # erstellt einen docker containert, welcher das Zertifikat generiert und sich anschliessend selber beendet
    run_certbot certonly --webroot -w /tmp/letsencrypt --cert-name $domain $staging_arg$domain_arg $default_args
}

# hilft beim löschen eines Zertifikates
delete_cert(){
    # erstellt einen docker continer, welcher das zertifikat löscht und sich anschliessend selber beendet
    run_certbot delete --cert-name $domain
}

# hilft beim erstellen der basis config fuer NGINX (benötigt fuer das SSL Zertifikat)
write_basic_config(){  
    cat > $nginx_config <<- EOM
# HTTP redirect
server {		
    listen      80;
    server_name "$domain" ${sub_domains[@]};

    include /etc/nginx/cmodules/letsencrypt.conf;

    location / {
        return 301 https://$domain\$request_uri;
    }
}
EOM
}