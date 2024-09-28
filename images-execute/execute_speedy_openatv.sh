#!/bin/bash

###################  Jungle-team   ######################
#                  jungle-team.es  ######################
#            speedy OEA Autoinstalacion OpenaTV         #
#                    version 1.5                        #
######################################################### 

#Definimos paquetes mas usuales de archivos a instalar
PAQUETE_EPGIMPORT="enigma2-plugin-extensions-epgimport"
PAQUETE_JUNGLESCRIPT="enigma2-plugin-extensions-junglescript"
PAQUETE_JUNGLEBOT="enigma2-plugin-extensions-junglebot"
PAQUETE_GHOSTREAMY_ARM="enigma2-plugin-extensions-ghostreamy-arm"
PAQUETE_GHOSTREAMY_MIPSEL="enigma2-plugin-extensions-ghostreamy-mips"
PAQUETE_OSCAMCONCLAVE="enigma2-plugin-softcams-oscam-conclave"
REPOSITORIO_JUNGLE="http://tropical.jungle-team.online/script/jungle-feed.conf"
PAQUETE_TDTCHANNLES="enigma2-plugin-extensions-tdtchannels"
PAQUETE_GHOSTREAMY="enigma2-plugin-extensions-ghostreamy"

#Defnimos comandos extra instalacion
COMANDO_FOOTONSAT="wget -q --no-check-certificate https://gitlab.com/MOHAMED_OS/dz_store/-/raw/main/FootOnsat/online-setup -O install.sh && sh install.sh && rm install.sh"
COMANDO_CCCAM="suerte_cccam"
COMANDO_JUNGLESCRIPT="wget -q '--no-check-certificate' https://raw.githubusercontent.com/jungla-team/Speedy-OEA-autoinstall/main/files_extra/op_junglescript.sh && sh op_junglescript.sh && rm op_junglescript.sh"
COMANDO_JUNGLEBOT="cambiar_parametros_junglebot"

#Definimos metodos instalacion
INSTALACION_NORMAL="opkg install"
INSTALACION_FORZADA="opkg install --force-reinstall"
ESTATUS_PAQUETE="opkg status"
BORRAR_PAQUETE="opkg remove"
FORZAR_BORRAR_PAQUETE="opkg remove --force-depends"
FORZAR_ESCRITURA="opkg install --force-overwrite"

#Definimos colores para mensajes
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"
RED_BOLD="\e[1;31m"
GREEN_BOLD="\e[1;32m"
YELLOW_BOLD="\e[1;33m"
BLUE_BOLD="\e[1;34m"

#Definimos url del respositorio jungle-team
REPOSITORIO_JUNGLE="http://tropical.jungle-team.online/script/jungle-feed.conf"

#Definimos la arquitectura de nuestro receptor
es_arm=$(uname -a | grep -i arm | wc -l)

#Definimos ubicacion del log de speedy OEA autoinstall
SPEEDY_LOG=/var/log/speedy_autoinstall.log

# Función para mostrar mensajes
function mensaje() {
  echo -e "${2}${1}${RESET}"
}

# Función para mostrar errores y salir del instalador
function error() {
  echo -e "\n${RED}ERROR: ${1}${RESET}" 1>&2
  exit 1
}

# Se define si hay conexion a internet
function TEST_INTERNET() {

	wget -q --spider http://google.com
	
	if [ $? -ne 0 ]; then
		Error "Es necesario disponer de conexion a Internet" "${GREEN}"
	fi

}

#Funcion de barra de progreso
function print_completed_blocks() {
    local completed_blocks=$(($elapsed * $BAR_LENGTH / $duration))
    printf "%0.s${BAR_CHARACTER}" $(seq 1 $completed_blocks)
}

function print_remaining_blocks() {
    local remaining_blocks=$(($BAR_LENGTH - ($elapsed * $BAR_LENGTH / $duration)))
    printf "%0.s${EMPTY_CHARACTER}" $(seq 1 $remaining_blocks)
}

function print_percentage() {
    local percentage=$(($elapsed * 100 / $duration))
    printf "| %3d%%" $percentage
}

function progress_bar() {
    local duration=${1}
    local BAR_LENGTH=10
    local BAR_CHARACTER="▇"
    local EMPTY_CHARACTER=" "

    for (( elapsed=1; elapsed<=$duration; elapsed++ )); do
        printf "${GREEN}"
        print_completed_blocks
        printf "${RESET}"
        print_remaining_blocks
        print_percentage
        sleep 1
        printf "\r"
    done
    printf "\r"
}


#Definimos un temporizador de espera para continuar con la instalacion o cancelarla
function temporizador()
{
tiempo=15 # segundos

echo
echo -e "${RED_BOLD}⚠️   Si continua se procedera a la ejecucion, me joderia que lo hiciera por error" "${RESET}"
echo ""

#Definimos una cuenta atras antes de la ejecucion
contador=${tiempo}
while [[ ${contador} -gt 0 ]];
do
    printf "\rTienes ${GREEN_BOLD}%2d segundos${RESET} para pulsar ${YELLOW_BOLD}Ctrl+C${RESET} y asi cancelar la ejecucion!" ${contador}
    sleep 1
        : $((contador--))
done
echo ""
}

#Definimos valores de informacion receptor para el menu speedy OEA      
MODELO_RECEPTOR="$(cat /etc/hostname)"
ARQUITECTURA_RECEPTOR="$(uname -m)"
VERSION_IMAGEN="$(cat /etc/image-version | grep imageversion | sed -e 's/imageversion=//')"
DATOS_COMPILACION="$(cat /etc/image-version | grep imagebuild= | sed -e 's/imagebuild=//')"
MEMORIA_RAM=$(free | grep Mem  | awk '{ print $4 }')
MEMORIA_FLASH=$(df -h | awk 'NR == 2 {print $4}')
FECHA_RECEPTOR="$(date)"
PYTHONVERSION=$(python --version | awk '{print $2}')

