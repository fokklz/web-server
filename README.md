# Web-Server

Entstanden im Rahmen eines Schulprojekts.

Dieses Skript/Environment soll es vereinfachen eine Webseite zu hosten mithilfe von Docker und einem Shell Skript.

Das Skript hat 3 Aktionen, welche es ausführen kann:
- Webseite erstellen (HTML)
- Webseite erstellen (Wordpress-Dockerized)
- Löschen einer vom Skript erstellten Webseite

# Installation

Mit dem Installation Befehl werden alle nötigen Abhängigkeiten sowie das Skript installiert, der Standard Installation Ordner ist "/opt" mit dem finalen Pfad "/opt/web-sever". Der Befehl webctl kann von überall verwendet werden und erstellt die Projekte in den Entsprechenden Ordnern innerhalb des ROOT-Ordners

`Installiert: Curl | Git | Docker | Webctl (dieses script)`
```shell
apt update && apt upgrade -y && apt install git curl -y && curl -sSL https://get.docker.com/ | CHANNEL=stable sh && systemctl enable --now docker && cd /opt && git clone https://github.com/fokklz/web-server.git && cd web-server && chmod +x install.sh && ./install.sh
```

Sollte die Domain auf den Server führen kann direkt mit der Start Konfiguration losgelegt werden da die NGINX Instanz an die IP `0.0.0.0` gebunden wird.

# Nutzung

Das Skript ist in mehrere kleinen Dateien aufgeteilt, wird aber dennoch über die Hauptdatei Webctl ausgeführt und sollte nicht über andere Dateien verwendet werden.

alle Parameter mit `[]` können weggelassen werden und werden wenn benötigt vom Skript abgefragt.
`Normale Webseite oder WordPress Erstellen`
```shell
webctl [1|2] [domain] [config-name] [subdomains (comma seperated)]
```
`Löschung einer Seite`
```shell
webctl [3] [config-name]
```
