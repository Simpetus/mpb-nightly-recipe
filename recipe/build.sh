#!/bin/bash

set -o xtrace

export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"

# We need to install a later MacOS SDK than the default Travis SDK for compatibilty with the Anaconda compilers.
if [[ $(uname) == Darwin ]]; then
    export MACOSX_DEPLOYMENT_TARGET="10.9"
    if [[ "$HOME" == "/Users/travis" ]]; then
        export CONDA_BUILD_SYSROOT="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk"
        echo "Downloading ${MACOSX_DEPLOYMENT_TARGET} sdk"
        curl -L -O https://github.com/phracker/MacOSX-SDKs/releases/download/10.13/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk.tar.xz
        tar -xf MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk.tar.xz -C "$(dirname "$CONDA_BUILD_SYSROOT")"
        # set minimum sdk version to our target
        plutil -replace MinimumSDKVersion -string ${MACOSX_DEPLOYMENT_TARGET} $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist
        plutil -replace DTSDKName -string macosx${MACOSX_DEPLOYMENT_TARGET}internal $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist
    fi
fi

if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
    # We don't actually compile parallel MPB here (--enable-parallel) because
    # the Python MPB interface in Pymeep isn't compatible with parallel MPB.
    # However, since the parallel Python interface uses parallel HDF5, we
    # need to build MPB against parallel HDF5, which just requires the MPI
    # compiler wrappers.
    export CC=mpicc
    export CXX=mpicxx
fi

sh autogen.sh                \
    --prefix=$PREFIX         \
    --enable-shared          \
    --with-libctl=no         \
    --with-hermitian-eps

make -j ${CPU_COUNT}
make install

rm ${PREFIX}/lib/libmpb.a