function installed_junglescript() {
    test_j=$(opkg list-installed | grep ${PAQUETE_JUNGLESCRIPT} | wc -l)
    if [ "$test_j" -eq 0 ];
    then
        test_jungle="No esta instalado junglescript"
    else
        test_jungle="Si tienes instalado junglescript"
    fi
   echo -e "${GREEN}JungleScript:${RESET} $test_jungle"
} 

function installed_junglebot() {
    test_j=$(opkg list-installed | grep ${PAQUETE_JUNGLEBOT} | wc -l)
    if [ "$test_j" -eq 0 ];
    then
        test_jungle="No esta instalado junglebot"
    else
        test_jungle="Si tienes instalado junglebot"
    fi
   echo -e "${GREEN}JungleBot:${RESET} $test_jungle"
}

function installed_oscamconclave() {
    test_j=$(opkg list-installed | grep ${PAQUETE_OSCAMCONCLAVE} | wc -l)
    if [ "$test_j" -eq 0 ];
    then
        test_jungle="No esta instalado Oscam-conclave"
    else
        test_jungle="Si tienes instalado Oscam-conclave"
    fi
   echo -e "${GREEN}Oscam-Conclave:${RESET} $test_jungle"
} 

function installed_ghostreamy() {
    test_j=$(opkg list-installed | grep ${PAQUETE_GHOSTREAMY} | wc -l)
    if [ "$test_j" -eq 0 ];
    then
        test_jungle="No esta instalado Ghostreamy"
    else
        test_jungle="Si tienes instalado Ghostreamy"
    fi
   echo -e "${GREEN}Ghotreamy:${RESET} $test_jungle"
}

function installed_tdtchannels() {
    test_j=$(opkg list-installed | grep ${PAQUETE_TDTCHANNLES} | wc -l)
    if [ "$test_j" -eq 0 ];
    then
        test_jungle="No esta instalado tdtchannels"
    else
        test_jungle="Si tienes instalado tdtchannels"
    fi
   echo -e "${GREEN}Tdtchannels:${RESET} $test_jungle"
}


function installed_epgimport() {
    test_j=$(opkg list-installed | grep ${PAQUETE_EPGIMPORT} | wc -l)
    if [ "$test_j" -eq 0 ];
    then
        test_jungle="No esta instalado EpgImport"
    else
        test_jungle="Si tienes instalado EpgImport"
    fi
   echo -e "${GREEN}EpgImport:${RESET} $test_jungle"
}


function status_server_jungleteam() {
    wget http://tropical.jungle-team.online/oasis/H2O/Packages.gz >>$SPEEDY_LOG 2>&1
    test_j=$(ls -a | grep Packages.gz | wc -l)
    if [ "$test_j" -eq 0 ];
    then
        test_jungle="Fuera de Servicio"
    else
        test_jungle="Esta Activo"
    fi
   echo -e "${GREEN}Estado Repositorio Jungle:${RESET} $test_jungle"
   rm -r Packages.gz >>$SPEEDY_LOG 2>&1

}

#Modulo base para instalaciones paquetes
function Modulo_package_gestion() {
    echo -e "${BLUE_BOLD}$2${RESET}"
    PS3="¿Deseas instalar el paquete $1? "
    options=("Sí" "No")
    select opt in "${options[@]}"; do
        case $opt in
            "Sí")
                echo "Instalando $1..."
                $3 "$1" >> $SPEEDY_LOG 2>&1 | progress_bar $4
                echo "Instalación de $1 completada."
                if [[ $5 == "extra_comando" ]]; then
                    echo "Ejecutando acción adicional después de instalar $1."
                    eval "$6"
                fi
                break;;
            "No")
                echo "No se ha seleccionado instalar $1."
                break;;
            *) echo "Opción inválida. Por favor, seleccione una opción válida.";;
        esac
    done
    echo "---------------------------------------------------------"
}


#Funcion menu principal speedy oea
function MENU_SPEEDY_OEA() {

    clear
	echo
	echo
	echo -e "${GREEN} *********************************************************************************************************************************${RESET}"
	echo -e "${GREEN}"
	cat << "EOF"
                        .::::-----:::.            
                     .::::::::::::::::-:          
                   :::::::::::::::::::::-.                  ¡Ándale, ándale, ándale yiiija! Rapidamente tu imagen configurada
               .::-::::::::::::::::::::::-.       
            :-::::::::::::::::::::::::::::-                 Speedy OEA AutoInstall version: 1.5
          :-::::::::::::::::::::::::::::::::      
        :-:::::::::::::::::::::::::::::::::-                Imagen Compatible: OpenATV
       -::::::::::::::::::::::::::::::::::::-     
     .-::::::::---::::::::::::::::::::::::::=:::            Web: www.jungle-team.es
    --:::::::-=+*#%%%#*+==-::::::::::::::::::=::  
   --::::::--=+**#%%%%@@@@%*-::::::::::::::::=:             Telegram: https://t.me/joinchat/AFo2KEfzM5Tk7y3VgcqIOA 
  =-::::::::--==+= +++++++**+=:::::::::::::::+    
  =-------==++++*-*+++++=:.=+++=-::::::::::::-              Donacion: https://www.paypal.com/paypalme/jungleteam
  :-:::::=+++++#@@@%#++=.==+++++++=::::::::::-    
   :=----+++++*+*###++++++*+++++++++-:----::::.             Licencia: General Public License
    .--::-+++++*+++++*%@*++++++++++++++++++-::-   
      .:-:-++++++*%%@@@#++++++++++++-::...:=::::            Fecha Actualizacion: 28-09-2024
         .:-=++++%@@@@*+++++++++++=-:.....:-::::-.
             :****###+++++++++++++=:....:-:::::::-
  ..       :*%%%%%##****+==+==--:--=----:::::::::.
  =: .::  :%%%%%%*=#%%%%%-  :::::--------:::::.             Puede transmitir un trabajo basado en el Programa, o las modificaciones para
  -+:.    #%#*=-.  :#%%%%%-  ..                             producirlo desde el Programa, en forma de código fuente bajo los términos,
 :+-     :*..        :*%%%-   :=:  .:                       siempre que también cumpla con todas estas condiciones:
 ++         .           =*      :==-.                       a) El trabajo debe llevar avisos prominentes que indiquen que usted lo modificó
 .         .            .        ++.                            o publico haciendo constar el autor del mismo.
           .            .        -*:                        b) Transmitir el código debera siempre unido al enlace al codigo fuente
                        .        :=               
              .  .... .=                          
               .  .   . :.                        
               .  :  ..   ...                     
                 =  :=       ......                         Miembros Jungle-Team: @ja2m00 @biturbo69 @txolo99 @tanharo_jungle
                 =   +                            
    .::--========-. .=-::::::..                   
 :=++++++=-:..          .::-=++++=-.          .   
