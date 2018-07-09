#!/bin/bash

TMPFILE=`mktemp XXXXXXXXXXXX.html` 

wget -O $TMPFILE $1

flex TESTE.l
cc lex.yy.c -lfl
./a.out $TMPFILE


rm $TMPFILE
rm list.txt
rm lex.yy.c
rm a.out
rm *.mp4*

echo $TMPFILE	
