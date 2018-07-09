#!/bin/bash

TMPFILE=`mktemp XXXXXXXXXXXX.html` 

wget -O $TMPFILE $1 

flex ficsListography.l
cc lex.yy.c -lfl -w
./a.out $TMPFILE 

rm $TMPFILE
rm lex.yy.c
rm a.out

