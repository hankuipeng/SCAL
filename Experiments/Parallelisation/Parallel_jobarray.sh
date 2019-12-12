#!/bin/bash
#PBS -N Parallelisation_ex
#PBS -l ncpus=40
#PBS -j oe
#PBS -o Output/
#PBS -t 1-4%4

PATH="/opt/matlab/bin:$PATH"


echo Moving to project directory
cd ~/Algorithms/SCAL/Experiments
echo Running Matlab script in directory $PWD:
matlab -nojvm -nodesktop -nosplash < Parallel_jobarray.m
