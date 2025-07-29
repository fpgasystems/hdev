import numpy as np
import os
import sys

if len(sys.argv) != 4:
    print("Usage: python data_add.py <num_input_signals> <dtype> <size>")
    sys.exit(1)

num_inputs = int(sys.argv[1])
dtype = sys.argv[2]
size = int(sys.argv[3]) 

for i in range(1, num_inputs + 1):
    arr = np.random.rand(size).astype(dtype)
    filename = f"input{i}.npy"
    np.save(filename, arr)