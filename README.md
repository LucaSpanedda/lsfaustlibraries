# Spanedda-Faustlibraries
my personal faust libraries

## Installation

```
cat > InstallFaust.sh << EOF
#!/bin/bash    
    
# install Faust Grame
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y build-essential cmake git libmicrohttpd-dev
sudo apt-get install llvm-dev
git clone https://github.com/LucaSpanedda/faust.git
git clone https://github.com/LucaSpanedda/Spanedda-Faustlibraries.git
cd faust
git submodule update --init
sudo make
sudo make install
cd ..
cp Spanedda-Faustlibraries/AIP.lib faust/libraries
cat << EOF >> faust/libraries/all.lib
import("AIP.lib")
EOF
EOF
```
