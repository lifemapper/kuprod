#!/bin/bash

# This command frees memory 
# check the memory with "free -m" before and after this command

sync && echo 1 > /proc/sys/vm/drop_caches
