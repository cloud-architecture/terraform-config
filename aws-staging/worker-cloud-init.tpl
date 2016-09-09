#!/usr/bin/env bash
# vim:filetype=sh

set -o errexit

main() {
  __write_travis_worker_configs
  __setup_papertrail_rsyslog
  __fix_perms
  __restart_worker
  __write_chef_node_json
  __set_hostname || true
}

__restart_worker() {
  stop travis-worker || true
  start travis-worker || true
}

__write_travis_worker_configs() {
  cat > /etc/default/travis-worker <<EOF
${worker_config}
EOF
}

__setup_papertrail_rsyslog() {
  source /etc/default/travis-worker
  local pt_port="$TRAVIS_WORKER_PAPERTRAIL_REMOTE_PORT"

  if [[ ! "$pt_port" ]] ; then
    return
  fi

  local match='logs.papertrailapp.com:'
  local repl="\*\.\* @logs.papertrailapp.com:$pt_port"

  sed -i "/$match/s/.*/$repl/" '/etc/rsyslog.d/65-papertrail.conf'

  restart rsyslog || start rsyslog
}

__fix_perms() {
  chown -R travis:travis /etc/default/travis-worker* /var/tmp/*
  chmod 0640 /etc/default/travis-worker* /var/tmp/gce*
}

__write_chef_node_json() {
  mkdir -p /etc/chef

  cat > /etc/chef/node.json <<EOF
${chef_json}
EOF
}

__set_hostname() {
  local instance_id
  local instance_ipv4

  instance_id="$(curl -s 'http://169.254.169.254/latest/meta-data/instance-id')"
  instance_ipv4="$(curl -s 'http://169.254.169.254/latest/meta-data/local-ipv4')"

  local instance_hostname="worker-docker-$${instance_id#i-}.${env}.travis-ci.${site}"

  echo "$${instance_hostname}" | tee /etc/hostname
  hostname -F /etc/hostname
  echo "$${instance_ipv4} $${instance_hostname} $${instance%.*}" \
    | tee -a /etc/hosts
}

main "$@"
