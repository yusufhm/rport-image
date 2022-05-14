#!/bin/sh

set -ex

conf_file=/etc/rport/rportd.conf
if [ ! -f "${conf_file}" ]; then
    mkdir -p `dirname $conf_file`
    cp /etc/rportd.conf.template ${conf_file}
    ep ${conf_file}
fi

exec "$@"
