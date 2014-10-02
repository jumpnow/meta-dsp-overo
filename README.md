This layer depends on:

        URI: git://git.yoctoproject.org/poky.git
        branch: daisy
        revision: HEAD
        commit: a4d8015

        URI: git://git.openembedded.org/meta-openembedded
        branch: daisy
        revision: HEAD
        commit: 66c2cf40

        URI: git://git.yoctoproject.org/meta-ti
        branch: daisy
        revision: HEAD
        commit: df04699

        meta-dsp-overo layer maintainer: Scott Ellis <scott@jumpnowtek.com>


Instructions for using this layer can be found at [jumpnowtek.com][overo-yocto-build]

The changes are in this section and below of that *howto*.

### NOTE: 32-bit vs 64-bit build workstation

The TI tools require 32-bit libraries on the build machine.
With previous versions of Ubuntu, 32-bit compat libraries were
available for 64-bit systems. As of Ubuntu 14.04 this is no
longer the case. It's not impossible to install 32-bit compat
libaries on a 64-bit Ubuntu system, but I'm not going to document
that here. It's easiest to just use a 32-bit system. A VM will
work. 

#### Clone the meta-overo repository

Instead of creating a `~/overo` directory, I'm using `~/dsp-overo` for
this repo.

Whenever `meta-overo` is referenced in that *howto*, use `meta-dsp-overo`.

Also, wherever the `[dora]` branch is referenced, substitute `[daisy]`.

There is also another dependency, the *meta-ti* layer hosted by the
Yocto project.

The modified instructions are

Checkout the *meta-ti* layer in the `~/poky-daisy` directory.

    scott@hex:~/poky-daisy$ git clone -b daisy git://git.yoctoproject.org/meta-ti 

Create a subdirectory for the `meta-dsp-overo` repository before cloning

    scott@hex:~/poky-daisy$ cd ..
    scott@hex:~$ mkdir dsp-overo
    scott@hex:~$ cd dsp-overo

    scott@hex:~/dsp-overo$ git clone git://github.com/jumpnow/meta-overo
    scott@hex:~/dsp-overo$ cd meta-dsp-overo
    scott@hex:~/dsp-overo/meta-dsp-overo$ git checkout -b daisy origin/daisy
    scott@hex:~/dsp-overo/meta-dsp-overo$ cd ..


When it comes time to build an image, build the `dsp-image` found here 

    meta-dsp-overo/images/dsp-image.bb

#### C6000 compiler

When you go to build the `dsp-image` eventually you'll get an error like
this

    ERROR: Function failed: Fetcher failure for URL: 'http://install.source.dir.local/ti_cgt_c6000_7.2.7_setup_linux_x86.bin;name=cgt6xbin'. Unable to fetch URL from any source

What you have to do is manually download the C6000 DSP compiler from
the [TI downloads page][ti-download] after some registration. 

You want the Linux version of the `7.2.7` compiler.

Place it in your `DL_DIR` and add a *done* file.

    scott@dual:~$ ls -l /oe-sources/ti_cgt*
    -rw-rw-r-- 1 scott scott 203234908 Jun  5 20:49 /oe-sources/ti_cgt_c6000_7.2.7_setup_linux_x86.bin

    scott@dual:~$ touch /oe-sources/ti_cgt_c6000_7.2.7_setup_linux_x86.bin.done

    scott@dual:~$ ls -l /oe-sources/ti_cgt*
    -rw-rw-r-- 1 scott scott 203234908 Jun  5 20:49 /oe-sources/ti_cgt_c6000_7.2.7_setup_linux_x86.bin
    -rw-rw-r-- 1 scott scott         0 Jul  4 16:28 /oe-sources/ti_cgt_c6000_7.2.7_setup_linux_x86.bin.done


#### Copying the binaries to an SD card

Using the copy scripts in `meta-dsp-overo/scripts` and explained in the 
[howto] [overo-yocto-build], copy the image to the SD card

    scott@hex:~/dsp-overo/meta-dsp-overo$ ./copy_boot.sh sdd
    ...
    scott@hex:~/dsp-overo/meta-dsp-overo$ ./copy_rootfs.sh sdd dsp dsp-overo
    ...


#### Initialization

When you boot the image the first time, you'll want to set some kernel 
parameters in u-boot for the DSP.

Stop u-boot and first clear the existing environment stored in NAND

    Overo # nand erase 240000 20000

Power off, power on an stop again in u-boot. Now you are using the default
environment built into the new version of u-boot.

Set aside some memory for the DSP

    Overo # setenv optargs mem=96M@0x80000000 mem=384M@0x88000000
    Overo # saveenv

And finish booting

    Overo # boot

