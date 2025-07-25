import subprocess
import numpy as np
import os

class Device:
    def __init__(self, id, kernel, inputs):
        self.id = id
        self.kernel = kernel
        self.inputs = inputs  # list of input filenames

    def run(self, *args, output_file):
        assert len(args) == len(self.inputs), f"Expected {len(self.inputs)} inputs, got {len(args)}"
        input_paths = [f"data/{f}" for f in self.inputs]

        # Save the input args into .npy files in case they're not already on disk
        for path, arr in zip(input_paths, args):
            if not os.path.exists(path):
                np.save(path, arr)

        kernel_path = f"src/{self.kernel}.py"
        cmd = ["python3", kernel_path, *input_paths, f"data/{output_file}"]
        subprocess.run(cmd, check=True)
        return np.load(f"data/{output_file}")