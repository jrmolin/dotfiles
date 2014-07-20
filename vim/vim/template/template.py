#!/usr/bin/env python

# generally need this
import sys

def handle_args(argv):
	import argparse
	argparser = argparse.ArgumentParser(description="TODO")
	argparser.add_argument('-v', '--verbose', dest='verbosity', action='count',
		default=0, help='verbose mode (aggregate)')
	argparser.add_argument('query', nargs='*', default=None)

	args = argparser.parse_args(argv)

	return args

def main(argv):
	args = handle_args(argv)

	return 0


if __name__ == '__main__':
	sys.exit(main(sys.argv))
