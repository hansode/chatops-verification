#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

# Do some changes ...

user=${user:-vagrant}

su - ${user} -c "bash -ex" <<'EOS'
  deploy_to=/var/tmp/buildbook-rhel6

  if ! [[ -d ${deploy_to} ]]; then
    git clone https://github.com/wakameci/buildbook-rhel6.git ${deploy_to}
  fi
  cd ${deploy_to}
  sudo ./run-book.sh jenkins.master
  sudo ./run-book.sh hubot.common
EOS

chkconfig --list jenkins
chkconfig jenkins on
chkconfig --list jenkins

service   jenkins start

su - ${user} -c "bash -ex" <<'EOS'
  curl -fSkL https://raw.githubusercontent.com/hansode/env-bootstrap/master/build-personal-env.sh | bash
EOS
