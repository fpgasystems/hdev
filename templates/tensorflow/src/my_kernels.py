# my_kernels.py

import os
import configparser
import tensorflow as tf

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

#-----------------------------------------------------------------------------------------

def get_kernel_name(gpu_index, config_path="kn.cfg"):
    config = configparser.ConfigParser()
    config.read(config_path)

    key = str(gpu_index)
    if "kernels" not in config or key not in config["kernels"]:
        raise ValueError(f"No kernel assigned to GPU index {gpu_index} in {config_path}")
    
    return config["kernels"][key].strip()

def run(gpu_index, *args):
    kernel_name = get_kernel_name(gpu_index)
    kernel_func = globals().get(kernel_name)

    if kernel_func is None or not callable(kernel_func):
        raise ValueError(f"Kernel function '{kernel_name}' is not defined.")

    gpu_device = f"/GPU:{int(gpu_index) - 1}"
    return kernel_func(*args, gpu_device=gpu_device)