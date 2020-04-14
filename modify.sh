#!/bin/bash

#functions renaming a file
renameFileUppercase(){
oldFileName=$1
mv $oldFileName ${oldFileName^^}
ls
}
renameFileLowercase(){
oldFileName=$1
newFileName=`echo $oldFileName  | tr '[A-Z]' '[a-z]'`
mv $oldFileName $newFileName
ls
}

#main body

scriptName=`basename $0`
firstParameter=$1
secondParameter=$2
thirdParameter=$3

#recursion or not
if test -z "$firstParameter"
then
	echo "first parameter empty"

elif test $firstParameter = "-r"
then
	echo "with recursion"
	#check if we have to do lowercasing or uppercasing with recursion
	if test -z "$secondParameter"
	then
		echo "second parameter empty"
	elif test $secondParameter = "-l"
	then
		echo "lowercasing"
		#check if user wrote filename
		if test -z "$thirdParameter"
		then
			echo "no file name!"
		else 
			renameFileLowercase $thirdParameter
		fi
	elif test $secondParameter = "-u"
	then
		echo "uppercasing"
		#check if user wrote filename
		if test -z "$thirdParameter"
		then
			echo "no file name!"
		else 
			renameFileUppercase $thirdParameter
		fi
	else
		echo "not supported parameter"
	fi
	
#without recursion
else	
	if test $firstParameter = "-l"
	then
		echo "lowercasing"
		#check if user wrote filename
		if test -z "$secondParameter"
		then
			echo "no file name!"
		else 
			renameFileLowercase $secondParameter
		fi
	elif test $firstParameter = "-u"
	then
		echo "uppercasing"
		#check if user wrote filename
		if test -z "$secondParameter"
		then
			echo "no file name!"
		else 
			renameFileUppercase $secondParameter
		fi
	else
		echo "not supported parameter"
	fi
fi



