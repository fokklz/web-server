#!/bin/bash
# ./create.sh 1 f-ibz.xyz f-ibz lol.com,haha.com,rofel.ch

# absolute working path
working_dir="/opt/web-server"
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
    mv "$working_dir/$nginx_config" "${deleted_dir}nginx.conf"
    mv "$working_dir/$config_file" "${deleted_dir}webctl.conf"
    mv "$working_dir/$pages_dir" "${deleted_dir}web-data"
}
    
delete_wordpress(){
    mkdir -p $deleted_dir
    mv "$working_dir/$nginx_config" "${deleted_dir}nginx.conf"
    mv "$working_dir/$config_file" "${deleted_dir}webctl.conf"
    cd $wordpress_dir
    docker compose down
    cd $working_dir
    mv "$working_dir/$wordpress_dir" "${deleted_dir}wordpress_data"
    rm "webctl/start_${domain_config}.sh"
    rm "webctl/stop_${domain_config}.sh"
}

# ueberpruefen das der nginx server nicht laueft
if [ -z `docker ps -q --no-trunc | grep $(docker-compose ps -q nginx)` ]; then
    # starten, da das skript nur mit laufender nginx instanz fehlerfrei funktionieren kann
    docker-compose up -d
fi

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

    # wordpress starten
    cd $wordpress_dir
    docker compose up -d

    print_final
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