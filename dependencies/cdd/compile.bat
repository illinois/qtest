@REM This is for windows platform
@REM see compile.sh for mac
@REM @REM Commands used to compile cddlib with and without gmp support

git clone https://github.com/cddlib/cddlib
cd cddlib
git reset --hard 9f016c8b08a043386b857e479d031b95fae1caa4
@REM Modify the files as per this - https://github.com/microsoft/vcpkg/pull/40863/files
@REM List of files changed should be Makefile.am, src/lcdd.c, src/scdd.c
@REM copy cddmex.c to lib-src
@REM copy cddgmpmex.c to lib-src

@REM Install MSYS2 with installation folder - C:\msys64\
@REM We will be using mingw for windows to do compilation of the binaries
@REM From MSYS2 installation folder, open mingw64.exe (C:\msys64\mingw64.exe)
@REM It will launch a terminal/command window

pacman -S mingw-x64-x86_64-gcc
pacmain -S base-devel
pacman -S mingw-x64-x86_64-gmp

@REM Under cdd folder
./bootstrap
./configure
make

@REM on matlab console
@REM Make sure you install matlab support for mingw-x64 c/c++/fortran compiler
@REM change compiler to mingw using below commands
mex -setup
mex -setup C++

@REM cd lib-src
@REM mex -v cddmex.c .libs/libcdd.a

@REM on matlab console
@REM cd lib-src
@REM Modify the below command according to the installation path you have
@REM mex -v -IC:\msys64\mingw64\include -LC:\ProgramData\MATLAB\SupportPackages\R2024a\3P.instrset\mingw_w64.instrset\lib\gcc\x86_64-w64-mingw32\8.1.0 -L.libs/ -DGMPRATIONAL cddgmpmex.c .libs/libcddgmp.a C:\msys64\mingw64\lib\libgmp.a C:\ProgramData\MATLAB\SupportPackages\R2024a\3P.instrset\mingw_w64.instrset\x86_64-w64-mingw32\lib\libmingw32.a