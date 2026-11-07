/*
 * This target exists only to combine the libjpeg and TurboJPEG headers into a
 * single Clang module for the JPEGTurbo Swift target.
 */

#include <turbojpeg.h>

int libjpegturbo_combined_version = TURBOJPEG_VERSION_NUMBER;
