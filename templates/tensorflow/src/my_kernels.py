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

def run(kernel_name, *args, gpu_device="/GPU:0"):
    with tf.device(gpu_device):
        kernel_fn = globals()[kernel_name]
        return kernel_fn(*args, gpu_device=gpu_device)