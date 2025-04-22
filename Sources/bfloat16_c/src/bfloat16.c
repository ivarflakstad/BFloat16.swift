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

#define BF16_NAN 0x7FC0
#define BF16_SIG_NAN 0xFF81
#define BF16_INF 0x7F80
#define BF16_NEG_INF 0xFF80
#define BF16_GREATEST_FIN_MAGNITUDE 0x7F7F
#define BF16_ZERO 0x0000
#define BF16_ONE 0x3F80
#define BF16_NEG_ZERO 0x8000
#define BF16_NEG_ONE 0xBF80
#define BF16_PI 0x4049
#define BF16_EPSILON 0x3C00

__ai bf16_t bf16_epsilon(void) { return BF16_EPSILON; }
__ai bf16_t bf16_pi(void) { return BF16_PI; }
__ai bf16_t bf16_nan(void) { return BF16_NAN; }

union float_bits {
  float f;
  uint32_t u;
};

__aio bf16_t bf16_from(const float v) {
  // TODO: ifs seem to be unecessary. Probably more performant to remove them.
  if (isnan(v)) {
    return signbit(v) ? BF16_SIG_NAN : BF16_NAN;
  } else if (isinf(v)) {
    return signbit(v) ? BF16_NEG_INF : BF16_INF;
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
}

__aio bf16_t bf16_from(const double v) { return bf16_from((float)v); }
// NOTE: without native bfloat support currently a noop
__aio bf16_t bf16_from(const uint16_t v) { return (uint16_t)v; }

__ai bool bf16_isnan(const bf16_t v) {
  return (v & BF16_INF) == BF16_INF && (v & 0x007FU) != 0;
}

__ai float to_f32(const bf16_t v) {
#if NATIVE_BF16_SUPPORT
  return (float)v;
#else
  // TODO: ifs seem to be unecessary. Probably more performant to remove them.
  if (bf16_isnan(v)) {
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
#endif
}

__ai double to_f64(const bf16_t v) { return to_f32(v); }
extern __ai uint16_t bf16_to_ushort(const bf16_t v) { return v; }

__ai bf16_t bf16_add(const bf16_t a, const bf16_t b) { return bf16_from(to_f32(a) + to_f32(b)); }
__ai bf16_t bf16_sub(const bf16_t a, const bf16_t b) { return bf16_from(to_f32(a) - to_f32(b)); }
__ai bf16_t bf16_mul(const bf16_t a, const bf16_t b) { return bf16_from(to_f32(a) * to_f32(b)); }
__ai bf16_t bf16_div(const bf16_t a, const bf16_t b) { return bf16_from(to_f32(a) / to_f32(b)); }
__ai bf16_t bf16_fma(const bf16_t a, const bf16_t b, const bf16_t c) {
  return bf16_from(fmaf(to_f32(a), to_f32(b), to_f32(c)));
}

__ai bf16_t bf16_neg(const bf16_t v) {
#if NATIVE_BF16_SUPPORT
  return -v;
#else
  return v ^ 0x8000;
#endif
}

__ai bf16_t bf16_abs(const bf16_t v) {
#if NATIVE_BF16_SUPPORT
  return (bf16_t)fabsf((float)v);
#else
  if ((v & 0x8000) == 0) {
    return v;
  }
  return v & 0x7FFF;
#endif
}

__ai bf16_t bf16_sqrt(const bf16_t v) { return bf16_from(sqrt(to_f32(v)));}

__ai bool equal(const bf16_t a, const bf16_t b) {
  if (bf16_isnan(a)) return 0;
  if (bf16_isnan(b)) return 0;
  if (((a &~ 0x8000) == 0) && ((b &~ 0x8000) == 0)) return 1;
  return a == b;
};
__ai bool lt(const bf16_t a, const bf16_t b) {
  if (bf16_isnan(a)) return 0;
  if (bf16_isnan(b)) return 0;
  bool a_is_negative = a & 0x8000;
  bool b_is_negative = b & 0x8000;
  
  if (a_is_negative != b_is_negative) {
    return a_is_negative && (a | b) &~ 0x8000;
  }
  return a_is_negative ? a > b : a < b;
}
__ai bool lte(const bf16_t a, const bf16_t b) {
  return lt(a, b) || equal(a, b);
}
__ai bool gt(const bf16_t a, const bf16_t b) {
  return lt(b, a);
}
__ai bool gte(const bf16_t a, const bf16_t b) {
  return lte(b, a);
}
