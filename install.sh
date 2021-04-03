#!/bin/bash
VERSION=11.3ppa1
sudo add-apt-repository ppa:bartbes/love-stable
sudo apt-get update
sudo apt-get install love=$VERSION
