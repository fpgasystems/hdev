#ifndef CPU_VECSUB_H
#define CPU_VECSUB_H

// CPU implementation of vector sub
namespace cpu {
    void vsub(double *a, double *b, double *c, int N, int deviceId);
}

#endif // CPU_VECSUB_H