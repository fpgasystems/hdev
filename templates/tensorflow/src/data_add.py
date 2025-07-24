import numpy as np
import os
import sys

# --- Read arguments ---
if len(sys.argv) != 4:
    print("Usage: python data_add.py <num_input_signals> <dtype> <size>")
    sys.exit(1)

num_inputs = int(sys.argv[1])
dtype_str = sys.argv[2]
size = int(sys.argv[3])  # <== Read size from argument

# --- Map string to NumPy dtype ---
dtype_map = {
    "fp32": np.float32,
    "fp64": np.float64,
    "int32": np.int32,
    "int64": np.int64,
    "bf16": np.float16  # Approximate bfloat16 with float16
}
if dtype_str not in dtype_map:
    print(f"Unsupported dtype: {dtype_str}")
    sys.exit(1)
dtype = dtype_map[dtype_str]

# --- Generate inputs ---
#os.makedirs("data", exist_ok=True)

for i in range(1, num_inputs + 1):
    arr = np.random.rand(size).astype(dtype)
    filename = f"input{i}.npy"
    np.save(filename, arr)
    #print(f"Saved {filename} with shape ({size},) and dtype {dtype_str}")

#print(f"Generated {num_inputs} inputs in /data/")