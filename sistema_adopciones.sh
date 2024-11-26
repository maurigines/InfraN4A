#!/bin/bash

clear

admin_file="admins.txt"
client_file="clients.txt"
mascotas_file="mascotas.txt"
adopciones_file="adopciones.txt"

[[ ! -f $admin_file ]] && touch $admin_file
[[ ! -f $client_file ]] && touch $client_file
[[ ! -f $mascotas_file ]] && touch $mascotas_file
[[ ! -f $adopciones_file ]] && touch $adopciones_file

if [[ ! -s $admin_file ]]; then
    echo "admin:admin" >> $admin_file
fi

login() {
    echo "******************************        LOGIN      ******************************"
    echo 
    echo "Ingrese su usuario (cédula):"
    read user
    echo "Ingrese su contraseña:"
    read -s password

    if grep -q "$user:$password" "$admin_file"; then
        clear
        echo "Autenticación exitosa como administrador"
        echo 
        admin_menu
    elif grep -q "$user:$password" "$client_file"; then
        clear
        echo "Autenticación exitosa como cliente"
        echo
        client_menu $user
    else
        echo "Credenciales incorrectas"
        exit 1
    fi
}



admin_menu() {
    while true; do
        echo "*********************        Menú de administrador      *********************"
        echo "1. Registrar Usuario"
        echo "2. Registrar Mascota"
        echo "3. Ver Estadísticas"
        echo "4. Salir"
        read -p "Seleccione una opción: " opt

        case $opt in
            1) registrar_usuario ;;
            2) registrar_mascota ;;
            3) ver_estadisticas ;;
            4) echo "Saliendo..."; exit ;;
            *)  clear
                echo "Opción inválida";;
        esac
    done
}

client_menu() {
    while true; do
        echo "*********************        Menú de cliente      *********************"
        echo "1. Listar Mascotas Disponibles"
        echo "2. Adoptar Mascota"
        echo "3. Salir"
        read -p "Seleccione una opción: " opt

        case $opt in
            1) listar_mascotas ;;
            2) adoptar_mascota $1 ;;
            3) echo "Saliendo..."; exit ;;
            *) echo "Opción inválida";;
        esac
    done
}



registrar_usuario() {
    echo "Ingrese nombre:"
    read nombre
    echo "Ingrese cédula:"
    read cedula
    echo "Ingrese teléfono:"
    read telefono
    echo "Ingrese fecha de nacimiento (dd/mm/yyyy):"
    read fecha_nac
    echo "Ingrese contraseña:"
    read -s password

    if grep -q "$cedula" "$admin_file" || grep -q "$cedula" "$client_file"; then
        clear
        echo
        echo "Usuario ya registrado."
        return
    fi

    echo "Es administrador o cliente? (a/c):"
    read tipo

    while [[ "$tipo" != "a" && "$tipo" != "c" ]]; do
        clear
        echo "Opción inválida. Inténtalo de nuevo."
        echo "Es administrador o cliente? (a/c):"
        read tipo
    done

    if [[ "$tipo" == "a" ]]; then
        echo "$cedula:$password" >> $admin_file
    elif [[ "$tipo" == "c" ]]; then
        echo "$cedula:$password" >> $client_file
    else
        echo "Opción inválida."
    fi

    echo "Usuario registrado."
}


registrar_mascota() {
    echo "Ingrese ID:"
    read id
    if grep -q "^$id" "$mascotas_file"; then
        echo "ID en uso."
        return
    fi

    echo "Ingrese tipo (Perro/Gato/etc):"
    read tipo
    echo "Ingrese nombre:"
    read nombre
    
    echo "Ingrese sexo Macho-Hembra (m/h):"
    read sexo

    while [[ "$sexo" != "m" && "$sexo" != "h" ]]; do
        clear
        echo "Opción inválida. Inténtalo de nuevo."
        echo "Ingrese sexo (m/h):"
        read sexo
    done

    echo "Ingrese edad:"
    read edad
    echo "Ingrese descripción:"
    read descripcion
    echo "Ingrese fecha de ingreso (dd/mm/yyyy):"
    read fecha_ingreso

    echo "$id:$tipo:$nombre:$sexo:$edad:$descripcion:$fecha_ingreso" >> $mascotas_file
    echo "Mascota registrada."
}


listar_mascotas() {
    echo
    echo "Mascotas disponibles:"
    echo
    [[ ! -s $mascotas_file ]] && echo "No hay mascotas." && return
    cat $mascotas_file | while IFS=":" read -r id tipo nombre sexo edad descripcion fecha; do
        echo "$id - $tipo - $nombre - $edad años - $descripcion"
    done
    echo
    echo
}

adoptar_mascota() {
    listar_mascotas
    [[ ! -s $mascotas_file ]] && return

    echo "Ingrese el ID de la mascota:"
    read id_mascota

    while ! grep -q "^$id_mascota:" "$mascotas_file"; do
        echo "ID no válido."
        echo "Ingrese el ID de la mascota:"
        read id_mascota
    done


    fecha_adopcion=$(date +%d/%m/%Y)

    grep "^$id_mascota" "$mascotas_file" >> $adopciones_file
    echo "Adoptado por $1 el $fecha_adopcion" >> $adopciones_file
    sed -i '' "/^$id_mascota/d" "$mascotas_file"

    clear
    echo "Adopción registrada."
}




ver_estadisticas() {
    total_mascotas=$(wc -l < $mascotas_file)
    total_adopciones=$(wc -l < $adopciones_file)

    [[ $total_adopciones -eq 0 ]] && echo "No hay adopciones." && return

    echo "Mascotas en adopción: $total_mascotas"
    echo "Adopciones: $total_adopciones"

    awk -F ":" '{print $2}' $adopciones_file | sort | uniq -c | while read -r count tipo; do
        porcentaje=$((count * 100 / total_adopciones))
        echo "$tipo: $porcentaje%"
    done

    awk -F ":" '{print $NF}' $adopciones_file | cut -d'/' -f2 | sort | uniq -c | sort -nr | head -n1 | while read -r count mes; do
        echo "Mes con más adopciones: $mes ($count)"
    done

    awk -F ":" '{sum+=$5; count+=1} END {print "Edad promedio: " sum/count " años"}' $adopciones_file
}


login