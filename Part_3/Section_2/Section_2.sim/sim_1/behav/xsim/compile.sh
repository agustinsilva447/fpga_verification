#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2021.2 (64-bit)
#
# Filename    : compile.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for compiling the simulation design source files
#
# Generated by Vivado on Sat Sep 16 15:25:57 CEST 2023
# SW Build 3367213 on Tue Oct 19 02:47:39 MDT 2021
#
# IP Build 3369179 on Thu Oct 21 08:25:16 MDT 2021
#
# usage: compile.sh
#
# ****************************************************************************
set -Eeuo pipefail
# compile Verilog/System Verilog design sources
echo "xvlog --incr --relax -L uvm -L uvm -prj tb_5_vlog.prj"
xvlog --incr --relax -L uvm -L uvm -prj tb_5_vlog.prj 2>&1 | tee compile.log

echo "Waiting for jobs to finish..."
echo "No pending jobs, compilation finished."