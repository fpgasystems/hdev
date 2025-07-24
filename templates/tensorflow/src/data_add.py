import numpy as np
import os

# Create /data folder if it doesn't exist
os.makedirs("data", exist_ok=True)

# Define the shape and values (you can change these)
size = 1000  # number of elements
input1 = np.random.rand(size).astype(np.float32)
input2 = np.random.rand(size).astype(np.float32)

# Save the arrays
np.save("data/input1.npy", input1)
np.save("data/input2.npy", input2)

print("Generated input1.npy and input2.npy in /data")