This layer depends on:

        URI: git://git.yoctoproject.org/poky.git
        branch: dora
        revision: HEAD
        commit: 0a6f0db 

        URI: git://git.openembedded.org/meta-openembedded
        branch: dora
        revision: HEAD
        commit: ee17367 

        URI: git://github.com/scottellis/meta-ti
        branch: dora
        revision: HEAD
        commit: 87a4bfa

        meta-dsp-overo layer maintainer: Scott Ellis <scott@jumpnowtek.com>


Instructions for using this layer can be found at [jumpnowtek.com][overo-yocto-build]

The changes are in this section and below

### Clone the meta-overo repository

Instead of creating a `~/overo` directory, I'm using `~/dsp-overo` for
this repo.

And when ever `meta-overo` is referenced, use `meta-dsp-overo`.

There is also another dependency on a patched version of the `meta-ti` 
repository at `github/jumpnow`

The new instructions are

Create a subdirectory for the `meta-dsp-overo` repository before cloning

    scott@hex:~/poky-dora$ cd ..
    scott@hex:~$ mkdir dsp-overo
    scott@hex:~$ cd dsp-overo

    scott@hex:~/dsp-overo$ git clone git://github.com/jumpnow/meta-ti
    scott@hex:~/dsp-overo$ cd meta-ti
    scott@hex:~/dsp-overo/meta-ti$ git checkout -b dora origin/dora
    scott@hex:~/dsp-overo/meta-ti$ cd ..

    scott@hex:~/dsp-overo$ git clone git://github.com/jumpnow/meta-overo
    scott@hex:~/dsp-overo$ cd meta-dsp-overo
    scott@hex:~/dsp-overo/meta-dsp-overo$ git checkout -b dora origin/dora
    scott@hex:~/dsp-overo/meta-dsp-overo$ cd ..


When it comes time to build an image, build the `dsp-image`. 

It can be found here.

    meta-dsp-overo/images/dsp-image.bb
 

[overo-yocto-build]: http://www.jumpnowtek.com/gumstix/overo/Overo-Systems-with-Yocto.html

