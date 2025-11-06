#ifndef CPU_VECADD_H
#define CPU_VECADD_H

// CPU implementation of vector add
namespace cpu {
    void vadd(double *a, double *b, double *c, int N, int deviceId);
}

#endif // CPU_VECADD_H