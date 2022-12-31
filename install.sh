#!/bin/bash
# Author: Fokko Vos
# Skript: install.sh
# Beschreibung: Dieses Skript dient der Installation von WebCTL und allen damit verbundenen abhängigkeiten damit alles fehlerfrei Funktioniert.

working_dir=$(pwd)
cd $working_dir

# die email welche für die Zertifikate genutzt werden soll
echo "Damit die Zertifikate erstellt werden können wird eine Emailadresse benötigt, bitte gib eine gültige Emailadresse ein um diese bedingung zu erfüllen und einen zentralen Verantwortlichen zu definieren."
read -p 'Email: ' email

cat > "webctl/scripts/config.sh" <<-EOM
# set to true while testing to bypass letsencrypt limits
staging=false
# RSA Size
rsa_key_size=4096
# authority for the certs
email="$email"
# get current time (start of script) for backups & processing marks
current_time=$(date '+%Y-%m-%d')
# confirm key
confirm="y"
# wir wollen die http versionen auf den lokalen port binden damit diese nur ueber die Proxy erreichbar sind
ip="127.0.0.1"
# config dir
config_base_dir="webctl/configs"
# wordpress project base location
wordpress_base_dir="wordpress"
EOM

# sollte die docker compose umgebung noch nicht laufen, wir diese gestartet
docker compose up -d

# cronjob fuer die Zertifikat erneuerung
crontab -l > mycron
echo "0 0 * * * docker run --rm --name certbot -v "$working_dir/data/certbot/letsencrypt":/etc/letsencrypt -v "$working_dir/data/certbot/www":/tmp/letsencrypt certbot/certbot renew" >> mycron
crontab mycron
rm mycron

webctl=$(< webctl.sh)
cat > "webctl.sh" <<- EOM
#!/bin/bash
working_dir="$working_dir"
$webctl
EOM
cp "webctl.sh" "/usr/local/bin/webctl"

# rechte für die Haupt-Datei des Skripts aktuallisieren damit diese ausgefürt werden kann
chmod +x webctl.sh
# rechte für die globale ausführungs datei definieren
chmod +x "/usr/local/bin/webctl"

clear
echo " ---- Installation Erfolgreich ---- "
echo ""
echo ""
echo "Das Skript ist nun bereit für die verwendung und wurde Global auf dem Server installiert."
echo "Zertifikate werden mit der email $email erstellt, und automatisch ueber Cronjobs erneuert."
echo "Starte sofort mit: 'webctl' um dir eine Hilfe anzeigen zu lassen."
echo ""
echo "Danke für dein Vertrauen!"
echo ""
echo "  Normale Webseite erstellen"
echo "   -> webctl 1 [domain] [config-name] [subdomains (comma seperated)]"
echo ""
echo "  Wordpress Webseite erstellen"
echo "   -> webctl 2 [domain] [config-name] [subdomains (comma seperated)]"
echo ""
echo "  Erstellte webseiten löschen"
echo "   -> webctl 3 [config-name]"

# löschung der datei, damit die Installation nicht unabsichtlich mehrmals vorgenommen wird
# sollten änderungen gemacht werden wollen ist dies ohne probleme in der webctl/scripts/config.sh möglich
rm install.sh