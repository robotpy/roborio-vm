#!/bin/bash -e
#
# Downloads a stock kernel from Xilinx's wiki. It's not perfect, but it gets the
# job done.
#

cd `dirname $0`

[ -d linux ] || mkdir linux
pushd linux

wget -c http://www.wiki.xilinx.com/file/view/2014.3-release.tar.xz/526959742/2014.3-release.tar.xz

[ ! -f uImage ] || rm uImage
[ ! -f devicetree.dtb ] || rm devicetree.dtb

tar -xf 2014.3-release.tar.xz uImage
tar -xf 2014.3-release.tar.xz --strip=1 zed/devicetree.dtb

echo "Success!"

popd
