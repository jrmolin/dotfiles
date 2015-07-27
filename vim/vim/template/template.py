#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import sys

# verbosity levels
QUIET = -1
ERRORS = 0
WARNINGS = 1
INFO = 2
DEBUG = 3

class Options(object):
    verbosity = ERRORS
    filename = "test.txt"

def handle_arguments(argv):
    parser = argparse.ArgumentParser()

    # add optional arguments
    # don't add -h/--help, as it conflicts with the default parser

    # a mutually exclusive group disallows both options being processed at the
    # same time
    volumeGroup = parser.add_mutually_exclusive_group()
    volumeGroup.add_argument("-v", "--verbose", action="count",
            help="increase verbosity level")
    volumeGroup.add_argument("-q", "--quiet", action="count",
            help="suppress output")

    # add positional arguments
    parser.add_argument("filename", help="name of file to operate on")

    # parse the arguments
    # must take out the first element of the array (this file), or it gets
    # erroneously parsed as a positional argument
    args = parser.parse_args(argv)

    # create an instance of our options object
    options = Options()

    # store the verbosity
    if args.verbose:
        options.verbosity=args.verbose
    elif args.quiet:
        options.verbosity=QUIET

    # store the filename
    if args.filename:
        options.filename = args.filename
    else:
        parser.print_help()

    # do what you will

    return 0

def main(argv):
    options = handle_arguments(argv[1:])

if __name__ == '__main__':
    sys.exit(main(sys.argv))
