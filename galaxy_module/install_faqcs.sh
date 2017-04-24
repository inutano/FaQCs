#!/bin/bash
set -eu

USER_DIR="/home/galaxy"

if [[ -z `sudo ls /` ]]; then
  echo "Permission denied: you have to be granted sudo privileges. Quit"
  exit 1
fi

echo "==> Installing R.."
#sudo rpm -ihv http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
sudo yum -y install R sudo yum perl-ExtUtils-MakeMaker 2>/dev/null

echo "==> Installing FaQCs and prerequisites.."

cd ${USER_DIR} && git clone https://github.com/inutano/FaQCs ${USER_DIR}/galaxy-dist/tools/FaQCs
sh ${USER_DIR}/galaxy-dist/tools/FaQCs/lib/INSTALL.sh

echo "==> Installing FaQCs on pitagora galaxy.."
cp ${USER_DIR}/galaxy-dist/tools/FaQCs/galaxy_module/FaQCs.xml ${USER_DIR}/galaxy-dist/tools/FaQCs
cat <(cat ${USER_DIR}/galaxy-dist/config/tool_conf.xml.sample | grep -v '</toolbox>') <(echo -e "  <section name=\"FastqQCs\" id=\"FaQCs\">\n    <tool file=\"FaQCs/FaQCs.xml\" />\n  </section>\n</toolbox>") > ${USER_DIR}/galaxy-dist/config/tool_conf.xml

echo "==> Restarting Pitagora Galaxy..."
sudo service galaxy restart

echo "==> Installing FaQCs Done."
exit 0