import random
import string

def get_random_key(length):
    letters = string.ascii_lowercase
    digits = string.digits
    length = length
    result_str = ''.join(random.choice(letters + digits) for i in range(length))
    print(result_str)

get_random_key(5)