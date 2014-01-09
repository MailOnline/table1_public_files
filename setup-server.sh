#!/usr/bin/env bash
environment=$1
cd /var/tmp
curl -O  https://bitbucket.org/tomburnell/table1_public_files/raw/b21d88ff949b9824328f84b9a4aade0d3a950dfc/dt.tar.gz
curl -O  https://bitbucket.org/tomburnell/table1_public_files/raw/b21d88ff949b9824328f84b9a4aade0d3a950dfc/statsd.tar.gz

cd /
tar -xzvf /var/tmp/dt.tar.gz
mkdir /service
echo "SV:123456:respawn:/command/svscanboot" >> /etc/inittab
ps -ef | grep init | grep -v grep | awk '{print $2}' | xargs kill -HUP

mkdir -p /opt/molsfw/statsd
cd /opt/molsfw/statsd
tar -xzvf /var/tmp/statsd.tar.gz
/opt/molsfw/statsd/mol-postinstall.sh blah POST-INSTALL

svcadm enable /mailonline/MOLstatsd
echo "PATH=/command:\$PATH" >> $HOME/.profile
echo "export NODE_ENV=integration" >> /etc/profile
echo "export PATH=/opt/local/bin:$PATH" >> /etc/profile
