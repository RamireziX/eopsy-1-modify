#!/bin/bash

#functions
renameFiles(){
lowOrUp=$1
oldFileNames=${@:2}
for file in $oldFileNames
do
    #if contains .
    if [[ "$file" == *"."* ]]
    then
        if test $lowOrUp = "-l"
        then
            newNameNoExt=$(tr '[:upper:]' '[:lower:]' <<< "${file%.*}")
        elif test $lowOrUp = "-u"
        then
            newNameNoExt=$(tr '[:lower:]' '[:upper:]' <<< "${file%.*}")
        else
            echo "not supported parameter"
            exit 1
        fi
        newFileName="$newNameNoExt.${file#*.}"
        if [[ "$file" != $newFileName ]]
        then
            mv $file $newFileName
        fi
    else
        #folder or file without extention
        if test $lowOrUp = "-l"
        then
            newFileName=$(tr '[:upper:]' '[:lower:]' <<< "${file}")
        elif test $lowOrUp = "-u"
        then
            newFileName=$(tr '[:lower:]' '[:upper:]' <<< "${file}")
        else
            echo "not supported parameter"
            exit 1
        fi
        if [[ "$file" != $newFileName ]]
        then
            mv $file $newFileName
        fi
    fi
done
}

renameFilesRecursive(){
lowOrUp=$1
mainDir=$2
#check if folder - recursive only with folders
if test -d "$mainDir"
then
    #depth first is needed
    inMainDir="$(find "$mainDir" -depth)"
    for file in $inMainDir
    do
        #if its not the root folder 
        if [[ "$file" == *"/"* ]]
        then
            fileNameNoPath=${file##*/}
            oldPath=${file%/*}
            slash="/"
            #if contains '.'
            if [[ "$file" == *"."* ]]
            then
                if test $lowOrUp = "-u"
                then
                    newNameNoExt=$(tr '[:lower:]' '[:upper:]' <<< "${fileNameNoPath%.*}")
                elif test $lowOrUp = "-l"
                then
                    newNameNoExt=$(tr '[:upper:]' '[:lower:]' <<< "${fileNameNoPath%.*}")
                else
                    echo "not supported parameter"
                    exit 1
                fi
                newFileName="$newNameNoExt.${fileNameNoPath#*.}"
                newFileNameWithPath=$oldPath$slash$newFileName
                if [[ "$file" != $newFileNameWithPath ]]
                then
                    mv $file $newFileNameWithPath
                fi
            else
                #folder or file without extention
                if test $lowOrUp = "-u"
                then
                    newFileName=$(tr '[:lower:]' '[:upper:]' <<< "${file##*/}")
                elif test $lowOrUp = "-l"
                then
                    newFileName=$(tr '[:upper:]' '[:lower:]' <<< "${file##*/}")
                else
                    echo "not supported parameter"
                    exit 1
                fi
                newFileNameWithPath=$oldPath$slash$newFileName
                if [[ "$file" != $newFileNameWithPath ]]
                then
                    mv $file $newFileNameWithPath
                fi
            fi
        else 
            #change the name of root folder too
            if test $lowOrUp = "-u"
            then
            newFileName=$(tr '[:lower:]' '[:upper:]' <<< "$file")
            elif test $lowOrUp = "-l"
            then
                 newFileName=$(tr '[:upper:]' '[:lower:]' <<< "$file")
            else
                echo "not supported parameter"
                exit 1
            fi
            if [[ "$file" != $newFileName ]]
            then
                mv $file $newFileName
            fi
        fi
    done
else
    echo "only directories allowed with parameter -r!"
fi
}

renameFileSed(){
sedPattern=$1
oldFileNames=${@:2}
for file in $oldFileNames
do
    newFileName=$(echo $file | sed "$sedPattern")
    if [[ "$file" != $newFileName ]]
    then
        mv $file $newFileName
    fi
done
}

renameFilesSedRecursive(){
sedPattern=$1
mainDir=$2
#check if folder - recursive only with folders
if test -d "$mainDir"
then
    #depth first is needed
    inMainDir="$(find "$mainDir" -depth)"
    for file in $inMainDir
    do
        #if its not the root folder 
        if [[ "$file" == *"/"* ]]
        then
            fileNameNoPath=${file##*/}
            oldPath=${file%/*}
            slash="/"
            newFileName=$(echo $fileNameNoPath | sed "$sedPattern")
            newFileNameWithPath=$oldPath$slash$newFileName
            if [[ "$file" != $newFileNameWithPath ]]
            then
                mv $file $newFileNameWithPath
            fi
        else 
            #change the name of root folder too
            newFileName=$(echo $file | sed "$sedPattern")
            if [[ "$file" != $newFileName ]]
            then
                mv $file $newFileName
            fi
        fi
    done
else
    echo "only directories allowed with parameter -r!"
fi
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
modify -r -u dirName ---------------------> will uppercase dirName, as well as all the folders and files within dirName
modify -l SOMEDIRECTORY ------------------> will lowercase only the folder name SOMEDIRECTORY
modify -u file1.txt file2.txt file3.txt --> will uppercase names of these 3 files
modify 's/text/tekst/' textFile.c --------> will call sed command to replace 'text' by 'tekst' in a given file name

examples of IMPROPER usage (will still execute)
modify -r 's/a/b/' dir1 dir2 -> recursive function will work only for dir1

examples of INCORRECT usage:
modify -r -u file.txt -----> recursion can be used only with a directory name
modify 's/a/b' file.txt ---> wrong sed command (lacks last '/')
modify '3 s/a/b' file.txt -> the program only accepts sed command starting with s
(other sed commands deal with lines of text in a file, not useful in just a filename)

made by Alexander Wrzosek
-----------------------------------------------------------------------------------------------------------------------
EOT
}

############# main body ######################

firstParameter=$1

############recursion
if test -z "$firstParameter"
then
	echo "first parameter empty"
elif test $firstParameter = "-r"
then
	secondParameter=$2
	thirdParameter=$3 
	if test -z "$secondParameter"
	then
		echo "second parameter empty"
	elif test -z "$thirdParameter"
		then
			echo "no folder name!"
    #sed pattern
    elif [[ "$secondParameter" == "s/"* ]]
	then
        renameFilesSedRecursive $secondParameter $thirdParameter
    else 
        renameFilesRecursive $secondParameter $thirdParameter
    fi

###########show help
elif test $firstParameter = "-h"
then
    showHelp
    
###########without recursion
else
    secondParameter=${@:2} #second parameter may contain a list of files
	#check if user wrote filename
    if test -z "$secondParameter"
    then
        echo "no file name!"
    elif [[ "$firstParameter" == "s/"* ]]
    then
        renameFileSed $firstParameter $secondParameter
	else
		renameFiles $firstParameter $secondParameter
	fi
fi
