//
//  bfloat16.h
//  BFloat16
//
//  Created by Ivar on 19/04/2025.
//
#ifndef bf16_h
#define bf16_h

#include <stdint.h>
#include <stdbool.h>

#if !defined(EXTERN_C)
#   if defined(__cplusplus)
#       define EXTERN_C extern "C"
#   else
#       define EXTERN_C extern
#   endif // #if defined(__cplusplus)
#endif // #if !defined(EXTERN_C)

#if __has_attribute(__const__)
#   define BF16_CONST   __attribute__((__const__))
#else
#   define BF16_CONST   /* nothing */
#endif

// Copied from <Foundation/NSObjCRuntime.h> since that header cannot be imported
#if !defined(NS_SWIFT_SENDABLE)
#   if defined(__SWIFT_ATTR_SUPPORTS_SENDABLE_DECLS) && __SWIFT_ATTR_SUPPORTS_SENDABLE_DECLS
#       define NS_SWIFT_SENDABLE __attribute__((swift_attr("@Sendable")))
#   else
#       define NS_SWIFT_SENDABLE
#   endif
#endif // #if !defined(NS_SWIFT_SENDABLE)

#define BF16_FUNC BF16_CONST
#define BF16_OFUNC BF16_FUNC __attribute__((__overloadable__))
//#define __ai static __inline__ __attribute__((__always_inline__, __nodebug__))
//#define __aio static __inline__ __attribute__((__always_inline__, __nodebug__, __overloadable__))

#if !defined(__ARM_NEON)
#define NATIVE_BF16_SUPPORT 1
#pragma GCC push_options
#pragma GCC target ("+nothing+bf16+nosimd")
#include <arm_neon.h>
#include <arm_bf16.h>

typedef bfloat16_t bf16_t;

__extension__ extern __inline bfloat16_t
__attribute__ ((__always_inline__, __gnu_inline__, __artificial__))
_vcvth_bf16_f32 (float32_t __a)
{
  return vcvth_bf16_f32(__a);
}

__extension__ extern __inline float32_t
__attribute__ ((__always_inline__, __gnu_inline__, __artificial__))
_vcvtah_f32_bf16 (bfloat16_t __a)
{
  return vcvtah_f32_bf16 (__a);
}


#pragma GCC pop_options

#else
#define NATIVE_BF16_SUPPORT 0

typedef uint16_t NS_SWIFT_SENDABLE bf16_t;

#endif

//#ifdef  __cplusplus
//extern "C" {
//#else
//#include <stdbool.h>
//#endif

EXTERN_C BF16_FUNC bf16_t bf16_zero(void);
EXTERN_C BF16_FUNC bf16_t bf16_epsilon(void);
EXTERN_C BF16_FUNC bf16_t bf16_pi(void);
EXTERN_C BF16_FUNC bf16_t bf16_nan(void);

EXTERN_C BF16_FUNC uint16_t bf16_to_raw(const bf16_t);
EXTERN_C BF16_FUNC bf16_t bf16_from_raw(const uint16_t);

EXTERN_C BF16_OFUNC bf16_t bf16_from(const double);
EXTERN_C BF16_OFUNC bf16_t bf16_from(const float);
/*
EXTERN_C BF16_OFUNC bf16_t bf16_from(const long long);
EXTERN_C BF16_OFUNC bf16_t bf16_from(const long);
EXTERN_C BF16_OFUNC bf16_t bf16_from(const int);
EXTERN_C BF16_OFUNC bf16_t bf16_from(const short);
EXTERN_C BF16_OFUNC bf16_t bf16_from(const char);
EXTERN_C BF16_OFUNC bf16_t bf16_from(const unsigned long long);
EXTERN_C BF16_OFUNC bf16_t bf16_from(const unsigned long);
EXTERN_C BF16_OFUNC bf16_t bf16_from(const unsigned int);
EXTERN_C BF16_OFUNC bf16_t bf16_from(const unsigned short);
EXTERN_C BF16_OFUNC bf16_t bf16_from(const unsigned char);
*/

EXTERN_C BF16_FUNC double to_f64(const bf16_t);
EXTERN_C BF16_FUNC float to_f32(const bf16_t);
/*
EXTERN_C BF16_FUNC long long          bf16_to_longlong(const bf16_t);
EXTERN_C BF16_FUNC long               bf16_to_long(const bf16_t);
EXTERN_C BF16_FUNC int                bf16_to_int(const bf16_t);
EXTERN_C BF16_FUNC short              bf16_to_short(const bf16_t);
EXTERN_C BF16_FUNC char               bf16_to_char(const bf16_t);
EXTERN_C BF16_FUNC unsigned long long bf16_to_ulonglong(const bf16_t);
EXTERN_C BF16_FUNC unsigned long      bf16_to_ulong(const bf16_t);
EXTERN_C BF16_FUNC unsigned int       bf16_to_uint(const bf16_t);
EXTERN_C BF16_FUNC unsigned short     bf16_to_ushort(const bf16_t);
EXTERN_C BF16_FUNC unsigned char      bf16_to_uchar(const bf16_t);
*/

EXTERN_C BF16_FUNC bf16_t bf16_add(const bf16_t, const bf16_t);
EXTERN_C BF16_FUNC bf16_t bf16_sub(const bf16_t, const bf16_t);
EXTERN_C BF16_FUNC bf16_t bf16_mul(const bf16_t, const bf16_t);
EXTERN_C BF16_FUNC bf16_t bf16_div(const bf16_t, const bf16_t);
EXTERN_C BF16_FUNC bf16_t bf16_fma(const bf16_t, const bf16_t, const bf16_t);

EXTERN_C BF16_FUNC bf16_t bf16_neg(const bf16_t);
EXTERN_C BF16_FUNC bf16_t bf16_abs(const bf16_t);
EXTERN_C BF16_FUNC bf16_t bf16_sqrt(const bf16_t);

EXTERN_C BF16_FUNC bool equal(const bf16_t, const bf16_t);
EXTERN_C BF16_FUNC bool lt(const bf16_t, const bf16_t);
EXTERN_C BF16_FUNC bool lte(const bf16_t, const bf16_t);
EXTERN_C BF16_FUNC bool gt(const bf16_t, const bf16_t);
EXTERN_C BF16_FUNC bool gte(const bf16_t, const bf16_t);

#endif
  
