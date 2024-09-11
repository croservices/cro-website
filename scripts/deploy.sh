#!/bin/bash


old_tag=
tag=

ln -s \
  "/etc/containers/systemd/cro-services-website@.container" \
  "/etc/containers/systemd/cro-services-website@${tag}.container"

systemctl daemon-reload

systemctl list-unit-files --no-pager | awk '/cro-/'

systemctl start "cro-services-website@${tag}.service"
systemctl stop "cro-services-website@${old_tag}"

rm -f "/etc/containers/systemd/cro-services-website\@${old_tag}.container"

systemctl daemon-reload
