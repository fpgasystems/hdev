# main.py

import sys
import numpy as np
import tensorflow as tf
from my_functions import np_load
from my_kernels import run,vadd,vsub

if len(sys.argv) != 2:
    print("Usage: python main.py <config_string>")
    sys.exit(1)

#data_type = sys.argv[1]
config_string = sys.argv[1]

# Check for available GPUs
gpus = tf.config.list_physical_devices('GPU')
if not gpus:
    print("No GPU found")
    sys.exit(1)

print("TensorFlow version:", tf.__version__)

#load inputs
input1 = np_load(1, config_string)
input2 = np_load(2, config_string)

#run kernels
vadd_out1 = run(1, input1, input2)
print("vadd (device 1):", vadd_out1)

vsub_out1 = run(2, vadd_out1, input2)
print("vsub (device 2)", vsub_out1)

#test
if np.allclose(vsub_out1, input1):
    print("Test passed!")
else:
    print("Test failed!")