import random
import string
import sys


def get_random_key(length):
    letters = string.ascii_lowercase
    digits = string.digits
    result_str = ''.join(random.choice(letters+digits) for i in range(length))
    print(result_str)


args = sys.argv[1:]
try:
    length = int(args[0])
    get_random_key(length)
except (ValueError, IndexError):
    get_random_key(16)
