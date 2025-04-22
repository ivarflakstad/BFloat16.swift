//
//  bfloat16.h
//  BFloat16
//
//  Created by Ivar on 19/04/2025.
//
#ifndef bf16_h
#define bf16_h

// Copied from <Foundation/NSObjCRuntime.h> since that header cannot be imported
#if !defined(NS_SWIFT_SENDABLE)
#   if defined(__SWIFT_ATTR_SUPPORTS_SENDABLE_DECLS) && __SWIFT_ATTR_SUPPORTS_SENDABLE_DECLS
#       define NS_SWIFT_SENDABLE __attribute__((swift_attr("@Sendable")))
#   else
#       define NS_SWIFT_SENDABLE
#   endif
#endif // #if !defined(NS_SWIFT_SENDABLE)

#if __has_attribute(__const__)
#   define __ai __inline__ __attribute__((__const__, __always_inline__, __nodebug__))
#   define __aio __inline__ __attribute__((__const__, __always_inline__, __nodebug__, __overloadable__))
#else
#   define __ai __inline__ __attribute__((__always_inline__, __nodebug__))
#   define __aio __inline__ __attribute__((__always_inline__, __nodebug__, __overloadable__))
#endif

// TODO: compile with native bfloat support. target +bf16
#define NATIVE_BF16_SUPPORT 0


#ifdef  __cplusplus
extern "C" {
#else
#include <stdint.h>
#include <stdbool.h>
#endif

typedef uint16_t NS_SWIFT_SENDABLE bf16_t;

extern __ai bf16_t bf16_epsilon(void);
extern __ai bf16_t bf16_pi(void);
extern __ai bf16_t bf16_nan(void);

extern __aio bf16_t bf16_from(const double);
extern __aio bf16_t bf16_from(const float);
extern __aio bf16_t bf16_from(const uint16_t);

extern __ai bool bf16_isnan(const bf16_t v);

extern __ai double to_f64(const bf16_t);
extern __ai float to_f32(const bf16_t);
extern __ai uint16_t bf16_to_ushort(const bf16_t);

extern __ai bf16_t bf16_add(const bf16_t, const bf16_t);
extern __ai bf16_t bf16_sub(const bf16_t, const bf16_t);
extern __ai bf16_t bf16_mul(const bf16_t, const bf16_t);
extern __ai bf16_t bf16_div(const bf16_t, const bf16_t);
extern __ai bf16_t bf16_fma(const bf16_t, const bf16_t, const bf16_t);

extern __ai bf16_t bf16_neg(const bf16_t);
extern __ai bf16_t bf16_abs(const bf16_t);
extern __ai bf16_t bf16_sqrt(const bf16_t);

extern __ai bool equal(const bf16_t, const bf16_t);
extern __ai bool lt(const bf16_t, const bf16_t);
extern __ai bool lte(const bf16_t, const bf16_t);
extern __ai bool gt(const bf16_t, const bf16_t);
extern __ai bool gte(const bf16_t, const bf16_t);



#endif

#ifdef  __cplusplus
}
#endif
