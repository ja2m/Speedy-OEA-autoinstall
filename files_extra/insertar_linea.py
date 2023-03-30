# -*- coding: utf-8 -*-
def guardar_linea():
    host = input("Ingrese su host: ")
    puerto = input("Ingrese su puerto: ")
    usuario = input("Ingrese su usuario: ")
    password = input("Ingrese su password: ")

    try:
        with open("/etc/CCcam.cfg", "a") as archivo:
            archivo.write("\nC: " + host + " " + puerto + " " + usuario + " " + password)
    except FileNotFoundError:
        with open("/etc/CCcam.cfg", "w") as archivo:
            archivo.write("C: " + host + " " + puerto + " " + usuario + " " + password)

    print("La linea se ha guardado en el archivo /etc/CCcam.cfg")

try:
    respuesta = input("¿Desea introducir una linea CCcam? (s/n): ")
    if respuesta == "s":
        guardar_linea()
except:
    print("No instroducen datos.")

