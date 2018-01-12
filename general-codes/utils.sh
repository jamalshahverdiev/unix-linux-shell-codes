#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# This script was written to FreeBSD servers. 
# And script will open menu which you can choose to install utilities for your needs.

HEIGHT=15
WIDTH=50
CHOICE_HEIGHT=6
BACKTITLE="Choose utility"
TITLE="Utils"
MENU="   Chooshe program which you want to install:"

OPTIONS=(1 "cmdwatch"
         2 "nload"
         3 "iftop"
         4 "htop"
         5 "bind-tools"
         6 "py-speedtest-cli")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
                cd `whereis cmdwatch | awk '{ print $2 }'`; make -DBATCH install
            ;;
        2)
                cd `whereis nload | awk '{ print $2 }'`; make -DBATCH install
            ;;
        3)
                cd `whereis iftop | awk '{ print $2 }'`; make -DBATCH install
            ;;
        4)
                echo "linproc /compat/linux/proc linprocfs rw,late 0 0" >> /etc/fstab
                mkdir -p /usr/compat/linux/proc; ln -s /usr/compat /compat; mount linproc
                cd `whereis htop | awk '{ print $2 }'`; make -DBATCH install
            ;;
        5)
                cd `whereis bind-tools | awk '{ print $2 }'`; make -DBATCH install
            ;;
        6)
                cd `whereis py-speedtest-cli | awk '{ print $2 }'`; make -DBATCH install
            ;;
esac
