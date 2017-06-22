#
# To produce the ./configure script, run `autoreconf`
#

AC_INIT

# Configure the C++ compiler
AC_PROG_CXX

CXXFLAGS="-std=c++11 -O3 -fwrapv -Wall"

# Option to disable assertions and debug information
AC_ARG_ENABLE(
    ndebug,
    "--enable-ndebug disables assertions",
    [CXXFLAGS="${CXXFLAGS} -DNDEBUG"],
    [CXXFLAGS="${CXXFLAGS} -g"]
)

# If building with SDL2
AC_ARG_WITH([sdl2], AS_HELP_STRING([--with-sdl2], [Build with SDL2 for audio/video output]))
AS_IF([test "x$with_sdl2" = "xyes"], [
    # Check for the presence of the SDL2 library
    PKG_CHECK_MODULES(SDL, [sdl2 >= 2.0.0], [CXXFLAGS="${CXXFLAGS} -DHAVE_SDL2"])
    # Add SDL2 compiler flags and libraries
    CXXFLAGS="${CXXFLAGS} ${SDL_CFLAGS}"
    LDFLAGS="${LDFLAGS} ${SDL_LIBS}"
])

# Substitute the variables CFLAGS and LDFLAGS in files to be configured
AC_SUBST(CXXFLAGS)
AC_SUBST(LDFLAGS)

# Process makefile.in
AC_CONFIG_FILES(makefile)

AC_OUTPUT
