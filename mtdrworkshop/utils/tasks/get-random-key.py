import random
import string



def get_random_key(l):
    letters = string.ascii_lowercase
    digits = string.digits
    result_str = ''.join(random.choice(letters + digits) for i in range(l))
    print(result_str)


get_random_key(5)