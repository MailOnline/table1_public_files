#!/usr/bin/env bash
environment=$1

public_files_base="https://bitbucket.org/tomburnell/table1_public_files/raw/master"

if [ -z "$environment" ]; then
    echo "USAGE: $0 <environment>"
    exit 2
fi

if ! cat $HOME/.profile | grep  '/command' > /dev/null; then echo "PATH=/command:\$PATH" >> $HOME/.profile;  fi
if ! cat /etc/profile | grep 'NODE_ENV'; then echo "export NODE_ENV=$environment" >> /etc/profile; fi
if ! cat /etc/profile | grep '/opt/local/bin'; then echo "export PATH=/opt/local/bin:\$PATH" >> /etc/profile; fi

mkdir -p /service
if [ ! -d /command ]; then
    cd /var/tmp
    curl -O  "$public_files_base/dt.tar.gz"
    cd /
    tar -xzf /var/tmp/dt.tar.gz 
    echo "SV:123456:respawn:/command/svscanboot" >> /etc/inittab
    ps -ef | grep init | grep -v grep | awk '{print $2}' | xargs kill -HUP
fi

svcadm disable /mailonline/MOLstatsd
cd /var/tmp
if [ -f statsd.tar.gz ]; then 
    rm statsd.tar.gz
fi
curl -O "$public_files_base/statsd.tar.gz"
rm -rf /opt/molswf/statsd
mkdir -p /opt/molsfw/statsd
cd /opt/molsfw/statsd
tar -xzf /var/tmp/statsd.tar.gz
/opt/molsfw/statsd/mol-postinstall.sh blah POST-INSTALL
svcadm enable /mailonline/MOLstatsd



