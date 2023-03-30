#!/bin/bash
#Menu opciones para junglescript
#Realizado por Jungle-team
#Version 2.0
#==============================================================================
VERDE='\033[0;32m'
ROJO='\033[0;31m'
NC='\033[0m'
negrita='\033[1m'

rojo='\033[0;31m'
verde='\033[0;32m'
blanco='\033[0;37m'
azul='\033[0;34m'
borrar='\033[0m'
amarillo='\033[0;33m' 
NC='\033[0m'


#Opciones de instalacion junglescript
options[0]="Instalar lista Canales Astra"
options[1]="Instalar lista Canales Astra-Hotbird"
options[2]="Instalar lista Canales Astra-Hispasat"
options[3]="Instalar lista Canales Astra-Hispasat-Hotbird"
options[4]="Instalar lista Canales Astra Comunitarias"
options[5]="Activar Picon (marcar si deseas instalacion picon)"
options[6]="Instalar Picon Version original"
options[7]="Instalar Picon Version Color"
options[8]="Instalar Picon Version Lunar"

#Acciones
function JUNGLESCRIPT {
    if [[ ${choices[0]} ]]; then
        echo -e "${negrita}${amarillol}* Has seleccionado instalacion Astra${borrar}"
        lista="astra"
    fi
    if [[ ${choices[1]} ]]; then
        echo -e "${negrita}${amarillol}* Has seleccionado instalacion Astra-hotbird${borrar}"
        lista="astra-hotbird"
    fi
    if [[ ${choices[2]} ]]; then
        echo -e "${negrita}${amarillol}* Has seleccionado instalacion Astra-hispasat${borrar}"
        lista="astra-hispasat"
    fi
    if [[ ${choices[3]} ]]; then
        echo -e "${negrita}${amarillol}* Has seleccionado instalacion Astra-hotbird-hispasat${borrar}"
        lista="astra-hotbird-hispasat"
    fi
    if [[ ${choices[4]} ]]; then
        echo -e "${negrita}${amarillol}* Has seleccionado instalacion Astra-Comunitaria${borrar}"
        lista="astra-comunitaria"
    fi
    if [[ ${choices[5]} ]]; then
        echo -e "${negrita}${amarillol}* Has seleccionado Activacion de Picon${borrar}"
        picon=1
    fi
    if [[ ${choices[6]} ]]; then
        echo -e "${negrita}${amarillol}* Has seleccionado picon original${borrar}"
        tipopicon=movistar-original
    fi
    if [[ ${choices[7]} ]]; then
        echo -e "${negrita}${amarillol}* Has seleccionado picon color${borrar}"
        tipopicon=movistar-color
    fi
    if [[ ${choices[8]} ]]; then
        echo -e "${negrita}${amarillol}* Has seleccionado picon lunar${borrar}"
        tipopicon=movistar-lunar
    fi
     
    
	   cat <<EOF > /usr/bin/enigma2_pre_start.conf
LISTACANALES=$lista
PICONS=$picon
TIPOPICON=$tipopicon
EOF

}

#Variables
ERROR=" "



#borrar opciones menu
clear

#funcion de menu
function MENU {
    echo -e "${negrita}${azul}OPCIONES DE INSTALACION DE JUNGLESCRIPT${borrar}"
    echo "-------------------------------------------------------------------------------------------------------------------------------------------"
    echo ""
    echo -e "${negrita}${rojo}-introduzca el valor numerico si es de un digito pulsar enter para confirmar${borrar}"
    echo -e "${negrita}${rojo}-Si ha seleccionado erroneamente vuelve a introducir el mismo valor numerico para deseleccionar${borrar}"
    echo -e "${negrita}${rojo}-Al finalizar la seleccion de las opciones pulsar enter para terminar${borrar}"
    echo -e "${negrita}${rojo}-Si desea cambiar las opciones una vez terminado autosonic modifique el archivo /usr/bin/enigma2_pre_start.conf${borrar}"
    echo ""
    echo "-------------------------------------------------------------------------------------------------------------------------------------------"
    echo ""
    for NUM in ${!options[@]}; do
        echo "[""${choices[NUM]:- }""]" $(( NUM+1 ))") ${options[NUM]}"
    done
    echo "$ERROR"
}

#Menu instalacion
while MENU && read -e -p "Introduzca las opciones de instalacion introduciendo su valor numerico para marcarlas: " -n2 SELECTION && [[ -n "$SELECTION" ]]; do
    clear
    if [[ "$SELECTION" == *[[:digit:]]* && $SELECTION -ge 1 && $SELECTION -le ${#options[@]} ]]; then
        (( SELECTION-- ))
        if [[ "${choices[SELECTION]}" == "+" ]]; then
            choices[SELECTION]=""
        else
            choices[SELECTION]="X"
        fi
            ERROR=" "
    else
        ERROR="Opcion invalida: $SELECTION"
    fi
done


JUNGLESCRIPT