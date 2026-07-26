#!/bin/bash
sudo add-apt-repository --remove -y ppa:bartbes/love-stable || true
sudo apt-get update
sudo apt-get install -y love
