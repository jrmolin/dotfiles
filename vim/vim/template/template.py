#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import sys

def main(argv):

    parser = argparse.ArgumentParser()

    parser.add_argument("filename", help="path/to/filename to operate on")

    args = parser.parse_args()

    with open(args.filename, 'rb') as f:
        data = f.read()

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
