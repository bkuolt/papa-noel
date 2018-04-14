#!/bin/bash
if [ $(which love) = "" ]; then
    echo "installing love2d"
    sudo add-apt-repository ppa:bartbes/love-stable
    sudo apt-get update
    sudo apt-get install love2d
fi