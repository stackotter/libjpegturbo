/*
 * SwiftPM wrapper for libjpeg-turbo's arm/jfdctfst-neon.c.
 *
 * The original file lives outside this target's directory, and SwiftPM cannot
 * select source files based on the target architecture.  Including it from a
 * wrapper guarded by the architecture macros gives SwiftPM a portable source
 * list: the wrapper is empty on architectures without a supported SIMD
 * implementation.
 */

#if defined(__aarch64__) || defined(_M_ARM64)
#include "../../libjpeg-turbo/simd/arm/jfdctfst-neon.c"
#endif
