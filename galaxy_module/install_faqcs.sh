#!/bin/bash
set -eu

USER_DIR="/home/galaxy"

if [[ -z `sudo ls / 2>/dev/null` ]]; then
  echo "Permission denied: you have to be granted sudo privileges. Quit"
  exit 1
fi

echo "==> Installing R.."

if [[ -e `which yum 2>/dev/null` ]]; then
  #sudo rpm -ihv http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
  sudo yum udpate -y && sudo yum install -y R perl-ExtUtils-MakeMaker git
elif [[ -e `which apt-get` ]]; then
  sudo apt-get update -y && sudo apt-get install apt-transport-https
  echo "deb https://cran.ism.ac.jp/bin/linux/ubuntu $(cat /etc/lsb-release | grep DISTRIB_CODENAME | sed -e 's:DISTRIB_CODENAME=::')/" >> /etc/apt/sources.list
  gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
  gpg -a --export E084DAB9 | sudo apt-key add -
  sudo apt-get update -y && sudo apt-get install -y r-base libextutils-makemaker-cpanfile-perl git
else
  echo "The package manager command (yum/apt-get) not found."
  exit 1
fi

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
