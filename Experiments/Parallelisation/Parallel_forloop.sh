#!/bin/bash
#PBS -N Parallelisation_ex0
#PBS -l ncpus=40
#PBS -j oe
#PBS -o Output/

PATH="/opt/matlab/bin:$PATH"


echo Moving to project directory
cd ~/Algorithms/SCAL/Experiments
echo Running Matlab script in directory $PWD:
matlab -nojvm -nodesktop -nosplash < Parallel_forloop.m
