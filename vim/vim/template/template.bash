#!/bin/bash

# if we were executed with some other shell, switch to the right one
if [ -z "${BASH_VERSION}" ]
then
    exec bash "$0" "$@"
fi

function usage() {
	echo "Usage: $0 <TODO: fill-in arguments/usage>";
	exit 1
}

function handle_args() {
	while getopts ":a:h" opt; do
		case $opt in
			h)
				usage
				;;
			a)
				echo "-a was triggered, Parameter: $OPTARG" >&2
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				exit 1
				;;
			:)
				echo "Option -$OPTARG requires an argument." >&2
				exit 1
				;;
		esac
	done
}

if (( "$#" >= "0" )); then
	args="$@"
	handle_args $args
fi

# remember the current working directory
CWD=`pwd`

# cd to the local directory, so we can include whatever we want easily
cd `dirname $BASH_SOURCE[0]`

# enter stuff here

# go back to where we started
cd $CWD
