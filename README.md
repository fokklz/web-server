# Web-Server

Entstanden im rahmen eines Schulprojekts.

Dieses Skript/Enviroment soll es vereinfachen eine Webseite zu hosten mithilfe von Docker und einem Shell Skript.

Das Skript hat 3 aktionen welche es ausführen kann:
- Webseite erstellen (HTML)
- Webseite erstellen (Wordpress-dockerized)
- Löschen einer vom Skript erstellten Webseite

# Installation

Mit dem Installations befehl werden alle nötigen abhängigkeiten sowie das skript installiert, der standard installationsordner ist "/opt" mit dem finalen pfad "/opt/web-sever". Der befehl webctl kann von überall verwendet werden und erstellt die projekte in den Entsprechenden ordnern innerhalb des ROOT-Ordners

`Installiert: Curl | Git | Docker | Webctl (dieses script)`
```shell
apt update && apt upgrade -y && apt install git curl -y && curl -sSL https://get.docker.com/ | CHANNEL=stable sh && systemctl enable --now docker && cd /opt && git clone https://github.com/fokklz/web-server.git && cd web-server && chmod +x install.sh && ./install.sh
```

Sollte die Domain auf den Server führen kann direkt mit der start konfiguration losgelegt werden da die NGINX instanz an die IP `0.0.0.0` gebunden wird.

# Nutzung

Das Skript ist in mehrere kleine Dateien aufgeteilt, wird aber dennoch über die Hauptdatei Webctl ausgeführt und sollte nicht über andere Dateien verwendet werden.

alle parameter mit `[]` können weggelassen werden und werden wenn benötigt vom Skript abgefragt.

Sollte das Skript nicht über die Installations datei installiert worden sein, oder der Befehl nicht global hinterlegt muss für die Ausführung des Skript in den Ordner in dem es installiert wurde navigiert werden, und der befehl mit `./` prefixed werden.

`Normale Webseite oder Wordpress Erstellen`
```shell
webctl [1|2] [domain] [config-name] [subdomains (comma seperated)]
```

`Löschung einer seite`
```shell
webctl 3 [config-name]
```