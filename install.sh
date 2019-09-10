#!/bin/bash
PATH=$(which love)

# installs the love library if not already installed
if [ $PATH = "" ]
then
    sudo add-apt-repository ppa:bartbes/love-stable
	sudo apt-get update
	sudo apt-get install love2d
fi

# installs json.lua
git clone https://github.com/rxi/json.lua src/json.lua

# unzips the art directory
sudo apt-get install unzip
unzip src/Art.zip -d src
rm src/Art.zip