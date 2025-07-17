import sys
import tensorflow as tf

# Parse GPU index from command line argument
if len(sys.argv) != 2:
    print("Usage: python add_vector.py <gpu_index>")
    sys.exit(1)

gpu_index = sys.argv[1]

# Print available GPUs
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

# Run vector addition on the selected GPU
with tf.device(gpu_device):
    a = tf.constant([1, 2, 3], dtype=tf.float32)
    b = tf.constant([4, 5, 6], dtype=tf.float32)
    c = tf.add(a, b)

print("Result of vector addition:", c.numpy())
