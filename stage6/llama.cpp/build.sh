#!/bin/bash
export pkgver=6.4.1
export ROCM_HOME=/opt/rocm-$pkgver/
export ROCM_PATH=$ROCM_HOME
export PATH=$ROCM_HOME/bin:$ROCM_HOME/lib/llvm/bin:$PATH
function fetch(){
  git clone --recursive https://github.com/ggml-org/llama.cpp
}
export HIPCLANG_AGENT=/opt/rocm-$pkgver/lib/llvm/bin/clang++
export HIPCC_AGENT=/opt/rocm-$pkgver/bin/hipcc
function prepare() {
  mkdir build
  cd build
  if [ -n $GPU_TARGETS ] && [ $GPU_TARGETS != 'all' ]; then
    targetSet=( -DAMDGPU_TARGETS=${GPU_TARGETS} )
  else
    targetSet=( )
  fi
  EXT_CFLAGS="-fPIC -I/opt/rocm-${pkgver}/include  -L/opt/rocm-${pkgver}/lib -L/opt/rocm-${pkgver}/lib64"
  cmake ../llama.cpp \
   -DCMAKE_C_COMPILER=clang \
   -DCMAKE_CXX_COMPILER=clang++ \
   -DCMAKE_HIP_COMPILER=$PWD/../hipclang-agent.sh \
   -DCMAKE_BUILD_TYPE=Release \
   -DGGML_HIP=ON \
   -DCMAKE_HIP_FLAGS="${EXT_CFLAGS}" \
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
