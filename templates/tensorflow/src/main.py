# main.py

import sys
import numpy as np
import tensorflow as tf
from my_functions import np_load
from my_kernels import run,vadd,vsub,vmadd

if len(sys.argv) != 4:
    print("Usage: python main.py <gpu_index> <data_type> <config_string>")
    sys.exit(1)
#if len(sys.argv) != 6:
#    print("Usage: python main.py <gpu_index> <input1.npy> <input2.npy> <data_type> <config_string>")
#    sys.exit(1)

gpu_index = sys.argv[1]
#input1_path = sys.argv[2]
#input2_path = sys.argv[3]
data_type = sys.argv[2]
config_string = sys.argv[3]

# Check for available GPUs
gpus = tf.config.list_physical_devices('GPU')
if not gpus:
    print("No GPU found")
    sys.exit(1)

if not gpu_index.isdigit() or int(gpu_index) >= len(gpus):
    print(f"Invalid GPU index. Available GPUs: {len(gpus)}")
    sys.exit(1)

gpu_device = f"/GPU:{gpu_index}"

print("TensorFlow version:", tf.__version__)
print(f"Using device: {gpu_device}")
#print(f"Reading input files: {input1_path}, {input2_path}")

# Load inputs
#a_np = np.load(input1_path).astype(np.float32)
#b_np = np.load(input2_path).astype(np.float32)
a_np = np_load(config_string, 1, data_type)
b_np = np_load(config_string, 2, data_type)

# Ensure shape match
if a_np.shape != b_np.shape:
    print("Input arrays must have the same shape.")
    sys.exit(1)

# Call vector add on GPU 0
c_np = vadd(a_np, b_np, gpu_device=gpu_device)
print("Result of vector addition:", c_np)
np.save("./data/output_add.npy", c_np)
print("Output saved to output_add.npy")

# Call vector sub on GPU 1
cc_np = vsub(a_np, b_np, gpu_device="/GPU:1")
print("Result of vector subtraction:", cc_np)
np.save("./data/output_sub.npy", cc_np)
print("Output saved to output_sub.npy")

#test
#test = run("vadd", a_np, b_np, gpu_device="/GPU:0")
test = run(1, "vadd", a_np, b_np)
print("Result of run:", test)