:---:..                       ..:-=++.                                            @Jungle-Team 2019
EOF
	echo -e "${GREEN} *********************************************************************************************************************************${RESET}"
	echo
	echo -e "${YELLOW}💡 Informacion Receptor:${RESET}"
	echo
	echo -e "${GREEN}Receptor:${RESET} $MODELO_RECEPTOR"
    echo -e "${GREEN}Imagen Version:${RESET} OpenATV $VERSION_IMAGEN"
    echo -e "${GREEN}Version PYTHON:${RESET} $PYTHONVERSION"
    echo -e "${GREEN}Fecha Compilacion:${RESET}$DATOS_COMPILACION"
	echo -e "${GREEN}Arquitectura:${RESET} $ARQUITECTURA_RECEPTOR"
	echo -e "${GREEN}Ram Libre:${RESET} $MEMORIA_RAM kb"
	echo -e "${GREEN}Flash Libre:${RESET} $MEMORIA_FLASH gb"
	status_server_jungleteam
	installed_junglescript
	installed_junglebot
	installed_oscamconclave
	installed_ghostreamy
	installed_epgimport
	installed_tdtchannels
	echo
	echo -e "${BLUE}------------------------------------------------------------${RESET}"
	echo -e "${BLUE}⚙️   MENU SELECCION OPCIONES INSTALACION${RESET}"
	echo
	echo -e "${YELLOW_BOLD}(introduzca el varlor numerico deeseado)             ${RESET}"
	echo -e "${BLUE}------------------------------------------------------------${RESET}"
	echo
while :
do
	echo -e " (1) Instalar ${YELLOW_BOLD}(Iniciar la instalacion de utilidades)${RESET}"
	echo
	echo -e " (2) desinstalar ${YELLOW_BOLD}(Borrar todos los archivos instalados)${RESET}"
	echo
	echo -e " (3) Ayuda ${YELLOW_BOLD}(Menu de ayuda y recomendaciones)${RESET}"
	echo
	echo -e " (4) Borrar log ${YELLOW_BOLD}(Elimina el log ubicado en /var/log)${RESET}"
	echo
	echo -e " (5) Realizar Backup ${YELLOW_BOLD}(Realiza backup de los archivos mas usuales en /media/hdd)${RESET}"
	echo
	echo -e " (6) Restaurar Backup ${YELLOW_BOLD}(Restaurar Backup)${RESET}"
	echo
	echo
    echo " (s) Salir"
	echo
	echo -n " Introduzca la opcion deseada: "
	read SpeedyOEA
	case $SpeedyOEA in
		1) clear && install_packages;;
		2) clear && remove;;
		3) clear && ayuda;;
		4) clear && borrar_log;;
		5) clear && backup_jungle;;
		6) clear && restaurar_backup;;
		s) clear && echo "❤️  Gracias por haber usado Speedy OEA Autoinstalacion" && echo && exit;;
		*) echo && echo -e " ${RED_BOLD}¡¡¡¡¡¡¡$SpeedyOEA es un valor incorrecto, intentalo de nuevo!!!!!!${RESET}" && echo;
	esac
done

 }
 
 
#Definiendo menu de instalacion
 function Menu_start_install() {
    logo
	echo
	echo -e "${BLUE}💡  En nuestro receptor puede seleccionar la instalacion de las siguientes utilidades:${RESET}"
	echo
	cat << "EOF"
  - Repositorios emus oficial Openatv y Repositorio jungle-team
  - JungleScript -- Auto instalacion lista canales y picon
  - JungleBot -- Para controlar tu receptor por Telegram
  - Oscam-Conclave -- Auto instalacion oscam ultima version
  - Oscam-Trunk -- Version oscam compilada por openatv
  - CCcam 2.3.2 64 bits spain -- Version estable para spain
  - Ncam -- Emuladora basada en Oscam
  - Ghostreamy - Panel gestion Stream Enigma2
  - EpgImport - Para descarga EPG con fuentes oficiales koala para Movistar+
  - Zerotier - Para acceder al receptor via vpn
  - Tdtchannels - crea favorito y picon canales tdt por web
  - Tailscale - Para acceder al receptor via vpn
  - Diseqc - Para programar LNB Unicable
  - Asignar password al receptor
  - Poner automaticamente en hora el receptor
  - FoonSat - Para eventos deportivos de futbol
  - Streamproxy - activar solicitud pass en streaming openwebif 
  - Oscam icam - Oscam parcheado para canales alemanes
  - bouquetmakerxtream - Para instalar listas iptv en nuestro receptor
  - jediepgxtream - Para asignar epg a los canales iptv
  - xklass - Para instalar listas iptv
  - openvpn - Para acceder al receptor via vpn
  - FootOnsat - Informacion de eventos deportivos
  - vpn_wireguard - Para acceder via vpn 
  - skin op-artkoala
  - junglem3utobouquet - Para crearte favoritos enigma2 desde una lista m3u o favorito icam
  - epgmhw2 - Epg desde canal portada
  - JungleScript Tools - Plugin interfaz grafica junglescript          
EOF
    temporizador
    echo
    echo
	echo -e "${BLUE_BOLD}💡  Has decidido continuar, a continuacion:${RESET}"
	echo
	mensaje "⚠️  Podras ir eligiendo que paquetes deseas instalar o no" "${GREEN}"
	mensaje "⚠️  Durante este proceso Enigma2 se parara, una vez finalizada la ejecucion volvera a iniciarse." "${GREEN}"
	echo
    init 4 &

 }

