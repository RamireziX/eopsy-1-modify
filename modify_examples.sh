#!/bin/bash

continue(){
read -p "Continue?[y/n] " yesOrNo
if test $yesOrNo = "n"
then
    read -p "Are you sure? The script will close.[y/n] " yOrN
    if test $yOrN = "y"
    then
        exit 1
    fi
fi
}

cat <<EOT
-----------------------------------------------------------------------------------------------------------------------
Welcome to modify_examples.sh!
A script which will guide you through the usage of the script modify.sh.
Made by Alexander Wrzosek.

It's better if the only files in the main directory are modify.sh and modify_examples.sh,
and there are no subdirectories.

You don't have to write commands here
the program will show which command it executes for modify.sh
and will ask you whether you want to continue or not.

EOT

continue

echo "First, let's make some files and folders that we can work on."

continue

mkdir -p dir1/dir2 ; mkdir -p dir1/dir3 ; mkdir -p dir1/dir3/dir4
touch file1.txt ; touch file2 ; touch dir1/file3.c ; touch dir1/file4.ABC
touch dir1/dir2/file5.py ; touch dir1/dir3/dir4/file6.aa ; touch dir1/dir3/dir4/file7.a

echo "This is how our worplace looks now:"
ls -R

continue

cat <<EOT

Now we can start working with modify.sh.
First, let's see the help page for the script using the following command:
modify.sh -h:
EOT

continue

chmod a+x modify.sh
./modify.sh -h

cat <<EOT

^Here we can see a bunch of useful information about modify.sh and some examples of usage.

EOT

continue

cat <<EOT

Now let's run a simple command: 
./modify.sh -u file1.txt file2 -> will uppercase the names of these 2 files in main dir.

EOT

continue

./modify.sh -u file1.txt file2
ls

cat <<EOT
^Here we can see the result. As you can see, the program omits the extention
when uppercasing (or lowercasing) a file name.

Now let's test the sed command with:
modify.sh 's/I/o' FILE1.txt FILE2 -> will replace 'I' with 'o' (or will it? :) )

EOT

continue

./modify.sh 's/I/o' FILE1.txt FILE2

cat <<EOT

^Something went wrong. The answer is that there is a mistake in sed command,
and it's an easy one to miss.
Mainly, the sed command lacks the last '/'. Now we will run this fixed command:
modify.sh 's/I/o/' FILE1.txt FILE2

EOT

continue

./modify.sh 's/I/o/' FILE1.txt FILE2
ls

cat <<EOT

Here it works corretly.

Now let's test the recursion. It can be used by passing -r parameter.
Here's a reminder on how our directory tree looks like:

EOT

continue

ls -R

cat <<EOT

We'll run these commands:
modify -r 's/i/I/' dir1
modify -r -u dIr1
modify -r -l DIR1 -> the name of the root directory is also changed
And you'll see the results for each of them below:

EOT

continue

cat <<EOT

After modify -r 's/i/I/' dir1 :

EOT

./modify.sh -r 's/i/I/' dir1
ls -R dIr1

cat <<EOT

After modify -r -u dIr1 :

EOT

./modify.sh -r -u dIr1
ls -R DIR1

cat <<EOT

After modify -r -l DIR1

EOT

./modify.sh -r -l DIR1
ls -R dir1

continue

cat <<EOT

We can see it works pretty good. 

Now, let's see some examples of improper usage. 
We'll run these commands:
modify -k -----------> not defined parameter
modify -r FoLE1.txt -> cannot work recursively on a file
modify -r -----------> too little parameters
modify -r -l --------> too little parameters (no folder name)
modify -u -----------> too little parameters (no file/folder name)

And we'll see how the program handles them.

EOT

continue

cat <<EOT

modify -k -----------> not defined parameter:

EOT

./modify.sh -k FoLE1.txt

cat <<EOT

modify -r FoLE1.txt -> cannot work recursively on a file:

EOT

./modify.sh -r FoLE1.txt

cat <<EOT

modify -r -----------> too little parameters:

EOT

./modify.sh -r 

cat <<EOT

modify -r -l --------> too little parameters (no folder name):

EOT

./modify.sh -r -l

cat <<EOT

modify -u -----------> too little parameters (no file/folder name):

EOT

./modify.sh -u

continue

cat <<EOT

And that's the end of the script modify_examples.

EOT
