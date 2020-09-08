#!/bin/bash


# remove the freeDiameter
read -p "Do you want to remove the installed freeDiameter(y/n)" prompt
if [[ $prompt =~ [yY](es)* ]]; then
    sudo rm /usr/local/bin/freeDiameterd* -rf
    sudo rm /usr/local/include/freeDiameter -rf
    sudo rm /usr/local/lib/freeDiameter -rf
    sudo rm /usr/local/lib/libfdcore* -rf
    sudo rm /usr/local/lib/libfdproto* -rf
fi


# remove asn1c
read -p "Do you want to remove the installed asn1c(y/n)" prompt
if [[ $prompt =~ [yY](es)* ]]; then
sudo rm /usr/local/bin/asn1c -rf
sudo rm /usr/local/bin/enber -rf
sudo rm /usr/local/bin/unber -rf
fi

# remove liblfds
read -p "Do you want to remove the installed liblfds710(y/n)" prompt
if [[ $prompt =~ [yY](es)* ]]; then
sudo rm /usr/local/lib/liblfds710* -rf
sudo rm /usr/local/include/liblfds710* -rf
fi



