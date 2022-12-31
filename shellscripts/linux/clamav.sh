#!/bin/bash
## Install and configure ClamAV

set \
  -o nounset \
  -o pipefail \
  -o errexit

dnf install -y -q clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd

setsebool -P antivirus_can_scan_system 1

sed -i -e "s/^Example/#Example/" /etc/clamd.d/scan.conf
sed -i -e "s/^Example/#Example/" /etc/freshclam.conf

sed -i 's/^#LocalSocket \/run\/clamd.scan\/clamd.soc/LocalSocket \/run\/clamd.scan\/clamd.soc/' /etc/clamd.d/scan.conf

clamscan --version

clamscan