#definimos instalacion de repositorio de emus de openatv OEA
function softcamfeed() {
    # Verificar si existe un archivo con el nombre que contiene "secret-feed.conf"
    if ls /etc/opkg/*secret-feed.conf >/dev/null 2>&1; then
    	echo
	    echo -e "${RED_BOLD}⚠️  El archivo secret-feed.conf ya existe en /etc/opkg/ - no se requiere la descarga.${RESET}"
	    echo
        return
    fi

    echo "Realizando instalacion de repositorio emuladoras"
    echo
    wget -O - -q http://updates.mynonpublic.com/oea/feed | bash | progress_bar 5
    echo
    echo "Finalizada instalacion de repositorio de emuladoras"
    echo "---------------------------------------------------------"
    echo
}

#Definimos la instalacion del repositorio jungle-team
function junglefeed() {
    if [ -f "/etc/opkg/jungle-feed.conf" ]; then
        echo
	    echo -e "${RED_BOLD}⚠️  El archivo jungle-feed.conf ya existe en /etc/opkg/ - no se requiere la descarga.${RESET}"
	    echo     
        return
    fi
    echo "Realizando instalacion de repositorio Jungle-Team"
    echo
    wget $REPOSITORIO_JUNGLE -P /etc/opkg/ >>$SPEEDY_LOG 2>&1 | progress_bar 3
    echo
    echo "Instalado repositorio Jungle-Team"
    echo "---------------------------------------------------------"
    echo
}

#funcion menu borrar logo speedy OEA
function borrar_log() {
	echo
	echo -e "${BLUE_BOLD}💡  Se ejecuta el borrado /var/log/speedy_autoinstall.log.${RESET}"
	echo
	if [ -f "$SPEEDY_LOG" ]; then
	    rm -r $SPEEDY_LOG >/dev/null 2>&1 | progress_bar 2
    fi
    echo
    echo
	echo -e "${RED_BOLD}⚠️  Se ha borrado /var/log/speedy_autoinstall.log en el caso de existir.${RESET}"
	echo
    sleep 3
    MENU_SPEEDY_OEA
}


function DEPENDENCIAS() {
    echo
    echo "-----------------------------------------------------------------------------------------------------------------------"
    echo "🐭 Comienzo Test de dependencias necesarias para la ejecucion sin errores del Speedy OEA"
    echo "-----------------------------------------------------------------------------------------------------------------------"
    echo
    # Verificar si ncurses está instalado
    if [ -z "$(opkg status ncurses-terminfo-base)" ]; then
        # Intentar instalar ncurses
        echo "ncurses no está instalado. Intentando instalar..."
        sleep 2
        opkg update >>$SPEEDY_LOG 2>&1
        if ! opkg install ncurses-terminfo-base >>$SPEEDY_LOG 2>&1; then
            echo "No se pudo instalar ncurses. Por favor, instale ncurses e inténtelo de nuevo."
            sleep 5
            exit 1
        fi
    fi
    echo
    echo -e "${RED_BOLD}⚠️  Las Dependencias necesarias ha sido instaladas o ya se encontraban instaladas. Se continúa la ejecución .......${RESET}"
    sleep 3
}



function cambiar_password() {
    local confirmacion="💡  ¿OpenAtv no tiene contraseña por defecto. ¿Desea asignarle una? entonces introduzca si + intro o intro para cancelar"
    echo -e "${BLUE_BOLD}$confirmacion${RESET}"
    read respuesta
    respuesta=$(echo "$respuesta" | tr '[:upper:]' '[:lower:]')  # Convertir la respuesta a minúsculas
    if [[ "$respuesta" == "si" ]]; then
        echo -n "Introduzca el valor para su contraseña: "
        read -s password
        echo
        if ! echo "root:$password" | chpasswd >>$SPEEDY_LOG 2>&1; then
            echo "Error: no se pudo cambiar la contraseña." >&2
            return 1
        fi
        echo "La contraseña se ha asignado correctamente. Su usuario es root y su contraseña es $password."
    else
        echo "No se cambia la contraseña."
    fi
}

function cambiar_arranque_emus() {
    local confirmacion="💡  En algunos receptores puede haber congelaciones al reiniciar receptor debido al arranque de la emu. ¿Desea modificar el arranque? entonces introduzca si + intro o intro para cancelar"
    echo -e "${BLUE_BOLD}$confirmacion${RESET}"
    read respuesta
    respuesta=$(echo "$respuesta" | tr '[:upper:]' '[:lower:]')  # Convertir la respuesta a minúsculas
    if [[ "$respuesta" == "si" ]]; then
        echo -n "se procede a cambiar el metodo de arranque "
        mv /etc/rc0.d/K50softcam /etc/rc0.d/K98softcam; mv /etc/rc1.d/K50softcam /etc/rc1.d/K98softcam; mv /etc/rc2.d/S50softcam /etc/rc2.d/S98softcam; mv /etc/rc3.d/S50softcam /etc/rc3.d/S98softcam; mv /etc/rc4.d/S50softcam /etc/rc4.d/S98softcam; mv /etc/rc5.d/S50softcam /etc/rc5.d/S98softcam; mv /etc/rc6.d/K50softcam /etc/rc6.d/K98softcam
        echo
    else
        echo "No se cambia el metodo de arranque."
    fi
}



function update() {

	echo "Se realiza actualizacion paquetes repositorios receptor"
	echo
    opkg update >>$SPEEDY_LOG 2>&1 | progress_bar 5
    echo
    echo "Actualizacion finalizada"
    echo "---------------------------------------------------------"
    echo   
      
}


function hora() {
    echo -e "${BLUE_BOLD}🧐   ¿Quieres ajustar el tiempo en el receptor?${RESET}"
    echo
    options=("Sí" "No")
    select opt in "${options[@]}"; do
        case $opt in
            "Sí")
                echo 
                echo "Ajustando la hora en el receptor......."
                echo
                ntpdate 2.es.pool.ntp.org >> $SPEEDY_LOG 2>&1 | progress_bar 5
    			echo
   				echo -e "${BLUE_BOLD}⚠️  la hora actual de su receptor es:${RESET}${YELLOW_BOLD} $FECHA_RECEPTOR${RESET}"
    			echo
                break;;
            "No")
            	echo
   				echo -e "${BLUE_BOLD}⚠️  No se ajusta la hora en su receptor${RESET}"
                echo
                break;;
            *) 
                echo
                echo -e "${RED_BOLD}⚠️   ️Opción inválida. Por favor, seleccione una opción válida.${RESET}";;
        esac
    done
}

#Define realizar backup de archivos del receptor
function backup_jungle() {
    echo
    echo -e "${YELLOW_BOLD}----------------------------------------------------------------------------------------${RESET}"
    echo -e "${YELLOW}ℹ️  Opcion realizar backup de archivos mas usuales:${RESET}"
    echo -e "${YELLOW}ingrese el valor numerico de los archivos que desee realizar${RESET}"
    echo -e "${YELLOW}el backup, si quiere seleccionar mas de un archivo separa${RESET}"
    echo -e "${YELLOW}con coma, ejemplo: 1,5,8 en cambio si desea realizar la${RESET}"
    echo -e "${YELLOW}copia de todos los archivos ingrese all${RESET}"
    echo -e "${YELLOW_BOLD}----------------------------------------------------------------------------------------${RESET}"
    echo
    archivos_etc=$(find /etc -type f \( -iname "oscam.*" -o -iname "CCcam.*" -o -iname "ncam.*" -o -iname "ghostreamy.*" -o -iname "epgimport.conf" -o -iname "CertResource.json" -o -iname "key.pem" -o -iname "simplecert.log" -o -iname "SSLUser.json" \) 2>&1 || true)
    archivos_usr_bin=$(find /usr/bin -type f \( -iname "enigma2_pre_start.conf" -o -iname "amigos.cfg" -o -iname "parametros.py" \) 2>&1 || true)

    opciones=()
    for archivo in $archivos_etc $archivos_usr_bin; do
        if [ -n "$archivo" ]; then
            opciones+=("$archivo")
        fi
    done
    seleccionados=()
    while true; do
    echo -e "${BLUE_BOLD}🛠  Menu Seleccionar Archivos para Backup:${RESET}"
        echo
        for ((i=0; i<${#opciones[@]}; i++)); do
            archivo="${opciones[$i]}"
            if [[ " ${seleccionados[@]} " =~ " ${archivo} " ]]; then
                echo -e "👍 $((i+1)). $archivo"
            else
                echo "$((i+1)). $archivo"
            fi
        done
        echo
        read -p "$(echo -e "${BLUE}💡 Ingrese los números de archivo que desea seleccionar (o 'all' para seleccionar todos, o 's' para salir): ${RESET}")" seleccion
        echo
        if [ "$seleccion" = "s" ]; then
            MENU_SPEEDY_OEA
        fi
        if [ "$seleccion" = "all" ]; then
            seleccionados=("${opciones[@]}")
            break
        fi
        IFS=',' read -ra opciones_seleccionadas <<< "$seleccion"
        for opcion in "${opciones_seleccionadas[@]}"; do
            if [ -n "${opciones[$((opcion-1))]}" ]; then
                seleccionados+=("${opciones[$((opcion-1))]}")
            else
                echo "Opción inválida: $opcion"
            fi
        done
    	read -p "$(echo -e "${BLUE}💡 Desea seleccionar otro archivo? (s/n): ${RESET}")" continuar
    	if [ "$continuar" = "n" ]; then
        	break
    	fi
	done

    printf "%s\n" "${seleccionados[@]}" > /tmp/backup_jungle.txt
    echo "Archivos seleccionados para backup guardados en /tmp/backup_jungle.txt"
    archivos=()
    while IFS= read -r archivo || [[ -n "$archivo" ]]; do
        archivos+=("$archivo")
    done < "/tmp/backup_jungle.txt"

	if [ ! -d "/media/hdd/backup_jungle" ]; then
    	mkdir -p "/media/hdd/backup_jungle"
	fi
	fecha=$(date +%Y%m%d%H%M%S)
	nombre_zip="/media/hdd/backup_jungle/backup_jungle_$fecha.zip"

	if [ ${#archivos[@]} -gt 0 ]; then
    	zip -r "$nombre_zip" "${archivos[@]}"
    	echo
    	echo -e "${RED}⚠️ Backup creando en  $nombre_zip${RESET}"
	else
    	echo "No se encontraron archivos seleccionados"
	fi
	sleep 5
    MENU_SPEEDY_OEA
}

# Define restaurar backup
function restaurar_backup() {
    echo
    echo -e "${YELLOW_BOLD}----------------------------------------------------------------------------------------${RESET}"
    echo -e "${YELLOW}ℹ️  Opcion de Restaurar Backup:${RESET}"
    echo -e "${YELLOW}ingrese el valor numerico del backup que desee restaurar${RESET}"
    echo -e "${YELLOW}a continuacion pulse intro y se procedera a la restauracion${RESET}"
    echo -e "${YELLOW}del backup seleccionado${RESET}"
    echo -e "${RED}Restaurar sobreescribe archivos si ya estuvieran en el receptor${RESET}"
    echo -e "${YELLOW_BOLD}----------------------------------------------------------------------------------------${RESET}"
    echo
    DIRECTORIO_BACKUP_JUNGLE=/media/hdd/backup_jungle
    ARCHIVOS_BACKUP_JUNGLE=("$DIRECTORIO_BACKUP_JUNGLE"/*.zip)
    if [ ${#ARCHIVOS_BACKUP_JUNGLE[@]} -eq 0 ]; then
        echo "No se encontraron archivos zip en el directorio especificado."
        MENU_SPEEDY_OEA
    fi
    echo -e "${BLUE_BOLD}🛠  Menu Seleccionar backup a restaurar:${RESET}"
    echo
    for ((i=0; i<${#ARCHIVOS_BACKUP_JUNGLE[@]}; i++)); do
        echo "$((i+1)). ${ARCHIVOS_BACKUP_JUNGLE[$i]}"
    done
	echo
    read -p "$(echo -e "${BLUE}💡 Ingrese el valor numero del backup a restaurar  o 's' para salir): ${RESET}")" SELECCION
    echo
    while ! [[ "$SELECCION" =~ ^[0-9]+$ ]] || ((SELECCION < 1 || SELECCION > ${#ARCHIVOS_BACKUP_JUNGLE[@]})); do
        if [ "$SELECCION" = "s" ]; then
            MENU_SPEEDY_OEA
        fi
        echo -e "${RED_BOLD}⚠️  La selección no es válida. Seleccione un número entre 1 y ${#ARCHIVOS_BACKUP_JUNGLE[@]} o s para salir.${RESET}"
        echo
    	read -p "$(echo -e "${BLUE}💡 Ingrese el valor numero del backup a restaurar  o 's' para salir): ${RESET}")" SELECCION
    done

    BACKUP_SELECCIONADO=${ARCHIVOS_BACKUP_JUNGLE[$((SELECCION-1))]}
    unzip -o "$BACKUP_SELECCIONADO" -d /
	echo
    echo -e "${RED_BOLD}⚠️ El backup $BACKUP_SELECCIONADO se ha restaurado${RESET}"
    sleep 5
    MENU_SPEEDY_OEA
}

#Se define introducir lineas cccam
function suerte_cccam() {
	echo
    echo -e "${BLUE}💡 Introduzca una o varias lineas, ejem. C: rioga.net 14200 tus muertos, cada vez que introduzca linea pulse intro, para salir escriba suerte: ${RESET}"
    echo
    while read linea
    do
        if [ "$linea" = "suerte" ]; then
            break  
        fi
        echo "$linea" >> /etc/CCcam.cfg
        echo "" >> /etc/CCcam.cfg
    done
    echo
    echo -e "${RED_BOLD}⚠️ Se ha actualizado el fichero CCcam.cfg, que tengas mucha suerte 🍀🤞🍀${RESET}"
    sleep 7    
}

function cambiar_parametros_junglebot() {
    while true; do
    	echo -e "${BLUE}💡  Deseas introducir los valores de TOKEN y CHAT_ID para junglebot (s/n) ${RESET}"
        read respuesta
        if [[ $respuesta =~ ^[Ss]$ ]]; then
            echo "💬 Introduce el nuevo valor para el token: "
            echo
            read -p "🔑️ " nuevo_token
            sed -i "s/BOT_TOKEN=.*/BOT_TOKEN=$nuevo_token/g" /usr/bin/junglebot/parametros.py

            echo "💬 Introduce el nuevo valor para el chat ID: "
            echo
            read -p "🔑️️️  " nuevo_chat_id
            sed -i "s/CHAT_ID=.*/CHAT_ID=$nuevo_chat_id/g" /usr/bin/junglebot/parametros.py
        elif [[ $respuesta =~ ^[Nn]$ ]]; then
            break
        fi
     	echo -e "${YELLOW}💡  Se vuelve a repetir por si te equivocaste en los valores, si no es el caso introduzca n para finalizar ${RESET}"
    done
	echo
	echo -e "${GREEN}✅ Valores de TOKEN y CHAT_ID actualizados correctamente${RESET}"

}

