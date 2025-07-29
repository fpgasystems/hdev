# my_functions.py

import os
import numpy as np

def np_load(data_idx, config_str):
    # Path to config file
    config_path = f"./data/input_{config_str}/device_config"
    
    # Check config file exists
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Config file not found: {config_path}")
    
    # Read precision from config
    precision = None
    with open(config_path) as f:
        for line in f:
            if line.strip().startswith("precision"):
                # Extract value after '=' and strip off trailing ';'
                precision = line.split("=")[1].strip().strip(";")
                break

    if precision is None:
        raise ValueError("Precision not defined in device_config")

    try:
        dtype = getattr(np, precision)
    except AttributeError:
        raise ValueError(f"Unsupported precision type: {precision}")

    # Path to input file
    data_path = f"./data/input_{config_str}/input{data_idx}.npy"
    if not os.path.exists(data_path):
        raise FileNotFoundError(f"Input file not found: {data_path}")

    return np.load(data_path).astype(dtype)