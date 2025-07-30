#!/bin/bash
export pkgver=6.4.2
export ROCM_HOME=/opt/rocm-$pkgver/
export ROCM_PATH=$ROCM_HOME
export PATH=$ROCM_HOME/bin:$ROCM_HOME/lib/llvm/bin:$PATH
function fetch(){
  git clone --recursive https://github.com/leejet/stable-diffusion.cpp
}
export HIPCLANG_AGENT=/opt/rocm-$pkgver/lib/llvm/bin/clang++
export HIPCC_AGENT=/opt/rocm-$pkgver/bin/hipcc
function prepare() {
  mkdir build
  cd build
  if [ -n $AMDGPU_TARGETS ] && [ $AMDGPU_TARGETS != 'all' ]; then
    targetSet=( -DAMDGPU_TARGETS=${AMDGPU_TARGETS} )
  else
    targetSet=( )
  fi
  EXT_CFLAGS="-fPIC -I/opt/rocm-${pkgver}/include  -L/opt/rocm-${pkgver}/lib -L/opt/rocm-${pkgver}/lib64"
  cmake ../stable-diffusion.cpp \
   -DCMAKE_C_COMPILER=/opt/rocm-$pkgver/lib/llvm/bin/clang \
   -DCMAKE_CXX_COMPILER=/opt/rocm-$pkgver/lib/llvm/bin/amdclang++ \
   -DCMAKE_HIP_COMPILER=$PWD/../hipclang-agent.sh \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_CXX_FLAGS="-I/opt/rocm-${pkgver}/include -parallel-jobs=$(nproc) ${EXT_CFLAGS}" \
   -DCMAKE_C_FLAGS="${EXT_CFLAGS}" \
   -DCMAKE_HIP_FLAGS="${EXT_CFLAGS}" \
   -DCMAKE_SHARED_LINKER_FLAGS="-L/opt/rocm-${pkgver}/lib/llvm/lib" \
   -DGGML_HIP=ON \
   -DSD_HIPBLAS=ON \
   -DCMAKE_INSTALL_RPATH="/opt/rocm-${pkgver}/lib;/opt/rocm-${pkgver}/lib/llvm/lib;/opt/rocm-${pkgver}/lib64;.;../lib64" \
   -DCMAKE_BUILD_RPATH="/opt/rocm-${pkgver}/lib;/opt/rocm-${pkgver}/lib/llvm/lib;/opt/rocm-${pkgver}/lib64" \
   ${targetSet[@]} \
   -G "Ninja"
  cd ..
}
function build() {
  cd build
    ninja
  cd ..
}
function package(){
  cd build
    cmake --install . --prefix=$PWD/../pkg/
  cd ..
}

function main(){
  fetch
  prepare
  build
#  package
}
main

