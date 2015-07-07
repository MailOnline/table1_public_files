#!/usr/bin/env bash
set -e 
[ $DEBUG ] && set -x

environment=$1

public_files_base="https://bitbucket.org/MailOnline/table1_public_files/src/master"

if [ -z "$environment" ]; then
    echo "USAGE: $0 <environment>"
    exit 2
fi

if ! cat $HOME/.profile | grep  '/command' > /dev/null; then echo "PATH=/command:\$PATH" >> $HOME/.profile;  fi
if ! cat /etc/profile | grep 'NODE_ENV'; then echo "export NODE_ENV=$environment" >> /etc/profile; fi
if ! cat /etc/profile | grep '/opt/local/bin'; then echo "export PATH=/opt/local/bin:\$PATH" >> /etc/profile; fi
if ! cat /etc/profile | grep '/command'; then echo "export PATH=/command:\$PATH" >> /etc/profile; fi

uname=$(uname | perl -ne 'print lc')
pkg="dt-$uname.tar.gz"

mkdir -p /service
if [ ! -d /command ]; then
    cd /var/tmp
    curl -O  "$public_files_base/$pkg"
    cd /
    tar -xzf /var/tmp/$pkg

    if [ "$uname" = "linux" ]; then
        echo "
        start on runlevel [12345]
        stop on runlevel [^12345]
        respawn
        exec /command/svscanboot
        " > /etc/init/svscan.conf

        start svscan

    else
        echo "SV:123456:respawn:/command/svscanboot" >> /etc/inittab
        ps -ef | grep init | grep -v grep | awk '{print $2}' | xargs kill -HUP
    fi
fi

