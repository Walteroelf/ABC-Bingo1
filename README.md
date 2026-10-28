# Buchstaben-Bingo

Ein Buchstaben-Ziehautomat für Bingo im Unterricht. Ein Kind tippt aufs
iPad, die Buchstaben „würfeln“ kurz durch, dann erscheint ein Buchstabe
groß auf dem Bildschirm und wird vorgelesen. Kein Buchstabe kommt doppelt,
bis das Spiel zurückgesetzt wird.

**App öffnen:** <https://walteroelf.github.io/ABC-Bingo1/>

## So wird gespielt

1. Die Kinder bekommen Wortkarten (siehe [Wortkarten drucken](#wortkarten-drucken)).
2. Die „Glücksfee“ tippt auf den roten Bildschirm.
3. Der gezogene Buchstabe erscheint und wird vorgelesen. Antippen spielt
   ihn noch einmal ab.
4. Alle Kinder, die den Buchstaben auf einer Karte haben, malen den Kreis
   darunter aus.
5. „Weiter“ führt zurück zum Startbildschirm für den nächsten Buchstaben.

Wer zuerst alle Wörter voll hat, ruft „Bingo!“.

## Einstellungen (⚙️ unten links)

| Bereich | Was es tut |
|---|---|
| Bisherige Buchstaben | Liste in Zieh-Reihenfolge, der neueste ist gelb umrandet. **Letzten zurücknehmen** (z. B. nach versehentlichem Doppeltippen) und **Zurücksetzen** (neues Spiel). |
| Farbe dieses iPads | Gezogene Buchstaben erscheinen in dieser Farbe, auch auf der Tafel. So sieht man, welche Fee gezogen hat. |
| Effekte | Trommelwirbel beim Würfeln und Konfetti beim Ergebnis, einzeln abschaltbar. |
| Buchstaben im Topf | Buchstaben antippen, um sie heraus- oder hineinzunehmen. Schnellknöpfe: Alle, Keine, Ohne Q, X, Y. |
| Schreibweise | „A“, „A a“ oder „a“, für jedes Gerät einzeln. |
| Lautstärke | Gilt auch auf iPhone und iPad. |
| Mehrere iPads | Siehe unten. |
| Tafel-Ansicht | Siehe unten. |
| Wortkarten | Öffnet den Wortkarten-Generator. |

Gezogene Buchstaben und Einstellungen bleiben beim Neuladen erhalten.

## Mehrere iPads

Mehrere Glücksfeen können gleichzeitig ziehen, ohne dass ein Buchstabe
doppelt kommt.

1. Auf einem iPad: ⚙️ → **Weitere iPads verbinden**. Es erscheint ein
   QR-Code und ein Spielcode (z. B. `4gux pjs9 78`).
2. Auf jedem weiteren iPad den QR-Code mit der Kamera scannen, **oder**
   unter ⚙️ → Mehrere iPads den Spielcode eintippen und **Beitreten**.
3. Ein grüner Punkt oben rechts heißt „verbunden“, ein oranger
   „gerade keine Verbindung“.

Gezogene Buchstaben, Topf, Farben, Zurücknehmen und Zurücksetzen gelten
dann für alle verbundenen Geräte. Ziehen zwei iPads im selben Moment
denselben Buchstaben, zieht eines davon unbemerkt neu.

Gut zu wissen:

- Der Abgleich braucht Internet. Vor dem ersten Einsatz einmal im
  Schul-WLAN testen: Wird der Punkt grün, klappt es.
- Mit mehreren iPads setzt „Weiter“ nach dem letzten Buchstaben das Spiel
  **nicht** zurück, damit keine Fee das Spiel aller beendet. Neues Spiel
  über ⚙️ → Zurücksetzen.
- Ohne Verbindung zieht ein iPad allein weiter. Nur in diesem Fall kann
  ein Buchstabe doppelt kommen.

## Tafel-Ansicht (Beamer, Smartboard)

Zeigt den zuletzt gezogenen Buchstaben ganz groß und darunter alle
bisherigen, in der Farbe der jeweiligen Fee. Auf der Tafel wird nicht
gewürfelt, aber man kann dort zurücksetzen und den Topf ändern.

Erst „Weitere iPads verbinden“ tippen, dann unter ⚙️ → Tafel-Ansicht:

- **QR-Code für die Tafel** mit der Kamera der Tafel scannen, oder
- **Link kopieren** und auf dem Beamer-Rechner öffnen, oder
- **Dieses Gerät als Tafel** (z. B. ein iPad per Kabel oder AirPlay am Beamer).

## Als App auf den Home-Bildschirm

In Safari auf dem iPad: Teilen-Symbol → **Zum Home-Bildschirm**. Dann:

- startet das Bingo mit eigenem Symbol im Vollbild, ohne Safari-Leiste,
- funktioniert es mit **einem** iPad auch ganz ohne Internet (nachdem es
  einmal mit Internet geöffnet wurde),
- holt es sich Updates automatisch, sobald Internet da ist.

Wichtig: Die Home-Bildschirm-App hat einen eigenen Speicher, getrennt von
Safari. Ein QR-Code öffnet sich immer in Safari, nicht in der App. Darum in
der App zum Verbinden den **Spielcode eintippen**.

Tipp für Kinder mit Beeinträchtigung: Mit **Geführter Zugriff**
(Einstellungen → Bedienungshilfen) lässt sich das iPad auf die App
festsetzen.

## Wortkarten drucken

⚙️ → **Wortkarten-Generator öffnen** (oder direkt `karten.html`).

1. Wörter eingeben, eins pro Zeile oder mit Komma getrennt.
2. Einstellen, wie viele Wörter ein Kind bekommt (Standard: 3). Auf jede
   Karte kann klein die Satz-Nummer gedruckt werden, das erleichtert das
   Austeilen. Die Wörter lassen sich auch zufällig auf die Sätze verteilen.
3. **Drucken / als PDF sichern.** Karten mit bis zu 5 Buchstaben passen zu
   zweit nebeneinander, längere Wörter stehen einzeln.

Der Generator zeigt, welche Buchstaben in den Wörtern vorkommen. Mit **Nur
diese Buchstaben in den Topf** werden genau diese ins Spiel übernommen, so
gehen keine Züge auf Buchstaben, die niemand braucht. Ä, Ö, Ü und ß werden
in der App nicht gezogen; der Generator warnt bei solchen Wörtern.

## Datenschutz

- Ohne „Weitere iPads verbinden“ bleibt alles auf dem Gerät.
- Beim Verbinden tauschen die Geräte über einen öffentlichen Test-Server
  (HiveMQ, als Ersatz EMQX) nur Buchstaben, Farben, Topf und einen
  zufälligen Spielcode aus. Keine Namen, keine Gerätedaten.
- Schrift und Bibliotheken liegen im Repo, es werden keine fremden
  Schrift- oder Bibliotheks-Server (CDN) abgefragt.

## Technik

Reine Webseite ohne Build-Schritt, läuft auf GitHub Pages.

| Datei | Inhalt |
|---|---|
| `index.html` | Die App (HTML, CSS, JavaScript in einer Datei) |
| `karten.html` | Wortkarten-Generator |
| `A.mp3` … `Z.mp3` | Gesprochene Buchstaben |
| `sw.js`, `manifest.webmanifest`, `icons/` | Home-Bildschirm-App und Offline-Speicher |
| `fonts/` | Schrift Andika (SIL, OFL-Lizenz, siehe `fonts/OFL.txt`) |
| `lib/` | MQTT.js 5.10.1 und qrcode-generator 1.4.4 (beide MIT), siehe `lib/README.md` |

Werden Dateien hinzugefügt oder umbenannt, die offline verfügbar sein
sollen: in `sw.js` die Liste `FILES` anpassen und `VERSION` erhöhen.
