# vsub.py

import tensorflow as tf

def vsub(a_np, b_np, gpu_device="/GPU:0"):
    with tf.device(gpu_device):
        a = tf.convert_to_tensor(a_np)
        b = tf.convert_to_tensor(b_np)
        c = tf.subtract(a, b)
    return c.numpy()