At the end of the kernel boot you should see the DSP modules getting loaded

    ... 
    Loading kernel modules for gstreamer-ti...
    Running /usr/share/ti/gst/omap3530/loadmodules.sh[    6.773712] CMEMK module: built on Jul  4 2014 at 16:44:11
    [    6.779815]   Reference Linux version 3.5.7
    [    6.784393]   File /home/scott/dsp-overo/build/tmp/work/overo-poky-linux-gnueabi/ti-linuxutils/1_2_26_01_02-r0e/linuxutils_2_26_01_02/packages/ti/sdo/linuxutils/cmem/src/module/cmemk.c
    [    6.805084] CMEM Range Overlaps Kernel Physical - allowing overlap
    [    6.811889] CMEM phys_start (0x86300000) overlaps kernel (0x80000000 -> 0x9d300000)
    [    6.820922] allocated heap buffer 0xe1000000 of size 0x53d000
    [    6.827270] cmemk initialized
    [    6.911315] DSPLINK Module (1.65.00.03) created on Date: Jul  4 2014 Time: 16:43:01
    [    6.956848] SDMAK module: built on Jul  4 2014 at 16:44:16
    [    6.962585]   Reference Linux version 3.5.7
    [    6.967407]   File /home/scott/dsp-overo/build/tmp/work/overo-poky-linux-gnueabi/ti-linuxutils/1_2_26_01_02-r0e/linuxutils_2_26_01_02/packages/ti/sdo/linuxutils/sdma/src/module/sdmak.c
      done

    Poky (Yocto Project Reference Distro) 1.5.2 dsp-overo /dev/ttyO2

    dsp-overo login:


The `mt9v032` driver for the *Caspa* camera was previously broken for use with
*gstreamer* because of some missing *V4L ioctls*. I recently added this 
[v4l patch][caspa-v4l-patch] taken from a posting on the Gumstix mailing list.
It may actually work now. I have not dug up a *Caspa* camera to test. 

I have tested the DSP *h.264* encoder using USB webcams.

Plug a webcam into the USB Host port. I used a *Logitech C920*.

    dsp-overo login: root
    root@dsp-overo:~# [  234.330871] usb 1-2: new high-speed USB device number 2 using ehci-omap
    [  234.490570] usb 1-2: New USB device found, idVendor=046d, idProduct=082d
    [  234.498718] usb 1-2: New USB device strings: Mfr=0, Product=2, SerialNumber=1
    [  234.506378] usb 1-2: Product: HD Pro Webcam C920
    [  234.511383] usb 1-2: SerialNumber: BB6C12BF
    [  234.524108] ALSA sound/usb/stream.c:462 2:3:1: add audio endpoint 0x82
    [  234.588714] ALSA sound/usb/stream.c:462 2:3:2: add audio endpoint 0x82
    [  234.652069] ALSA sound/usb/stream.c:462 2:3:3: add audio endpoint 0x82
    [  234.716369] ALSA sound/usb/mixer.c:1212 [5] FU [Mic Capture Switch] ch = 1, val = 0/1/1
    [  234.725006] ALSA sound/usb/mixer.c:866 5:2: cannot get min/max values for control 2 (id 5)
    [  234.733856] ALSA sound/usb/mixer.c:1212 [5] FU [Mic Capture Volume] ch = 1, val = 0/1/1
    [  234.748535] ALSA sound/usb/mixer.c:866 5:2: cannot get min/max values for control 2 (id 5)
    [  234.767730] uvcvideo: Found UVC 1.00 device HD Pro Webcam C920 (046d:082d)
    [  234.778503] input: HD Pro Webcam C920 as /devices/platform/usbhs_omap/ehci-omap.0/usb1/1-2/1-2:1.0/input/input0
    [  234.797485] usbcore: registered new interface driver uvcvideo
    [  234.804626] USB Video Class driver (1.1.1)


On a Linux workstation where you want to view the video, run a gstreamer 
pipeline like this before you start gstreamer on the Gumstix

    gst-launch-0.10 -v udpsrc port=4000 \
        caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H264' \
      ! rtph264depay \
      ! ffdec_h264 \
      ! xvimagesink sync=false

Then on the Gumstix, run a pipeline like this

    gst-launch -e v4l2src device=/dev/video7 \
      ! video/x-raw-yuv, width=640, height=480, framerate=30/1 \
      ! ffmpegcolorspace \
      ! TIVidenc1 codecName=h264enc engineName=codecServer \
      ! rtph264pay pt=96 \
      ! udpsink host=192.168.10.3 port=4000

Where `192.168.10.3` is the workstation IP address. The ports have to match.

