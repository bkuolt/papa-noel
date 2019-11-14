#!/bin/bash

install_love () {
    if [ $(which love) = "" ]; then
        echo "installing love2d"
        sudo add-apt-repository ppa:bartbes/love-stable
        sudo apt-get update
        sudo apt-get install love2d
    fi
}

download_source_code() {
    echo "Downloading source from github..."
    rm -f test
    git clone https://github.com/bkuolt/PapaNoel.git test
    git clone https://github.com/rxi/json.lua src/json.lua
}

build() {
    # TODO create symlink
}

install_love
download_source_code
#build