function logo(){
	clear
	echo -e "\e[32m${VERDE} ******************************************************************************\e[0m"
	echo -e "\e[32m${VERDE} *      _ _    _ _   _  _____ _      ______   _______ ______          __  __  *\e[0m"
    echo -e "\e[32m${VERDE} *     | | |  | | \ | |/ ____| |    |  ____| |__   __|  ____|   /\   |  \/  | *\e[0m"
    echo -e "\e[32m${VERDE} *     | | |  | |  \| | |  __| |    | |__ ______| |  | |__     /  \  | \  / | *\e[0m"
    echo -e "\e[32m${VERDE} *  _  | | |  | |     | | |_ | |    |  __|______| |  |  __|   / /\ \ | |\/| | *\e[0m"
    echo -e "\e[32m${VERDE} * | |_| | |__| | |\  | |__| | |____| |____     | |  | |____ / ____ \| |  | | *\e[0m"
    echo -e "\e[32m${VERDE} * \____/ \____/|_| \_|\_____|______|______|    |_|  |______/_/    \_\_|  |_| *\e[0m"        
	echo -e "\e[32m${VERDE} *        																	 *\e[0m"
	echo -e "\e[32m${VERDE} *                          SPEEDY OEA-OpenATV            					 *\e[0m"
	echo -e "\e[32m${VERDE} *      grupo telegram: https://t.me/joinchat/AFo2KEfzM5Tk7y3VgcqIOA          *\e[0m"
	echo -e "\e[32m${VERDE} *                            VERSION 1.4                                     *\e[0m"
	echo -e "\e[32m${VERDE} *                           jungle-team.com                                  *\e[0m"
	echo -e "\e[32m${VERDE} ******************************************************************************\e[0m"
}

