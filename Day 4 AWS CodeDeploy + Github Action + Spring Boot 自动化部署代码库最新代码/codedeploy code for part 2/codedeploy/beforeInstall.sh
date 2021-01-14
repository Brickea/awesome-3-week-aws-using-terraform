#!/bin/bash

echo "******************Remove all previous files******************"
if  [ ! -d  "/home/ubuntu/springbootCode/"  ]; then
echo  "No webapp"
else
sudo rm  -rf  /home/ubuntu/springbootCode
fi
