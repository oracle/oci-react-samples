# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
# Used for v2.0.1

import random
import string



def get_random_key(l):
    letters = string.ascii_lowercase
    digits = string.digits
    result_str = ''.join(random.choice(letters + digits) for i in range(l))
    print(result_str)


get_random_key(5)