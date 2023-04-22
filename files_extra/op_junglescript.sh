#!/bin/bash
# Menu opciones para junglescript
# Realizado por Jungle-team
# Version 3.0
#==============================================================================

# Ruta al archivo de configuración
CONFIG_FILE="/usr/bin/enigma2_pre_start.conf"

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


# Opciones de configuracion de  junglescript
options=(
    "Activar lista Canales (marcar si deseas instalacion lista canales)"
    "Instalar lista Canales Astra"
    "Instalar lista Canales Astra-Hotbird"
    "Instalar lista Canales Astra-Hispasat"
    "Instalar lista Canales Astra-Hispasat-Hotbird"
    "Instalar lista Canales Astra Comunitarias"
    "Activar Picon (marcar si deseas instalacion picon)"
    "Instalar Picon Version original"
    "Instalar Picon Version Color"
    "Instalar Picon Version Lunar"
)

# Acciones
function JUNGLESCRIPT {
    lista=0
    listacanales=""
    picon=0
    tipopicon=""

    # Asignar valores a las variables según las opciones seleccionadas
    for i in ${!choices[@]}; do
        if [[ ${choices[i]} ]]; then
            case $i in
                0) lista=1 ;;
                1) listacanales="astra" ;;
                2) listacanales="astra-hotbird" ;;
                3) listacanales="astra-hispasat" ;;
                4) listacanales="astra-hotbird-hispasat" ;;
                5) listacanales="astra-comunitaria" ;;
                6) picon=1 ;;
                7) tipopicon="movistar-original" ;;
                8) tipopicon="movistar-color" ;;
                9) tipopicon="movistar-lunar" ;;
            esac
        fi
    done

    # Actualizar variables en el archivo de configuración
    sed -i "s/^LISTA=.*/LISTA=$lista/" $CONFIG_FILE
    sed -i "s/^LISTACANALES=.*/LISTACANALES=$listacanales/" $CONFIG_FILE
    sed -i "s/^PICONS=.*/PICONS=$picon/" $CONFIG_FILE
    sed -i "s/^TIPOPICON=.*/TIPOPICON=$tipopicon/" $CONFIG_FILE
}

# Variables
ERROR=" "

# Borrar opciones menú
clear

# Función de menú
function MENU {
    echo -e "${BLUE_BOLD}OPCIONES DE CONFIGURACION DE JUNGLESCRIPT${RESET}"
    echo
    echo -e "${YELLOW}-------------------------------------------------------------------------------------------------------------------------------------------"
    echo
    echo  "-introduzca el valor numerico si es de un digito pulsar enter para confirmar"
    echo  "-Si ha seleccionado erroneamente vuelve a introducir el mismo valor numerico para deseleccionar"
    echo  "-Al finalizar la seleccion de las opciones pulsar enter para terminar"
    echo  "-Si desea cambiar las opciones una vez terminado SPEEDY modifique el archivo /usr/bin/enigma2_pre_start.conf"
    echo
    echo -e "-------------------------------------------------------------------------------------------------------------------------------------------${RESET}"
    echo 
    echo
    echo -e "${GREEN_BOLD}Selecciona las opciones que desees instalar y presiona ENTER${RESET}"
    echo

    # Mostrar las opciones del menú con su estado actual
    for i in ${!options[@]}; do
        # Verificar si la opción está seleccionada
        if [[ ${choices[i]} ]]; then
            echo -e "${amarillo}[$i] [👍] ${options[i]}${NC}"
        else
            echo -e "${amarillo}[$i] [ ] ${options[i]}${NC}"
        fi
    done
}

# Menú de opciones
while true; do
    clear
    MENU
    echo
    read -p $'\033[1;32m'"Selecciona una opción: "$'\033[0m' opcion


    # Comprobar si la opción es válida
    if [[ $opcion =~ ^[0-9]+$ ]] && [ "$opcion" -ge 0 ] && [ "$opcion" -lt ${#options[@]} ]; then
        # Alternar la selección de la opción
        if [[ ${choices[opcion]} ]]; then
            choices[opcion]=""
        else
            choices[opcion]="1"
        fi
    # Si la opción no es válida, mostrar mensaje de error
    elif [[ $opcion == '' ]]; then
        break
    else
        echo -e "${RED_BOLD}ERROR: Opción inválida${RESET}"
        sleep 2
    fi
done

# Ejecutar la función JUNGLESCRIPT para aplicar las opciones seleccionadas
JUNGLESCRIPT
