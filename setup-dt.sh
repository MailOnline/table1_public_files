#!/usr/bin/env bash
set -e 
[ $DEBUG ] && set -x

public_files_base="https://bitbucket.org/MailOnline/table1_public_files/raw/master"

if ! cat $HOME/.profile | grep  '/command' > /dev/null; then echo -e "\nPATH=/command:\$PATH" >> $HOME/.profile;  fi
if ! cat /etc/profile | grep '/opt/local/bin'; then echo -e "\nexport PATH=/opt/local/bin:\$PATH" >> /etc/profile; fi
if ! cat /etc/profile | grep '/command'; then echo -e "\nexport PATH=/command:\$PATH" >> /etc/profile; fi

uname=$(uname | perl -ne 'print lc')
pkg="dt-$uname.tar.gz"

mkdir -p /service
mkdir -p /opt/service

chmod g+wrxs /service /opt/service

if [ ! -d /command ]; then
    cd /var/tmp
    wget "$public_files_base/$pkg"
    mkdir dt-$$
    pushd dt-$$
    tar -oxzf /var/tmp/$pkg .
    mv package command /
    popd
    rm -rf /var/tmp/dt-$$

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