function install_packages() {
 CompruebaInternet
 Menu_start_install
 hora
 softcamfeed
 junglefeed
 update
#Se ejecuta instalacion de paquetes propios de openatv
 Modulo_package_gestion "$PAQUETE_EPGIMPORT" "🧐  Opciones Solicitud de instalacion EPGIMPORT" "$INSTALACION_NORMAL" "5"
 Modulo_package_gestion "enigma2-plugin-softcams-oscam-trunk-ipv4only" "🧐  Opciones Solicitud de instalacion Oscam Trunk" "$INSTALACION_FORZADA" "5"
 Modulo_package_gestion "enigma2-plugin-softcams-oscam-icam" "🧐  Opciones Solicitud de instalacion Oscam Icam" "$INSTALACION_FORZADA" "5"
 Modulo_package_gestion "enigma2-plugin-softcams-ncam" "🧐  Opciones Solicitud de instalacion Ncam" "$INSTALACION_FORZADA" "5"
 Modulo_package_gestion "enigma2-plugin-softcams-cccam" "🧐  Opciones Solicitud de instalacion CCcam 2.3.2 64 bits spain" "$INSTALACION_FORZADA" "5" "extra_comando" "$COMANDO_CCCAM"
 cambiar_arranque_emus
 Modulo_package_gestion "zerotier" "🧐  Opciones Solicitud de instalacion Zerotier" "$INSTALACION_FORZADA" "5"
 Modulo_package_gestion "tailscale" "🧐  Opciones Solicitud de instalacion Tailscale" "$INSTALACION_FORZADA" "5"
 Modulo_package_gestion "openvpn" "🧐  Opciones Solicitud de instalacion Openvpn" "$INSTALACION_NORMAL" "5"
 Modulo_package_gestion "enigma2-plugin-extensions-bouquetmakerxtream" "🧐  Opciones Solicitud de instalacion bouquetmakerxtream" "$INSTALACION_NORMAL" "5"
 Modulo_package_gestion "enigma2-plugin-extensions-jediepgxtream" "🧐  Opciones Solicitud de instalacion jediepgxtream" "$INSTALACION_NORMAL" "5"
 Modulo_package_gestion "enigma2-plugin-extensions-xklass" "🧐  Opciones Solicitud de instalacion xklass" "$INSTALACION_NORMAL" "5"
 Modulo_package_gestion "streamproxy" "🧐  Opciones Solicitud de instalacion streamproxy" "$INSTALACION_NORMAL" "5"
#Se ejecuta instalacion de paquetes de jungle-team
 Modulo_package_gestion "$PAQUETE_OSCAMCONCLAVE" "🧐  Opciones Solicitud de instalacion Oscam Conclave" "$INSTALACION_FORZADA" "10"
 if [ "$es_arm" -gt 0 ];
 then
	 Modulo_package_gestion "$PAQUETE_GHOSTREAMY_ARM" "🧐  Opciones Solicitud de instalacion Ghostreamy" "$INSTALACION_FORZADA" "10"
 else
     Modulo_package_gestion "$PAQUETE_GHOSTREAMY_MIPSEL" "🧐  Opciones Solicitud de instalacion Ghostreamy" "$INSTALACION_FORZADA" "10"
 fi
 Modulo_package_gestion "$PAQUETE_JUNGLEBOT" "🧐  Opciones Solicitud de instalacion Junglebot" "$INSTALACION_FORZADA" "45" "extra_comando" "$COMANDO_JUNGLEBOT"
 Modulo_package_gestion "$PAQUETE_TDTCHANNLES" "🧐  Opciones Solicitud de instalacion TdtChannels" "$INSTALACION_NORMAL" "5"
 Modulo_package_gestion "enigma2-plugin-extensions-junglem3utobouquet" "🧐  Opciones Solicitud de instalacion junglem3utobouquet" "$INSTALACION_NORMAL" "5"
 Modulo_package_gestion "$PAQUETE_JUNGLESCRIPT" "🧐  Opciones Solicitud de instalacion JungleScript" "$INSTALACION_FORZADA" "10" "extra_comando" "$COMANDO_JUNGLESCRIPT"
 if [ "$es_arm" -gt 0 ];
 then
     Modulo_package_gestion "enigma2-plugin-extensions-movistarepgdownload-arm" "🧐  Opciones Solicitud de instalacion movistarepgdownload" "$INSTALACION_NORMAL" "5"
 else
     Modulo_package_gestion "enigma2-plugin-extensions-movistarepgdownload-mipsel" "🧐  Opciones Solicitud de instalacion movistarepgdownload-arm" "$INSTALACION_NORMAL" "5"
 fi
 if [ "$es_arm" -gt 0 ];
 then
     Modulo_package_gestion "sendunicable" "🧐  Opciones Solicitud de instalacion sendunicable" "$INSTALACION_NORMAL" "5"
 else
     echo -e "${BLUE_BOLD}⚠️  No disponible para receptores mipsel${RESET}"
 fi
 Modulo_package_gestion "enigma2-plugin-skins-op-artkoala" "🧐  Opciones Solicitud de instalacion skin OP-Artkoala" "$INSTALACION_FORZADA" "10"
 Modulo_package_gestion "enigma2-plugin-extensions-junglescripttool" "🧐  Opciones Solicitud de instalacion JungleScript Tools" "$INSTALACION_FORZADA" "5"
#Instalaciones especiales
 Modulo_package_gestion "enigma2-plugin-extensions-footOnsat" "🧐  Opciones Solicitud de instalacion FootOnsat" "$INSTALACION_NORMAL" "5" "extra_comando" "$COMANDO_FOOTONSAT"
 Modulo_package_gestion "enigma2-plugin-extensions-bootlogojungle" "🧐  Opciones Solicitud de instalacion Bootlogo Speedy OEA" "$FORZAR_ESCRITURA" "5"
 cambiar_password 
 init 3
 mensaje "Terminada la ejecucion de Speedy OEA Autoinstall, ahora se volvera al menu principal${GREEN}"
 mensaje "❤️  Gracias por haber usado el instalador Jungle-Team visite https://t.me/joinchat/AFo2KEfzM5Tk7y3VgcqIOA para soporte${RED}"
 sleep 5
 MENU_SPEEDY_OEA
 
}

