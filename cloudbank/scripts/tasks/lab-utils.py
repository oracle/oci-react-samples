import os
import argparse
import json
import random
import string
import logging


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
    log.info(f'path={path}')

    state = {}
    try:
        state_location = os.environ["CB_STATE_DIR"]
        log.info(state_location)

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


# CLI (using argparse)
parser = argparse.ArgumentParser()
sp = parser.add_subparsers(description="Lab Utility Functions")
parser.set_defaults(func=print_help)

# Generate Token Parser
generate_token_parser = sp.add_parser("generate-token")
generate_token_parser.add_argument("-l", "--length", default=16, help="length of token to generate", type=int)
generate_token_parser.set_defaults(func=get_random_key)

generate_token_parser = sp.add_parser("json")
generate_token_parser.add_argument("-p", "--path", required=True, help="Json Path Expression")
generate_token_parser.set_defaults(func=read_json)

# Process Parsed Arguments
options = parser.parse_args()
options.func(options)
