SUMMARY = "Add TI Gstreamer and DSP support"
HOMEPAGE = "http://www.jumpnowtek.com"
LICENSE = "MIT"

require console-image.bb

PR = "0"

DSP_INSTALL = " \
    gstreamer-ti \
    gst-plugins-base-meta \
    gst-plugins-good-meta \
    gst-plugins-bad-meta \
 "

IMAGE_INSTALL += " \
    ${DSP_INSTALL} \
 "

export IMAGE_BASENAME = "dsp-image"