function remove() {
    echo -e "${BLUE}💡  Se va a proceder a desinstalar todos los paquetes instalados${RESET}"
    temporizador
    echo
    if [ -n "$($ESTATUS_PAQUETE $PAQUETE_EPGIMPORT)" ]; then
        echo "Desinstalando Epgimport"; echo; $BORRAR_PAQUETE $PAQUETE_EPGIMPORT >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 Epgimport Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE $PAQUETE_JUNGLESCRIPT)" ]; then
        echo "Desinstalando Junglescript"; echo; $BORRAR_PAQUETE $PAQUETE_JUNGLESCRIPT >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 JungleScript Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE $PAQUETE_JUNGLEBOT)" ]; then
        echo "Desinstalando Jungleblot"; echo; $BORRAR_PAQUETE $PAQUETE_JUNGLEBOT >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 Junglebot Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE $PAQUETE_GHOSTREAMY_ARM)" ]; then
        echo "Desinstalando Ghostreamy"; echo; $BORRAR_PAQUETE $PAQUETE_GHOSTREAMY_ARM >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 Ghostreamy Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE $PAQUETE_GHOSTREAMY_MIPSEL)" ]; then
        echo "Desinstalando Ghostreamy"; echo; $BORRAR_PAQUETE $PAQUETE_GHOSTREAMY_MIPSEL >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 Ghostreamy Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE $PAQUETE_OSCAMCONCLAVE)" ]; then
        echo "Desinstalando Oscam Conclave"; echo; $BORRAR_PAQUETE $PAQUETE_OSCAMCONCLAVE >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 OscamConclave Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE $PAQUETE_TDTCHANNLES)" ]; then
        echo "Desinstalando TdtChannels"; echo; $BORRAR_PAQUETE $PAQUETE_TDTCHANNLES >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 TdtChannels Desinstalado"
    fi
     if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-softcams-oscam-trunk-ipv4only)" ]; then
        echo "Desinstalando Oscam Trunk"; echo; $BORRAR_PAQUETE enigma2-plugin-softcams-oscam-trunk-ipv4only >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 Oscam Trunk Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-softcams-oscam-icam)" ]; then
        echo "Desinstalando Oscam icam"; echo; $BORRAR_PAQUETE enigma2-plugin-softcams-oscam-icam >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 Oscam icam Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-softcams-ncam)" ]; then
        echo "Desinstalando Oscam ncam"; echo; $BORRAR_PAQUETE enigma2-plugin-softcams-ncam >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 Oscam ncam Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE zerotier)" ]; then
        echo "Desinstalando zerotier"; echo; $BORRAR_PAQUETE zerotier >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 zerotier Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE tailscale)" ]; then
        echo "Desinstalando tailscale"; echo; $BORRAR_PAQUETE tailscale >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 tailscale Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE openvpn)" ]; then
        echo "Desinstalando openvpn"; echo; $BORRAR_PAQUETE openvpn >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 openvpn Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-extensions-bouquetmakerxtream)" ]; then
        echo "Desinstalando bouquetmakerxtream"; echo; $BORRAR_PAQUETE enigma2-plugin-extensions-bouquetmakerxtream >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 jedimakerxtream Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-extensions-jediepgxtream)" ]; then
        echo "Desinstalando jediepgxtream"; echo; $BORRAR_PAQUETE enigma2-plugin-extensions-jediepgxtream >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 jediepgxtream Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-extensions-xklass)" ]; then
        echo "Desinstalando xklass"; echo; $BORRAR_PAQUETE enigma2-plugin-extensions-xklass >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 xklass Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE streamproxy)" ]; then
        echo "Desinstalando streamproxy"; echo; $BORRAR_PAQUETE streamproxy >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 streamproxy Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-extensions-movistarepgdownload-arm)" ]; then
        echo "Desinstalando movistarepgdownload"; echo; $BORRAR_PAQUETE enigma2-plugin-extensions-movistarepgdownload-arm >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 movistarepgdownload Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-extensions-movistarepgdownload-mipsel)" ]; then
        echo "Desinstalando movistarepgdownload"; echo; $BORRAR_PAQUETE enigma2-plugin-extensions-movistarepgdownload-mipsel >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 movistarepgdownload Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE sendunicable)" ]; then
        echo "Desinstalando sendunicable"; echo; $BORRAR_PAQUETE sendunicable >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 sendunicable Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-skins-op-artkoala)" ]; then
        echo "Desinstalando op-artkoala"; echo; $BORRAR_PAQUETE enigma2-plugin-skins-op-artkoala >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 op-artkoala Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-extensions-junglescripttool)" ]; then
        echo "Desinstalando junglescripttool"; echo; $BORRAR_PAQUETE enigma2-plugin-extensions-junglescripttool >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 junglescripttool Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-extensions-footOnsat)" ]; then
        echo "Desinstalando footOnsat"; echo; $BORRAR_PAQUETE enigma2-plugin-extensions-footOnsat >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 footOnsat Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-softcams-cccam)" ]; then
        echo "Desinstalando CCcam"; echo; $BORRAR_PAQUETE enigma2-plugin-softcams-cccam >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 CCcam Desinstalado"
    fi
    if [ -n "$($ESTATUS_PAQUETE enigma2-plugin-extensions-junglem3utobouquet)" ]; then
        echo "Desinstalando junglem3utobouquet"; echo; $BORRAR_PAQUETE enigma2-plugin-extensions-junglem3utobouquet >>$SPEEDY_LOG 2>&1 | progress_bar 5; echo "👍 junglem3utobouquet Desinstalado"
    fi                                                                                                                                                                                                                            
    echo
    echo "----Espere, dentro de 5 segundos se volvera al menu principal-----"
    sleep 5
    MENU_SPEEDY_OEA
}

