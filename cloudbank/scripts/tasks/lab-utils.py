import os
import argparse
import json
import random
import string
import logging
import re

# Initialize logging
logging.basicConfig(
    format='%(asctime)s: %(levelname)s - %(message)s',
    datefmt='%m/%d/%Y %I:%M:%S %p',
    level=logging.CRITICAL)
log = logging.getLogger("dev")


# Common Functions
def print_help(*args):
    print("Lab Utility Functions")
    print("For help, run python lab-utils.py -h")


# Parser Functions
def get_random_key(args):
    letters = string.ascii_lowercase
    digits = string.digits
    length = args.length
    result_str = ''.join(random.choice(letters + digits) for i in range(length))
    print(result_str)


def read_json(args):
    path = args.path.split('.')
    log.debug(f'path={path}')

    state = {}
    try:
        state_location = os.environ["CB_STATE_DIR"]
        log.debug(state_location)

        with open(f'{state_location}/state.json') as state_file:
            state["data"] = json.load(state_file)
    except FileNotFoundError:
        log.error("State file not found. Make sure you have run the setup script.")
        return None
    except KeyError:
        log.error("Lab variables not set. Please source source.env first")
        return None

    try:
        value = state["data"]
        for key in path:
            value = value[key]
        print(value)
    except KeyError:
        print()


def filter_for_jdk(args):
    # custom error
    class NoMatchFoundError(Exception):
        def __init__(self):
            self.message = f'Error: No match found.'
            super().__init__(self.message)

    # regex
    regex='^openjdk-11.\d+.\d+'
    log.debug(f'Filtering using regex: {regex}')

    # filtering inputs
    inputs = args.string
    log.debug(f'Filter from list: {str(inputs)}')
    f = re.compile(regex)
    matches = [ item for item in inputs if f.match(item) ]
    log.debug(f'Matches foumd: {str(matches)}')

    # processing results if matches found
    if len(matches) > 0:
        print(matches[0])
    else:
        raise NoMatchFoundError()


# CLI (using argparse)
parser = argparse.ArgumentParser()
sp = parser.add_subparsers(description="Lab Utility Functions")
parser.set_defaults(func=print_help)

# Generate Token Parser
# Used to generate random tokens
generate_token_parser = sp.add_parser("generate-token")
generate_token_parser.add_argument("-l", "--length", default=16, help="length of token to generate", type=int)
generate_token_parser.set_defaults(func=get_random_key)

# JSON Parser
# Used to parse the State file and read JSON keys instead of jq with better exception handling
# This avoids the issue with JQ returning null instead of an empty value
json_parser = sp.add_parser("json")
json_parser.add_argument("-p", "--path", required=True, help="Json Path Expression")
json_parser.set_defaults(func=read_json)

# Regex Filter
# Used by filtering csruntimectl JDK
filter_parser = sp.add_parser("filter")
filter_parser.add_argument("-s", "--string", nargs="+", required=True, help="Inputs to filter the JDK version from")
filter_parser.set_defaults(func=filter_for_jdk)

# Process Parsed Arguments
options = parser.parse_args()
options.func(options)
