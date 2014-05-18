DESCRIPTION = "A kernel module to measure the irq latency in responding to gpio events"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

inherit module

SRCREV = "${AUTOREV}"
SRC_URI = "git://github.com/scottellis/overo-irqlat.git"

S = "${WORKDIR}/git"

do_compile() {
  unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
  oe_runmake 'KERNELDIR=${STAGING_KERNEL_DIR}'
}

do_install() {
  install -d ${D}${base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/${PN}
  install -m 0644 irqlat${KERNEL_OBJECT_SUFFIX} ${D}${base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/${PN}
}

