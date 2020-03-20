
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;33m'
NC='\033[0m'

echo "${BLUE}********************Raspberry Cpuminer-multi for Ring Coin Auto-Install ****************************${NC}"
echo "${GREEN}**************************************** by hans200 ************************************************${NC}"
sleep 5
echo "${RED}First of all we will install the dependencies${NC}"
echo "${RED}Starting installing the dependencies, please do not close the window${NC}"
sleep 5

echo "${BLUE}dependencies install!${NC}"
sleep 5
sudo apt update -y
sudo apt-get upgrade -y
sudo apt-get install automake git screen autoconf pkg-config libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev make g++ -y
git clone https://github.com/litecoincash-project/cpuminer-multi.git 
cd cpuminer-multi


# Linux build, optimised for ARM devices

echo "${BLUE}System Cleaning${NC}"
sleep 5
if [ "$OS" = "Windows_NT" ]; then
    ./mingw64.sh
    exit 0
fi

make clean || echo clean

rm -f config.status
echo "${BLUE}Starting"
sleep 5
./autogen.sh
echo "${GREEN}done"
sleep 5
echo "${BLUE}Configure for Pi4"
sleep 5
if [[ "$OSTYPE" == "darwin"* ]]; then
    ./nomacro.pl
    ./configure \
        CFLAGS="-march=native -O2 -Ofast -flto -DUSE_ASM -pg" \
        --with-crypto=/usr/local/opt/openssl \
        --with-curl=/usr/local/opt/curl
    make -j4
    strip cpuminer
    exit 0
fi

extracflags="$extracflags -Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores"

if [ ! "0" = `cat /proc/cpuinfo | grep -c avx` ]; then
    # march native doesn't always works, ex. some Pentium Gxxx (no avx)
    extracflags="$extracflags -march=native"
fi

./configure --with-crypto --with-curl CFLAGS="-O2 $extracflags -DUSE_ASM -pg"


echo "${GREEN}done"
sleep 5
echo "${BLUE}Starting Compile for Pi4"
make -j4
echo "${GREEN}done"
strip -s cpuminer
echo "${GREEN}finish"
echo "${GREEN}run cpuminer with Terminal -> ./configure -a minotaur -o stratum+tcp://stratum-eu.rplant.xyz:7018 -u ->your wallet addy<-"
sleep 5
exit 0
