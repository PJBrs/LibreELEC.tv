# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="brcmfmac_sdio-firmware"
#PKG_VERSION="428ee70f59671a5c620466e8be1d320a66c1bf8b"
PKG_VERSION="a263daa9878a1106e1d5914b5f8193169c708641"
#PKG_SHA256="6b61755d8735053d00c67c158af4d931d88fd7c4c18413830309e92c44f4b295"
PKG_SHA256="6a4295d8c5dc31098fc5e4c00b43f73c4c9c383b1fb68133a86429c71e44b4a6"
PKG_LICENSE="GPL"
#PKG_SITE="https://github.com/LibreELEC/brcmfmac_sdio-firmware"
#PKG_URL="https://github.com/LibreELEC/brcmfmac_sdio-firmware/archive/$PKG_VERSION.tar.gz"
PKG_SITE="https://github.com/PJBrs/brcmfmac_sdio-firmware"
PKG_URL="https://github.com/PJBrs/brcmfmac_sdio-firmware/archive/$PKG_VERSION.tar.gz"
PKG_LONGDESC="Broadcom SDIO firmware used with LibreELEC"
PKG_TOOLCHAIN="manual"

post_makeinstall_target() {
  FW_TARGET_DIR=$INSTALL/$(get_full_firmware_dir)

  if find_file_path firmwares/$PKG_NAME.dat; then
    FW_LISTS="${FOUND_PATH}"
  else
    FW_LISTS="${PKG_DIR}/firmwares/any.dat ${PKG_DIR}/firmwares/${TARGET_ARCH}.dat"
  fi

  for fwlist in ${FW_LISTS}; do
    [ -f ${fwlist} ] || continue
    while read -r fwline; do
      [ -z "${fwline}" ] && continue
      [[ ${fwline} =~ ^#.* ]] && continue
      [[ ${fwline} =~ ^[[:space:]] ]] && continue

      for fwfile in $(cd ${PKG_BUILD} && eval "find ${fwline}"); do
        [ -d ${PKG_BUILD}/${fwfile} ] && continue
        if [ -f ${PKG_BUILD}/${fwfile} ]; then
          mkdir -p $(dirname ${FW_TARGET_DIR}/brcm/${fwfile})
            cp -Lv ${PKG_BUILD}/${fwfile} ${FW_TARGET_DIR}/brcm/${fwfile}
        else
          echo "ERROR: Firmware file ${fwfile} does not exist - aborting"
          exit 1
        fi
      done
    done < ${fwlist}
  done

  mkdir -p $INSTALL/usr/bin
    cp $PKG_DIR/scripts/brcmfmac-firmware-setup $INSTALL/usr/bin
}

post_install() {
  enable_service brcmfmac-firmware.service
}
