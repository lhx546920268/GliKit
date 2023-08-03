#!/bin/sh

###########################################################################
#  Change values here
SDKVERSION="16.2"
###########################################################################
#                                                                                                              #
# Don't change anything under this line!                                                  #
#                                                                                                              #
###########################################################################

CURRENTPATH=`pwd`
ARCHS="arm64"
LIBRTMPREPO="git://git.ffmpeg.org/rtmpdump"
BUILDPATH="${CURRENTPATH}/build"
LIBPATH="${CURRENTPATH}/lib"
INCLUDEPATH="${CURRENTPATH}/include"
SRCPATH="${CURRENTPATH}/src"
LIBRTMP="librtmp.a"
DEVELOPER=`xcode-select -print-path`

if [ ! -d "$DEVELOPER" ]; then
  echo "xcode path is not set correctly $DEVELOPER does not exist (most likely because of xcode > 4.3)"
  echo "run"
  echo "sudo xcode-select -switch <xcode path>"
  echo "for default installation:"
  echo "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer"
  exit 1
fi

# Check whether openssl has already installed on the machine or not.
# libcrypt.a / libssl.a

set -e
echo 'Check openssl installation'
if [ -f "${LIBPATH}/libcrypto.a" ] && [ -f "${LIBPATH}/libssl.a" ] && [ -d "${INCLUDEPATH}/openssl" ]; then
  echo 'Openssl for iOS has already installed, no need to install openssl'
else
  echo 'Openssl for iOS not found, will install openssl for iOS'
  ./build-libssl.sh
  echo 'Succeeded to install openssl'
fi

# Download librtmp source code from git repository
# We assuem the user already installed git client.
echo 'Clone librtmp git repository'

# Remove the directory if already exist
rm -rf "${SRCPATH}/rtmpdump"

git clone ${LIBRTMPREPO} src/rtmpdump
cd "${SRCPATH}/rtmpdump/librtmp"

LIBRTMP_REPO=""

for ARCH in ${ARCHS}
do
  if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ];
  then
      PLATFORM="iPhoneSimulator"
  else
      PLATFORM="iPhoneOS"
  fi

  export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
  export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"
  export BUILD_TOOLS="${DEVELOPER}"

  echo "Building librtmp for ${PLATFORM} ${SDKVERSION} ${ARCH}"
  echo "Please wait..."

  # add arch to CC=
  sed -ie "s!AR=\$(CROSS_COMPILE)ar!AR=/usr/bin/ar!" "Makefile"
  sed -ie "/CC=\$(CROSS_COMPILE)gcc/d" "Makefile"
  echo "CC=\$(CROSS_COMPILE)gcc -arch ${ARCH}" >> "Makefile"

  export CROSS_COMPILE="${DEVELOPER}/usr/bin/"
  export XCFLAGS="-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -miphoneos-version-min=11.0 -I${INCLUDEPATH} -arch ${ARCH}"

  if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ];
  then
      export XLDFLAGS="-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -miphoneos-version-min=11.0 -L${LIBPATH} -arch ${ARCH}"
  else
      export XLDFLAGS="-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -miphoneos-version-min=11.0 -L${LIBPATH} -arch ${ARCH}"
  fi

  OUTPATH="${BUILDPATH}/librtmp-${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
  mkdir -p "${OUTPATH}"
  LOG="${OUTPATH}/build-librtmp.log"

  make SYS=darwin >> "${LOG}" 2>&1
  make SYS=darwin prefix="${OUTPATH}" install  >> "${LOG}" 2>&1
  make clean >> "${LOG}" 2>&1

  LIBRTMP_REPO+="${OUTPATH}/lib/${LIBRTMP} "
done

echo "Build universal library..."
lipo -create ${LIBRTMP_REPO}-output ${LIBPATH}/${LIBRTMP}

mkdir -p ${INCLUDEPATH}
cp -R ${BUILDPATH}/librtmp-iPhoneSimulator${SDKVERSION}-i386.sdk/include/ ${INCLUDEPATH}/

echo "Building done."
echo "Cleaning up..."

rm -rf ${SRCPATH}/rtmpdump
echo "Done."
