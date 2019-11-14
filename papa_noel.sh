#!/bin/bash
if [ $(pwd) != "/home/bastian/PapaNoel" ]
then
    echo must be in PapaNoel directory
    exit 1
fi 

# game must be run directly from root source code directory
cd game
love .
cd ..