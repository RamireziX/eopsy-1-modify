#!/bin/sh
# simple version

# the name of the script without a path
name=`basename $0`

# function for printing error messages to diagnostic output
error_msg() 
{ 
        echo "$name: error: $1" 1>&2 
}



# if no arguments given
if test -z "$1"
then
cat<<EOT 1>&2

usage: 
	modify [-r] [-l|-u] <dir/file names...>
  	modify [-r] <sed pattern> <dir/file names...>
  	modify [-h]

EOT
fi


