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
  addpkgs="
   jenkins.master
   hubot.common
  "

  if [[ -z "$(echo ${addpkgs})" ]]; then
    exit 0
  fi

  deploy_to=/var/tmp/buildbook-rhel6

  if ! [[ -d "${deploy_to}" ]]; then
    git clone https://github.com/wakameci/buildbook-rhel6.git ${deploy_to}
  fi

  cd ${deploy_to}
  git checkout master
  git pull

  sudo ./run-book.sh ${addpkgs}
EOS

chkconfig --list jenkins
chkconfig jenkins on
chkconfig --list jenkins

service   jenkins start

su - ${user} -c "bash -ex" <<'EOS'
  curl -fSkL https://raw.githubusercontent.com/hansode/env-bootstrap/master/build-personal-env.sh | bash
EOS
