#!/bin/bash

# if we were executed with some other shell, switch to the right one
if [ -z "${BASH_VERSION}" ]
then
    exec bash "$0" "$@"
fi

################################################################################
# START we may need to change to the local directory (of this file)
################################################################################
# remember the current working directory
CWD=`pwd`

# cd to the local directory, so we can include whatever we want easily
cd `dirname ${BASH_SOURCE[0]}`

# go back to where we started
cd $CWD
################################################################################
# END we may need to change to the local directory (of this file)
################################################################################

DBNAME="logs.db"
LOCATION=`pwd`
OVERWRITE=
DUMP=

function usage {
    cat <<EOF
    Usage: $0 [options] ### XXX finish this
    =======================================================================
        -h,--help                   print this help message (and exit)

        -n,--name NAME              set the log file to NAME

        -l,--location DIR           save the log file in the directory DIR

        -o,--overwrite              if the log file already exists, delete
                                    it and recreate the database

        -d,--dump                   dump the contents of the log file (to
                                    stdout)
EOF
    if [ "$#" -gt "0" ]
    then
        exit $1
    fi

    exit 0
}

function handle_args {
    # handle the command-line arguments
    while [[ $# > 0 ]]
    do
        key="$1"
        shift

        case $key in
            -h|--help)
                usage
                ;;
            -n|--name)
                DBNAME="$1"
                shift
                ;;
            -l|--location)
                LOCATION="$1"
                shift
                ;;
            -o|--overwrite)
                OVERWRITE=1
                shift
                ;;
            -d|--dump)
                DUMP=1
                ;;
            *)
                # unknown option
                echo "unknown option: $key"
                usage 1

                ;;
        esac
    done
}

handle_args $*
