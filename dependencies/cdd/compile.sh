# This is for mac platform
# see compile.bat for windows
# Commands used to compile cddlib with and without gmp support

git clone https://github.com/cddlib/cddlib
cd cddlib
git reset --hard 9f016c8b08a043386b857e479d031b95fae1caa4
# copy cddmex.c to lib-src
# copy cddgmpmex.c to lib-src
chmod +x bootstrap
./bootstrap
chmod +x configure
./configure
make

# Download GMP
wget https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz
tar xf gmp-6.3.0.tar.xz
cd gmp-6.3.0
./configure
make
make check
sudo make install
cd ..
# rm gmp-6.3.0.tar.xz
# rm -rf gmp-6.3.0.tar.xz

# on matlab console
# cd lib-src
# mex -v cddmex.c .libs/libcdd.a

# on matlab console
# cd lib-src
# mex -v -I/usr/local/include -L/usr/local/lib -L.libs/ -DGMPRATIONAL cddgmpmex.c .libs/libcddgmp.a /usr/local/lib/libgmp.a
