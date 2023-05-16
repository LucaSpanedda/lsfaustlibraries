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
git clone https://github.com/LucaSpanedda/faust.git
cd faust
git submodule update --init
sudo make
sudo make install
EOF
```
