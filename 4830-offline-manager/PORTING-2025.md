# 4830-offline-manager mit Pump für Gluon v2025.1.3

Stand: 3. November 2026. Manager 1-r4, gluon-pump 0.1.22-r2.
Ziel: freifunk-gluon/gluon Tag v2025.1.3, Commit
`e2fe4b52effcf32e498e1afa283dbe8dccf21ffb`.

## Änderungen

- Lua 5.1 bleibt; `bit32` / `lua-bit32` statt `bit` / `luabitop`.
- WAN-Aufruf: `env LD_PRELOAD=libpacketmark.so LIBPACKETMARK_MARK=1
  /usr/bin/gluon-wan-dns /usr/sbin/autoupdater -f -b BRANCH`.
  DNS-Wrapper und IPv6-Routingmarkierung erfüllen unterschiedliche Aufgaben.
- SSID-Änderungen: alle Hostapd-Dateien schreiben, dann einmal
  `ubus call hostapd reload '{}'`. Fehler behalten die Retry-Markierung.
  OpenWrt 24.10 verwendet Inline-Konfigurationen; HUP reicht dafür nicht.
- Pump-Abhängigkeit auf `wpa-supplicant-mbedtls` umgestellt, passend zum von
  `gluon-wireless-encryption-wpa3` ausgewählten `hostapd-mbedtls`.
- Die vollständige Pump-Erweiterung der letzten Lieferung bleibt enthalten:
  bestehender Pump-Uplink zuerst, IPv4/IPv6-Fallback, externe netifd-Anmeldung,
  Wiederherstellung ohne Überschreiben der Pump-Konfiguration, Migration und respondd.
- Vorhandene BSS-config_id werden weiterhin SSID-abhängig aktualisiert;
  bei fehlendem config_id wird keines eingefügt. Pump/private BSS bleiben unberührt.

Unverändert: Minute-Cron mit 18 Sekunden Verzögerung, 15 Minuten Bootfrist,
Updates nach mehr als 60 Minuten durchgehend ohne Batman-Gateways, mindestens
10 Minuten zwischen Versuchen, Reboot nach mehr als 95 Minuten mit Update-Schutz.
Nur fehlende Gateways lösen Recovery aus; auch TQ 0 bei vorhandenem Gateway
verhindert dies. SSIDs: TQ <=15 offline, >=30 online, dazwischen Hysterese.
Zwei getrennte Open-/OWE-SSIDs, kein Transition-Modus. TQ erfordert BATMAN_IV.

## Einbau: genau eine Variante

A. Gegen die zuletzt gelieferte v2023.1-Pump-Version (Manager 1-r3):

```sh
git apply --check /pfad/pump-manager-v2023-to-v2025.1.3.patch
git apply /pfad/pump-manager-v2023-to-v2025.1.3.patch
```

B. Gegen den ursprünglichen ffgtso/ffgt_packages-v2023.x-Feed, Commit
`b622663eca1110cf9c7e034cc7dea2b7a8800697` (Manager 1-r2, Pump 0.1.22-r1):

```sh
git apply --check /pfad/pump-manager-v2025.1.3-from-feed.patch
git apply /pfad/pump-manager-v2025.1.3-from-feed.patch
```

Beide Patches enthalten Manager und Pump-Anpassung. Nicht nacheinander anwenden.
Alternativ die beiden vollständigen Paketverzeichnisse aus `packages/` übernehmen.
Die Patch-Basis ist der angegebene Feed-Commit, nicht automatisch dessen aktueller HEAD.
Die übrigen Pakete dieses v2023-Feeds werden dadurch nicht für Gluon 2025 portiert.

In der v2025.1.3-Site `4830-offline-manager` und bei Bedarf `gluon-pump` auswählen.
`pump-autoupdater-wifi-fallback`, andere Offline-Fallbacks, SSID-Changer und
`4830-node-watchdog` entfernen. Danach den Feed-Pin in `modules` auf den eigenen
Commit setzen. Offline-Mirrors, Branches und Signaturschlüssel müssen zum Ziel passen.
Kein alter v2023.1-site.mk-Patch liegt bei; er passt nicht pauschal zur v2025-Site.

Firmware neu bauen: das Upgrade-Skript richtet DHCPv4/IPv6 und Firewall ein.
Nur runtime.lua auszutauschen reicht nicht. Falls Tunneldigger eingesetzt wird,
muss es in der v2025-Site separat über einen kompatiblen Community-Feed kommen;
Gluon-Core liefert es nicht mehr. Pump bleibt optional.

## Validierung und Grenzen

83 Lua-5.1-Tests und zwei Python-Tests bestanden. Unter anderem tatsächlicher
WAN-argv, Hostapd-ubus-Aufruf, Retry, getrennte SSIDs, unveränderte Pump-BSS,
IPv4/IPv6, Cleanup, Gateway-Rückkehr, Upgrade-Schutz und Einstellungsübernahme.
Responder-C wurde im Hosttest mit UCI-/JSON-Doubles kompiliert.
Lua-/Shell-Syntax und Anwendung beider Patches mit Dateivergleich geprüft.
Kein Firmware-Build, Ziel-ABI-Test oder Hardwaretest. Insbesondere Hostapd/netifd,
Pump-STA/AP, WAN-DNS und Wiederherstellung auf Zielhardware vor Rollout prüfen.
Keine Pushes oder Deployments vorgenommen.

Quellen: Gluon v2025.1.3 `package/gluon-mesh-vpn-core`, `gluon-core`,
`gluon-wireless-encryption-wpa3`; OpenWrt 24.10 Hostapd-ucode-Reload;
https://gluon.readthedocs.io/en/latest/releases/v2025.1.html
https://gluon.readthedocs.io/en/latest/releases/v2025.1.3.html
