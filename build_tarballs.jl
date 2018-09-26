# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "LibHSAKMT"
version = v"1.9.0"

# Collection of sources required to build LibHSAKMT
sources = [
    "https://github.com/RadeonOpenCompute/ROCT-Thunk-Interface/archive/roc-1.9.0.tar.gz" =>
    "00fe91f3dcb9f3246945a2421e3df3cf618bb392c1b22aa485cf74ebc816f7d0",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd ROCT-Thunk-Interface-roc-1.9.0/
mkdir build
cd build
sed -i 's/^\(.*\)nodelete\(.*\)$/\1nodelete -L\/workspace\/destdir\/lib\/\2/g' ../CMakeLists.txt 
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain ..
make -j${nproc}
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:aarch64, libc=:musl)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libhsakmt", Symbol(""))
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/jpsamaroo/PCIUtilsBuilder/releases/download/v3.6.2/build_PCIUtils.v3.6.2.jl",
    "https://github.com/jpsamaroo/LibNUMABuilder/releases/download/v2.0.12/build_LibNUMA.v2.0.12.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

