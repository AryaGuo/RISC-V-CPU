#!bin/sh
set -e
#prefix='../data_gen'
#cd ..
#cd data_gen
#sh gen.sh $1
#cd ..
#cd sim
time iverilog -o main testbench.v
time vvp main
#set gtkw_file='main.gtkw'
#if [ -e main.gtkw ]
#then
#    open main.gtkw
#else
#    open main.vcd
#fi
