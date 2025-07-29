# my_functions.py

import os
import numpy as np

def np_load(config_str, data_idx, dtype_str):
    try:
        dtype = getattr(np, dtype_str)
    except AttributeError:
        raise ValueError(f"Unsupported data type: {dtype_str}")

    path = f"./data/input_{config_str}/input{data_idx}.npy"
    if not os.path.exists(path):
        raise FileNotFoundError(f"Input file not found: {path}")

    return np.load(path).astype(dtype)