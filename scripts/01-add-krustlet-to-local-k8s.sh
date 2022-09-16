#!/bin/bash

wget https://raw.githubusercontent.com/krustlet/krustlet/main/scripts/bootstrap.sh -O bootstrap.sh

chmod +x bootstrap.sh
./bootstrap.sh

krustlet-wasi --bootstrap-file=~/.krustlet/config/bootstrap.conf
