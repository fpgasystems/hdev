#include "vadd.hpp"

// Each iteration handles one element of c
namespace cpu {
    void vadd(double *a, double *b, double *c, int N, int deviceId)
    {
        (void)deviceId; // unused, kept for parity with GPU signature
        for (int id = 0; id < N; ++id) {
            c[id] = a[id] + b[id];
        }
    }
}