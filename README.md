# WebCTL

Entstanden im rahmen eines Schulprojekts.

Dieses Skript/Enviroment soll es vereinfachen eine Webseite zu hosten mithilfe von Docker und einem Shell Skript.

Das Skript hat 3 aktionen welche es ausführen kann:
- Webseite erstellen (HTML)
- Webseite erstellen (Wordpress-dockerized)
- Löschen einer vom Skript erstellten Webseite

# Installation

wenn das Respository geclont wurde kann die install.sh welche sich im Hauptordner befindet dazu genutzt werden alle benötigten einstellungen für das Skript vorzunehmen, wie das anpassen von Rechten oder erstellen von Cronjobs.

Mit dem Installations Skript wird der befehl "webctl" global auf dem Server eingerichtet und kann unabhängig vom Ordner ausgeführt werden.

`Vor der Installation sollte man sich in den geclonten ordner begeben auf die tree ebene der install.sh`

```shell
chmod +x install.sh && ./install.sh
```

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