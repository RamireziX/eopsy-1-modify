#!/bin/bash

#functions renaming a file
renameFileUppercase(){
oldFileName=$1
newNameNoExt=$(tr '[:lower:]' '[:upper:]' <<< "${oldFileName%.*}")
newFileName="$newNameNoExt.${oldFileName#*.}"
mv $oldFileName $newFileName
ls
}
renameFileLowercase(){
oldFileName=$1
newFileName=`echo $oldFileName  | tr '[A-Z]' '[a-z]'`
mv $oldFileName $newFileName
ls
}
renameFileSed(){
echo "Sed command!"
ls
}
showHelp(){
cat <<EOT
-----------------------------------------------------------------------------------------------------------------------
The script modify.sh is designed to rename filenames in a following way:

modify [-r] [-l|-u] <dir/file names...>
modify [-r] <sed pattern> <dir/file names...>
modify [-h]

parameters:
-r ------------------> change names of all files in all subfolders of a given folder (recursion)
-l ------------------> lowercasing
-u ------------------> uppercasing
<sed pattern> -------> sed pattern for sed command, which will operate on the file names instead
<dir/file names...> -> folder name OR list of file names to change
-h ------------------> help

examples of CORRECT usage:
modify -r -u dirName --------------------> will uppercase dirName, as well as all the folders and files within dirName
modify -l SOMEDIRECTORY -----------------> will lowercase only the folder name SOMEDIRECTORY
modify -u file1.txt file2.txt file3.txt -> will uppercase names of these 3 files
modify 's/text/tekst' textFile.c --------> will call sed command to replace 'text' by 'tekst' in a given file name

examples of INCORRECT usage:
modify -r -u file.txt -> recursion can be used only with a directory name

made by Alexander Wrzosek
-----------------------------------------------------------------------------------------------------------------------
EOT
}

############# main body ######################

firstParameter=$1
secondParameter=$2
thirdParameter=${@:3} # jest lista plikow, tylko czasami second parameter moze miec liste pliow
#rowniez funckje nie obsluguja listy plikow poki co

echo $thirdParameter

#recursion
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
		#check if user wrote filename
		if test -z "$thirdParameter"
		then
			echo "no folder name!"
		else 
			renameFileLowercase $thirdParameter
		fi
	elif test $secondParameter = "-u"
	then
		#check if user wrote filename
		if test -z "$thirdParameter"
		then
			echo "no folder name!"
		else 
			renameFileUppercase $thirdParameter
		fi
    #sed pattern
    elif [[ "$secondParameter" == "s"* ]]
	then
        #jak potrzeba potem podac '' do sed command
        #quotation="'"
        #withQuotation=${quotation}${secondParameter}${quotation}
        #check if user wrote filename
        if test -z "$thirdParameter"
        then
            echo "no folder name!"
        else   
			renameFileSed $secondParameter $thirdParameter
        fi
    else
        echo "not supported parameter"
    fi
	
#show help
elif test $firstParameter = "-h"
then
    showHelp
    
#without recursion
else	
	if test $firstParameter = "-l"
	then
		#check if user wrote filename
		if test -z "$secondParameter"
		then
			echo "no file name!"
		else 
			renameFileLowercase $secondParameter
		fi
	elif test $firstParameter = "-u"
	then
		#check if user wrote filename
		if test -z "$secondParameter"
		then
			echo "no file name!"
		else 
			renameFileUppercase $secondParameter
		fi
    #sed pattern
    elif [[ "$firstParameter" == "s"* ]]
	then
        #check if user wrote filename
        if test -z "$secondParameter"
        then
            echo "no folder name!"
        else   
			renameFileSed $firstParameter $secondParameter
        fi
	else
		echo "not supported parameter"
	fi
fi