I have the gstreamer pipelines in a script

    root@dsp-overo:~# ./start-stream.sh

    (gst-plugin-scanner:291): GLib-GObject-WARNING **: cannot register existing type `GstVorbisDec'

    (gst-plugin-scanner:291): GLib-CRITICAL **: g_once_init_leave: assertion `result != 0' failed

    (gst-plugin-scanner:291): GStreamer-CRITICAL **: gst_element_register: assertion `g_type_is_a (type, GST_TYPE_ELEMENT)' failed
    Setting pipeline to PAUSED ...
    Pipeline is live and does not need PREROLL ...
    Setting pipeline to PLAYING ...
    New clock: GstSystemClock
    [  744.724639] Alignment trap: v4l2src0:src (294) PC=0x4dbc1ed4 Instr=0x14913004 Address=0xb4eab01a FSR 0x001

If you do that, you should see a video window popping up on the workstation.

At 30 fps, the load looks like this on the Gumstix

    top - 12:46:04 up 23 min,  2 users,  load average: 0.46, 0.41, 0.25
    Tasks:  65 total,   1 running,  64 sleeping,   0 stopped,   0 zombie
    Cpu(s): 46.3%us,  8.1%sy,  0.0%ni, 45.6%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
    Mem:    335736k total,    61540k used,   274196k free,     2276k buffers
    Swap:        0k total,        0k used,        0k free,    40788k cached

      PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
      310 root      20   0 49220 7244 4796 S 47.0  2.2   0:33.72 gst-launch-0.10
      320 root      20   0  2356 1080  880 R  0.7  0.3   0:00.42 top
      319 root      20   0     0    0    0 S  0.3  0.0   0:00.08 kworker/0:1       
      ...

Some of the load comes because of the `ffmpegcolorspace` element that is necessary
between webcams and the TI DSP *h.264* codec. Some notes on that can be found
[here][overo-ffmpegcolorspace]. 

If you used this `meta-dsp-overo` layer then that yuv patch was included in the
`gst-plugins-base` that was built.

At 10 fps, the load gets a little better

    top - 12:48:56 up 26 min,  2 users,  load average: 0.25, 0.37, 0.26
    Tasks:  65 total,   1 running,  64 sleeping,   0 stopped,   0 zombie
    Cpu(s): 22.7%us,  7.2%sy,  0.0%ni, 70.1%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
    Mem:    335736k total,    61280k used,   274456k free,     2300k buffers
    Swap:        0k total,        0k used,        0k free,    40788k cached

      PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
      324 root      20   0 48616 6908 4796 S 23.4  2.1   0:13.89 gst-launch-0.10
      333 root      20   0  2356 1076  876 R  0.7  0.3   0:00.32 top
      301 root      20   0  4360 1936 1680 S  0.3  0.6   0:00.39 sshd
      319 root      20   0     0    0    0 S  0.3  0.0   0:00.32 kworker/0:1
      ...

Still quite a load, but the images from the *Logitech C920* are considerably 
nicer then the *Caspa mt9v032* board. Any UVC webcam that can output YUV 
should work the same way. Most webcams provide YUV.

The webcam shows up as `/dev/video7` because `/dev/video0` through `/dev/video6`
are taken by the `mt9v0321` driver and the associated `ISP` pipelines.

If you aren't using the Caspa, you could remove the mt9v032 and ISP drivers
and the the webcam would show up as `/dev/video0`.

I don't really use the Overos this way. I tend to just stream the data off 
Gumstix as `mjpeg` and do the image processing somewhere else. Much less work
for the Gumstix.

I threw  this layer together because someone asked about the DSP on current 
Gumstix Yocto builds. It's not tested very well.

The issues to get this repo working starting from the `meta-overo` repo I 
normally use were the following

1. Inclusion of the *meta-ti* layer, the [daisy] branch.

2. A `TOOLCHAIN_PATH` setting for TI tools in `meta-dsp-overo/conf/machine/overo.conf`.
 
3. The kernel recipes in `meta-overo/recipes/kernel/linux/` have this line
   
    require recipes-kernel/linux/linux-yocto.inc   

   `linux-yocto.inc` ends up appending a name to the kernel and modules
   directory when it builds and packages a kernel.

   When the TI DSP kernel recipes run, they generate the kernel again and a new
   module directory without this appended name. So when you boot, you have two
   kernel `/lib/modules/` directories, but only one is used.

   I didn't bother to try and fix the root cause in the TI recipes. 
   I just grabbed an older `linux.inc` and placed it directly in the 
   `meta-dsp-overo/recipes-kernel/linux` directory and used that.


Another NOTE. I get a kernel Oops the first time I kill the gstreamer pipeline
on the Gumstix. It doesn't seem to be fatal. I can restart the pipeline and get
a good feed still. And the oops doesn't happen when I kill the pipeline after
that first shutdown. I have not investigated.

   
[overo-yocto-build]: http://www.jumpnowtek.com/gumstix/overo/Overo-Systems-with-Yocto.html
[overo-ffmpegcolorspace]: http://www.jumpnowtek.com/gumstix/overo/Overo-ffmpegcolorspace-optimization.html
[ti-download]: http://software-dl.ti.com/codegen/non-esd/downloads/download.htm
[caspa-v4l-patch]: https://github.com/jumpnow/meta-dsp-overo/commit/16e9855760bffc66c48f18e3174ed3704b688e83
