# my_kernels.py

import os
import numpy as np
import tensorflow as tf #original sols aquest

def vadd(a_np, b_np, gpu_device="/GPU:0"):
    with tf.device(gpu_device):
        a = tf.convert_to_tensor(a_np)
        b = tf.convert_to_tensor(b_np)
        c = tf.add(a, b)
    return c.numpy()

def vsub(a_np, b_np, gpu_device="/GPU:0"):
    with tf.device(gpu_device):
        a = tf.convert_to_tensor(a_np)
        b = tf.convert_to_tensor(b_np)
        c = tf.subtract(a, b)
    return c.numpy()

def vmadd(a_np, b_np, c_np, gpu_device="/GPU:0"):
    with tf.device(gpu_device):
        a = tf.convert_to_tensor(a_np)
        b = tf.convert_to_tensor(b_np)
        c = tf.convert_to_tensor(c_np)
        d = tf.add(tf.multiply(a, b), c)
    return d.numpy()

def run(kernel_name, *args, gpu_device="/GPU:0"):
    with tf.device(gpu_device):
        kernel_fn = globals()[kernel_name]
        return kernel_fn(*args, gpu_device=gpu_device)

def np_load(config_str, data_idx, dtype_str):
    try:
        dtype = getattr(np, dtype_str)
    except AttributeError:
        raise ValueError(f"Unsupported data type: {dtype_str}")

    path = f"./data/input_{config_str}/input{data_idx}.npy"
    if not os.path.exists(path):
        raise FileNotFoundError(f"Input file not found: {path}")

    return np.load(path).astype(dtype)