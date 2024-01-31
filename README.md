Mirror of POLSARPRO V6.0.3 (BIOMASS EDITION) for Linux
======================================================

This repository is a mirror of the PolSARPro software, eventually
patched to build and run on a modern GNU/Linux system. This software can
be built on Debian GNU/Linux 11+ and its derivatives, including Ubuntu
21.4+.

Please, refer to https://ietr-lab.univ-rennes1.fr/polsarpro-bio/ for the
original distribution kit and its documentation, as well as the users
forum at https://forum.step.esa.int/ for support.

In order to install and use this software kit on Debian and derivatives,
it is mandatory to install a few more packages than those listed
in the original documentation.

```
sudo apt install libtk-img iwidgets4 bwidget wget
sudo apt install gcc g++ build-essential libglew-dev
sudo apt install freeglut3-dev libfreeimage-dev

wget https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb
sudo apt install ./google-earth-pro-stable_current_amd64.deb

wget https://download.esa.int/step/snap/9.0/installers/esa-snap_all_unix_9_0_0.sh
chmod a+x ./esa-snap_all_unix_9_0_0.sh
sudo ./esa-snap_all_unix_9_0_0.sh

sudo apt install gimp gnuplot imagemagick 
sudo apt install p7zip-full curl hdf5-tools
```

The Tcl scripts have been patched to use the system wide tools. Note that the
Tk GUI have some glitches in use with some workarounds, I eventually could fix them if there was
enough interest.

I even added a simple shell script `polsarpro.sh` to be run as the preferred way of
using PolSARPro program.

-- Enjoy
