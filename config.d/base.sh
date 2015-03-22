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

## install packages

su - ${user} -c "bash -ex" <<'EOS'
  addpkgs="
   hold-releasever.hold-baseurl
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

## restart services

svcs="
 jenkins
"

for svc in ${svcs}; do
  chkconfig --list ${svc}
  chkconfig ${svc} on
  chkconfig --list ${svc}

  service ${svc} restart
done

su - ${user} -c "bash -ex" <<'EOS'
  curl -fSkL https://raw.githubusercontent.com/hansode/env-bootstrap/master/build-personal-env.sh | bash
EOS
