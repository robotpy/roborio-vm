#!/bin/bash -e
#
# Downloads a stock kernel from Xilinx's wiki. It's not perfect, but it gets the
# job done.
#

cd `dirname $0`

[ -d linux ] || mkdir linux
pushd linux

wget -c http://www.wiki.xilinx.com/file/view/2016.2-zed-release.tar.xz/586243277/2016.2-zed-release.tar.xz

[ ! -f uImage ] || rm uImage
[ ! -f devicetree.dtb ] || rm devicetree.dtb

tar -xf 2016.2-zed-release.tar.xz --strip=1 zed/uImage
tar -xf 2016.2-zed-release.tar.xz --strip=1 zed/devicetree.dtb

echo "Success!"

popd
