/*
 * Public wrapper for libjpeg's jpeglib.h.
 *
 * jpeglib.h deliberately does not include <stdio.h> (see the comment at the
 * top of the original header), so include it here before importing the real
 * header into Swift.
 */

#ifndef LIBJPEGTURBO_COMBINED_JPEGLIB_H
#define LIBJPEGTURBO_COMBINED_JPEGLIB_H

#include <stdio.h>
#include <stddef.h>

#include "../../../libjpeg-turbo/src/jpeglib.h"

#endif /* LIBJPEGTURBO_COMBINED_JPEGLIB_H */
