//
//  bfloat16.c
//  BFloat16
//
//  Created by Ivar on 19/04/2025.
//

#include "bfloat16.h"
#include <stdint.h>
#include <stdbool.h>
#include <math.h>


// On Linux platforms the casting sometimes gets wacky, so we need to first promote
// the incoming value before storing it in the __fp16 type.
#if defined(__linux__)
#   define PROMOTE_SIGNED(x)   (long long)x
#   define PROMOTE_UNSIGNED(x) (unsigned long long)x
#else
#   define PROMOTE_SIGNED(x)   x
#   define PROMOTE_UNSIGNED(x) x
#endif

#define BF16_NAN 0xFFC1
#define BF16_SIG_NAN 0xFF81
#define BF16_INF 0x7F80
#define BF16_GREATEST_FIN_MAGNITUDE 0x7F7F
#define BF16_ZERO 0x0000
#define BF16_ONE 0x3F80
#define BF16_NEG_ZERO 0x8000
#define BF16_NEG_ONE 0xBF80
#define BF16_PI 0x4049
#define BF16_EPSILON 0x3C00

#ifdef __ARM_NEON
#include <arm_neon.h>
#endif

#ifdef __ARM_NEON
EXTERN_C BF16_FUNC bf16_t bf16_zero(void) { return 0.0; };
EXTERN_C BF16_FUNC bf16_t bf16_epsilon(void) { return (bf16_t)BF16_EPSILON; };
EXTERN_C BF16_FUNC bf16_t bf16_pi(void) { return (bf16_t)BF16_PI; };
EXTERN_C BF16_FUNC bf16_t bf16_nan(void) { return (bf16_t)BF16_NAN; };

#else
EXTERN_C BF16_FUNC bf16_t bf16_zero(void) { return BF16_ZERO; };
EXTERN_C BF16_FUNC bf16_t bf16_epsilon(void) { return BF16_EPSILON; };
EXTERN_C BF16_FUNC bf16_t bf16_pi(void) { return BF16_PI; };
EXTERN_C BF16_FUNC bf16_t bf16_nan(void) { return BF16_NAN; };
#endif

union float_bits {
  float f;
  uint32_t u;
};

EXTERN_C BF16_OFUNC bf16_t bf16_from(const float v) {
#ifdef __ARM_NEON
  const uint32_t *fromptr = (const uint32_t *)&v;
  uint16_t result;
  __asm __volatile("ldr    s0, [%[fromptr]]\n"
                   ".inst    0x1e634000\n" // BFCVT h0, s0
                   "str    h0, [%[toptr]]\n"
                   :
                   : [fromptr] "r"(fromptr), [toptr] "r"(&result)
                   : "v0", "memory");
  return result;
#else
  if (isnan(v)) {
    return BF16_NAN;
  } else if (isinf(v)) {
    return BF16_INF;
  } else {
    union float_bits fb;
    fb.f = v;
    if ((fb.u & 0x7FFFFFFF) <= 0x7F800000) {
      uint32_t round_bit = 0x00008000;
      if ((fb.u & round_bit) != 0 && (fb.u & (3 * round_bit - 1)) != 0) {
        return (fb.u >> 16) + 1;
      } else {
        return fb.u >> 16;
      }
    } else {
      return (fb.u >> 16) | 0x0040;
    }
  }
#endif
};
EXTERN_C BF16_OFUNC bf16_t bf16_from(const double v) { return bf16_from((float)v); };

EXTERN_C BF16_FUNC float to_f32(const bf16_t val) {
#ifdef __ARM_NEON
  uint16_t v = (uint16_t)val;
#else
  bf16_t v = val;
#endif
  if (v == BF16_NAN) {
    return NAN;
  } else if (v == BF16_INF) {
    return INFINITY;
  } else {
    union float_bits fb;
    if ((v & 0x7FFF) >= 0x7F80) {
      fb.u = v << 16;
      return fb.f;
    } else {
      fb.u = (v | 0x0040000) << 16;
      return fb.f;
    }
  }
}

EXTERN_C BF16_FUNC double to_f64(const bf16_t v) {
  return to_f32(v);
}

EXTERN_C BF16_FUNC bf16_t bf16_add(const bf16_t a, const bf16_t b) { return bf16_from(to_f32(a) + to_f32(b)); }
EXTERN_C BF16_FUNC bf16_t bf16_sub(const bf16_t a, const bf16_t b) { return bf16_from(to_f32(a) - to_f32(b)); }
EXTERN_C BF16_FUNC bf16_t bf16_mul(const bf16_t a, const bf16_t b) { return bf16_from(to_f32(a) * to_f32(b)); }
EXTERN_C BF16_FUNC bf16_t bf16_div(const bf16_t a, const bf16_t b) { return bf16_from(to_f32(a) / to_f32(b)); }
EXTERN_C BF16_FUNC bf16_t bf16_fma(const bf16_t a, const bf16_t b, const bf16_t c) {
  return bf16_from(fmaf(to_f32(a), to_f32(b), to_f32(c)));
}

EXTERN_C BF16_FUNC bf16_t bf16_neg(const bf16_t v) {
#ifdef __ARM_NEON
  return -v;
#else
  return v ^ 0x8000;
#endif
}
EXTERN_C BF16_FUNC bf16_t bf16_abs(const bf16_t v) {
#ifdef __ARM_NEON
  return (bf16_t)((uint16_t) v & 0x7FFF);
#else
  return v & 0x7FFF;
#endif
}
EXTERN_C BF16_FUNC bf16_t bf16_sqrt(const bf16_t v) { return bf16_from(sqrt(to_f32(v)));};

EXTERN_C BF16_FUNC bool equal(const bf16_t a, const bf16_t b) { return a == b; };
EXTERN_C BF16_FUNC bool lt(const bf16_t a, const bf16_t b) { return to_f32(a) < to_f32(b); };
EXTERN_C BF16_FUNC bool lte(const bf16_t a, const bf16_t b) { return to_f32(a) <= to_f32(b); };
EXTERN_C BF16_FUNC bool gt(const bf16_t a, const bf16_t b) { return to_f32(a) > to_f32(b); };
EXTERN_C BF16_FUNC bool gte(const bf16_t a, const bf16_t b) { return to_f32(a) >= to_f32(b); };


