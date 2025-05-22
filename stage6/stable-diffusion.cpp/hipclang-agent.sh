#!/usr/bin/sh
# 解决clang直接编译.cu文件 使用CUDA模式 识别不支持gfx的问题
#  在此时强制指定为hip模式
args=("${@}")
has_x_hip=0
compile_cu=0
ext_args=()
for arg in ${args[@]};
do
 if [[ $arg =~ \.cu$ ]];
 then
   compile_cu=1
 fi
 if [[ $arg == '-x' ]];
 then
   has_x_hip=2
 fi
 if [[ $arg =~ ^hip$ ]] && [[ $has_x_hip == 2 ]];
 then
  has_x_hip=1
 fi
done
#if [[ $has_x_hip != 1 ]] && [[ $compile_cu == 1 ]];
#then
  $HIPCC_AGENT ${ext_args[@]} ${args[@]}
#else
#  $HIPCLANG_AGENT ${ext_args[@]} ${args[@]}
#fi
exit $?