function ayuda () {

    logo
	echo
	echo -e "${BLUE}💡  Debes tener en cuenta estas consideraciones sobre el funcionamiento de Speedy OEA${RESET}"
	echo
	echo -e "${RED}💡  Este menu se cerrara automaticamente en 20 Segundos retornando al menu principal, no toque nada hasta que se cierre${RESET}"
	echo
	echo -e "${YELLOW}---------------------------------------------------------------------------------------------------"
	cat << "EOF"
  - Speedy OEA auto install no se instala en el receptor, simplemente puedes ir
	seleccionando utilidades a instalar.
  - Durante la instalacion Guiada podras ir seleccionando que paquetes instalar,
  	esta seleccion sera introduciendo los parametros necesarios.
  - Tenemos menu de desinstalacion si deseamos borrar todo lo instalado referente a
    paquetes especificos de jungle-team.
  - Puede crear backup de archivos configuracion mas usuales y restaurarlos  
  - Del proceso de instalacion se crea log en /var/log/speedy_autoinstall.log
  - Grupo telegram ayuda: https://t.me/joinchat/AFo2KEfzM5Tk7y3VgcqIOA 
  - Github: https://github.com/jungla-team/Speedy-OEA-autoinstall
  - web: jungle-team.com
      
EOF
   echo "-----------------------------------------------------------------------------------------------------------------"
   echo -e "${RESET}"
   sleep 20
   MENU_SPEEDY_OEA
}

 TEST_INTERNET
 DEPENDENCIAS
 MENU_SPEEDY_OEA
