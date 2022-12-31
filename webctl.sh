#!/bin/bash
# Author: Fokko Vos
# Skript: webctl.sh
# Beschreibung: Dieses Skript binhaltet die Erstellung von Simplen Webseiten, sowie eine minimale Löschfunktion

if [ -f "install.sh" ]; then
    echo "Das Skript kann nicht ausgeführt werden sollange die Installation nicht vorgenommen wurde"
    exit 0
fi

#working_dir=$(pwd)
cd $working_dir

# include config
source "$working_dir/webctl/scripts/config.sh"
# include core functions
source "$working_dir/webctl/scripts/core.sh"
# include webpage functions
source "$working_dir/webctl/scripts/webpage.sh"
# include wordpress functions
source "$working_dir/webctl/scripts/wordpress.sh"
# include wordpress-yml functions
source "$working_dir/webctl/scripts/wordpress-yml.sh"

delete_webpage(){
    mkdir -p $deleted_dir
    mv "$nginx_config" "${deleted_dir}nginx.conf"
    mv "$config_file" "${deleted_dir}webctl.conf"
    mv "$pages_dir" "${deleted_dir}web-data"
}
    
delete_wordpress(){
    mkdir -p $deleted_dir
    mv "$nginx_config" "${deleted_dir}nginx.conf"
    mv "$config_file" "${deleted_dir}webctl.conf"
    cd $wordpress_dir
    docker compose down
    cd $working_dir
    mv "$wordpress_dir" "${deleted_dir}wordpress_data"
    rm "$working_dir/webctl/start_${domain_config}.sh"
    rm "$working_dir/webctl/stop_${domain_config}.sh"
}

# sollte die docker compose umgebung noch nicht laufen, wir diese gestartet
docker compose up -d

user_menu $1
case "$action" in
    "1")
    # (Normal)
    # webctl 1 <domain> <config-name> <subdomains (comma seperated)>
    read_domain $2
    read_config_name $3
    read_subdomains $4
    print_config
    build_vars
    # erstellt eine standard NGINX config
    write_basic_config
    # generiert ein zertifikat und reloaded vorher den NGINX container
    generate_cert
    # erstellt den basis ordner
    mkdir -p $pages_dir
    # erstellt die basis HTML seite
    create_webpage_base_structure
    # erweitert die NGINX konfiguration 
    extend_nginx_webpage_config
    # NGINX container neu laden
    reload_nginx
    # config fuer die nachvollziehbarkeit schreiben
    # wird beim löschvorgang verwendet
    write_config
    print_final
    ;;
    "2")
    # (Wordpress)
    # webctl 2 <domain> <config-name> <subdomains (comma seperated)>
    read_domain $2
    read_config_name $3
    read_subdomains $4
    print_config
    build_vars
    # erstellt eine standard NGINX config
    write_basic_config
    # generiert ein zertifikat und reloaded vorher den NGINX container
    generate_cert
    # erstellt den basis ordner
    mkdir -p $wordpress_dir
    # erstellt die port-tracking datei, sollte diese noch nicht existent sein
    if [ ! -f $wordpress_port_file ]; then
        # wir wollen das die erste seite auf dem Port 20000 laueft
        # desehalb stellen wir den start wert 2 tiefer
        # die 'level_wordpress_port' funktion wird auf diese zahl fuer jede instanz drauf rechnen weil wir immer einen MYSQL und einen WORDPRESS port brauchen
        echo "wordpress_port=19998" > $wordpress_port_file
    fi
    # port fuer wordpress um eins hochzaehlen
    level_wordpress_port
    # erstellt eine basis wordpress dateien
    create_wordpress_base_structure
    # erstellt start und stop dateien
    setup_wordpress
    # Hinzufuegen der finalen server config fuer NGINX
    extend_nginx_wordpress_config
    # NGINX container neu laden
    reload_nginx
    # config fuer die nachvollziehbarkeit schreiben
    # wird beim löschvorgang verwendet
    write_config
    print_final
    # wordpress starten
    cd $wordpress_dir
    docker compose up -d
    ;;
    "3")
    # (Delete)
    # webctl 3 <config-name>
    read_config_name $2 true
    read -p "Sicher das die Seite $domain_config gelöscht werden soll? [y/n] " confirm_delete
    if [ "${confirm_delete,,}" = "${confirm,,}" ]; then
        read -p "soll das Zertifikat auch gelöscht werden? [y/n] " confirm_delete_cert
        if [ "${confirm_delete_cert,,}" = "${confirm,,}" ]; then
            delete_cert
        fi
        echo "Seite wird gelöscht..."
        case "$action" in
            "2")
            delete_wordpress
            ;;
            *)
            delete_webpage
            ;;
        esac
    fi
    ;;
esac