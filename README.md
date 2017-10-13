# Ambiente de desarrollo
Este proyecto consta de una serie de scripts para levantar un servidor virtual con una configuracion no monolitica, la idea es que los desarrolladores empiecen a pensar en que sus desarrollos no van a ir enfocados a un solo nodo, si no a multiples, especialmente en empresas grandes donde su infraestructura es mas robusta.

## Requerimientos

Para usar este proyecto es necesario tener instalado lo siguiente:

* virtualbox
* vagrant
* putty (en caso de estar usando windows)


Para hacer accesibles las paginas publicadas por el servidor virtual, necesitamos poner 
las siguientes lineas en el archivo hosts (/etc/hosts en linux y mac, 
C:\windows\system32\drivers\etc\hosts para windows )

    192.168.86.10 www.wrappergraylogzendlogger.local.com

Es importante comentar que la resolucion de nombres, esta en cada uno de los servidores y responden a la siguiente manera:

    192.168.86.11 magentotraining.local.com (No agregar al /etc/hosts, cuenta con restricciones de firewall)
    192.168.86.11 magento2training.local.com

## Modo de uso
Una vez que tenemos la configuración correcta podemos manipular el servidor virtual desde la linea de comandos
con los siguientes comandos

### Iniciar el servidor:
    
    vagrant  up
    
La primera vez que se usa este comando, vagrant genera y configura el servidor virtual,
por lo que es probable que se tarde varios minutos.   

### Detener el servidor:

    vagrant halt 

### Aplicar cambios en los archivos de configuración

    vagrant reload --provision
    
Esto se hará cada vez que hagamos una corrección en los scripts de este proyecto para
que los servidores de cada uno tome los cambios, obvio habrá que hacer un "git pull"  previamente. 
  
### Destruir la maquina

    vagrant destroy
    
Esta instrucción destruye el servidor virtual y debe ser usada con cuidado, 
es útil en el caso de que se desee liberar espacio en disco, cuando ya no se ocupe más
el servidor, o en caso de querer iniciar con un servidor limpio.
    
Los datos en las carpetas de los proyectos no se ven afectados.
    
Si después de ejecutar este comando ejecutamos una vez mas vagrant up, 
la maquina se volverá a generar desde cero.

### Ingresar por ssh al servidor

    vagrant ssh
    
Este comando es muy útil para revisar logs del servidor, hacer cambios manuales a la configuración reiniciar servicios etc. 
    
Recuerda que cualquier configuración especial que hagas a mano aquí
diferirá de la configuración que tienen los demás y se perderá si ejecutas 
vagrant destroy o en algunos casos si ejecutas vagrant reload --provision,
si deseas hacer una configuración que se pueda regenerar automáticamente, 
hay que hacerlo en los scripts de este proyecto, en puppet o en sh.

# FAQ

### ¿ Qué servicios provee el servidor virtual ?

El servidor virtual creado por vagrant con los archivos de este proyecto, tiene instalado:

     nginx
     compass
     nodejs
     npm
     php-fpm 5.6
     mysql
     xdebug
     y una serie de librerías de php

### Memcached
Para verficar que el servicio esta funcionando, por favor de correr:
    
        netstat -tulpn | grep :11211

Para verificar el estatus del servidor memcached, se deberá de usar memcached-tool

        memcached-tool 127.0.0.1 stats

Para el borrado de la cache por favor usar :
    
        telnet 127.0.0.1 11211
        flush_all

### Errores

Puedes conectarte al servidor ejecutando vagrant ssh app01 o app02, y revisar los logs
los logs de php los puedes encontrar en.
    
    /var/log/php-fpm/www-error.log
    
Te recomiendo ejecutar dentro del servidor
    tail -f /var/log/php-fpm/www-error.log


# Cualquier otra duda o problema, pueden contactarme para revisarlo y corregirlo.
@author Ricardo Ruiz Cruz <ricardojesus.ruizcruz@gmail.com>
