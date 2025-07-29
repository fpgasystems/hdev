# my_kernels.py

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

def vmadd(a_np, b_np, c_np, gpu_device="/GPU:0"):
    with tf.device(gpu_device):
        a = tf.convert_to_tensor(a_np)
        b = tf.convert_to_tensor(b_np)
        c = tf.convert_to_tensor(c_np)
        d = tf.add(tf.multiply(a, b), c)
    return d.numpy()

# Mapping kernel names to actual function objects
kernels = {
    "vadd": vadd,
    "vsub": vsub,
    "vmadd": vmadd,
}

def run(gpu_index, kernel_name, *args):
    gpu_device = f"/GPU:{int(gpu_index) - 1}"
    if kernel_name not in kernels:
        raise ValueError(f"Unknown kernel name: {kernel_name}")
    return kernels[kernel_name](*args, gpu_device=gpu_device)