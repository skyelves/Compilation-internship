#!/bin/bash
echo "-------------------phase 1:flex"
flex cal.lex
echo "-------------------phase 2:bison"
bison cal.y
echo "-------------------phase 3:gcc"
gcc cal.tab.c -ly -ll -o calculator

