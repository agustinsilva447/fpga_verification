#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2021.2 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Tue Jul 18 17:04:17 -03 2023
# SW Build 3367213 on Tue Oct 19 02:47:39 MDT 2021
#
# IP Build 3369179 on Thu Oct 21 08:25:16 MDT 2021
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# simulate design
echo "xsim tb22_behav -key {Behavioral:sim_1:Functional:tb22} -tclbatch tb22.tcl -log simulate.log"
xsim tb22_behav -key {Behavioral:sim_1:Functional:tb22} -tclbatch tb22.tcl -log simulate.log
