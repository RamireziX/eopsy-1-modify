#!/bin/sh

scriptName=`basename $0`
secondParameter=$1
#check if we have to do lowercasing or uppercasing

if test -z "$secondParameter"
then
	echo "nothing"

elif test $secondParameter = "-l"
then
	echo "lowercasing"
elif test $secondParameter = "-u"
then
	echo "uppercasing"
else
	echo "not supported parameter"

fi

