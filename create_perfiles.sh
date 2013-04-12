#!/bin/bash
#
# GNU bash, versión 4.1.7(1)-release
# Script para generar los grupos y usuarios con sus correspondientes directorios y permisos
# Autor Gonzalo Fleitas

user=''
passwd=''
group=''
directory=''

echo "Agregando grupos..."
for i in $(cat groups.txt);
do
	group=$i
	groupadd $group
	echo "Grupo "$i" Agregado."
done

echo ""

echo "Agregando usuarios..."
for i in $(cat users.txt);
do
	user=`echo $i | awk -F: '{print $1}'`
	passwd=`echo $i | awk -F: '{print $2}'`
	group=`echo $i | awk -F: '{print $3}'`
	directory=`echo $i | awk -F: '{print $4}'`

	# Agrego usuario del sistema con su grupo y su directorio personal.
	useradd $user -g $group -d $directory -s /sbin/nologin

	# Seteo la contraseña al usuario recien creado.
	echo -e "$passwd\n$passwd" | smbpasswd -a $user -s

	# Seteo el propietario y grupo al directorio personal del usuario.
	chown $user:$group $directory
	# Seteo permiso total a su directorio solo al propietario.
	chmod 700 $directory

	# Genero el archivo con la configuracion de los directorios para samba
	echo -e "[$user]\n\tcomment = Carpeta personal de $user\n\tpath = $directory\n\twritable = yes\n\tvalid users = $user\n" >> smb.conf.txt
done

echo "Archivo smb.conf generado. Ahora solo falta agregar las lineas generadas del archivo smb.conf.txt en el archivo de configuracion de samba (smb.conf)"
