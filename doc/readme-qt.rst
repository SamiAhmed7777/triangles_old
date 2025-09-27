triangles-qt: Qt5 GUI for triangles
===============================

Note: Not all of these instructions are updated yet, so they probably don't work.  
Feel free to update them! ;)

Build instructions
===================

Debian
-------

First, make sure that the required packages for Qt5 development of your
distribution are installed, for Debian and Ubuntu these are:

::

    apt-get install qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools \
        build-essential libboost-dev libboost-system-dev \
        libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev \
        libssl-dev libdb++-dev

then execute the following:

::

    qmake
    make

Alternatively, install Qt Creator and open the `triangles-qt.pro` file.

An executable named `triangles-qt` will be built.


Windows
--------

The most reliable way to build Triangles-Qt on Windows 11 is to use the
Qt 5.15.2 MinGW kit in tandem with MSYS2's MinGW-w64 packages.  The
steps below mirror the workflow documented in ``doc/build-msw.txt`` and
are summarised here for quick reference inside Qt Creator.

1. Install `MSYS2 <https://www.msys2.org/>`_ and launch the **MSYS2 MinGW
   x64** shell.
2. Update the base system and install the toolchain packages:

   ::

        pacman -Syu
        pacman -S --needed \
            mingw-w64-x86_64-toolchain \
            mingw-w64-x86_64-qt5 \
            mingw-w64-x86_64-boost \
            mingw-w64-x86_64-libevent \
            mingw-w64-x86_64-miniupnpc \
            mingw-w64-x86_64-db \
            mingw-w64-x86_64-qrencode \
            git make pkgconf

3. Install Qt 5.15.2 (MinGW 64-bit component) with the Qt Maintenance
   Tool or offline installer.  Configure a Qt Creator kit that uses:

   * ``C:\Qt\5.15.2\mingw81_64\bin\qmake.exe``
   * ``C:\msys64\mingw64\bin\g++.exe`` and ``gdb.exe`` from the MSYS2
     MinGW toolchain

4. Obtain either LibreSSL 3.7+ or OpenSSL 1.0.2u for Windows.  Add its
   ``bin`` directory to the kit's PATH (or set
   ``OPENSSL_INCLUDE_PATH``/``OPENSSL_LIB_PATH`` environment variables)
   so that qmake can discover the headers and libraries.
5. (Optional) If you require Berkeley DB 4.8 for wallet compatibility,
   build it following the instructions in ``doc/build-msw.txt`` and add the
   resulting ``BDB_INCLUDE_PATH``/``BDB_LIB_PATH`` to the kit.
6. Open ``triangles-qt.pro`` in Qt Creator.  In **Projects → Build
   Settings**, add the following *Additional arguments* to **qmake** as
   required:

   ::

        OPENSSL_INCLUDE_PATH="C:/libressl/include" \
        OPENSSL_LIB_PATH="C:/libressl/lib" \
        BDB_LIB_SUFFIX="-4.8"

7. Build the project (``Ctrl`` + ``B``).  Qt Creator will run ``qmake``
   and ``mingw32-make`` using the configured kit and output a
   ``triangles-qt.exe`` inside the build directory.  Run or debug the
   wallet directly from Qt Creator, or use the **Deploy** step to execute
   ``windeployqt`` and stage the required Qt/MinGW runtime DLLs.

These instructions avoid the old dependency archive and ensure all
libraries are sourced from actively maintained distributions.


Mac OS X
--------

- Download and install the `Qt Mac OS X SDK`_. It is recommended to also install Apple's Xcode with UNIX tools.

- Download and install `MacPorts`_.

- Execute the following commands in a terminal to get the dependencies:

::

	sudo port selfupdate
	sudo port install boost db48 miniupnpc

- Open the .pro file in Qt Creator and build as normal (cmd-B)

.. _`Qt Mac OS X SDK`: http://qt.nokia.com/downloads/sdk-mac-os-cpp
.. _`MacPorts`: http://www.macports.org/install.php


Build configuration options
============================

UPNnP port forwarding
---------------------

To use UPnP for port forwarding behind a NAT router (recommended, as more connections overall allow for a faster and more stable triangles experience), pass the following argument to qmake:

::

    qmake "USE_UPNP=1"

(in **Qt Creator**, you can find the setting for additional qmake arguments under "Projects" -> "Build Settings" -> "Build Steps", then click "Details" next to **qmake**)

This requires miniupnpc for UPnP port mapping.  It can be downloaded from
http://miniupnp.tuxfamily.org/files/.  UPnP support is not compiled in by default.

Set USE_UPNP to a different value to control this:

+------------+--------------------------------------------------------------------------+
| USE_UPNP=- | no UPnP support, miniupnpc not required;                                 |
+------------+--------------------------------------------------------------------------+
| USE_UPNP=0 | (the default) built with UPnP, support turned off by default at runtime; |
+------------+--------------------------------------------------------------------------+
| USE_UPNP=1 | build with UPnP support turned on by default at runtime.                 |
+------------+--------------------------------------------------------------------------+

Notification support for recent (k)ubuntu versions
---------------------------------------------------

To see desktop notifications on (k)ubuntu versions starting from 10.04, enable usage of the
FreeDesktop notification interface through DBUS using the following qmake option:

::

    qmake "USE_DBUS=1"

Generation of QR codes
-----------------------

libqrencode may be used to generate QRCode images for payment requests. 
It can be downloaded from http://fukuchi.org/works/qrencode/index.html.en, or installed via your package manager. Pass the USE_QRCODE 
flag to qmake to control this:

+--------------+--------------------------------------------------------------------------+
| USE_QRCODE=0 | (the default) No QRCode support - libarcode not required                 |
+--------------+--------------------------------------------------------------------------+
| USE_QRCODE=1 | QRCode support enabled                                                   |
+--------------+--------------------------------------------------------------------------+


Berkely DB version warning
==========================

A warning for people using the *static binary* version of triangles on a Linux/UNIX-ish system (tl;dr: **Berkely DB databases are not forward compatible**).

The static binary version of triangles is linked against libdb 5.0 (see also `this Debian issue`_).

Now the nasty thing is that databases from 5.X are not compatible with 4.X.

If the globally installed development package of Berkely DB installed on your system is 5.X, any source you
build yourself will be linked against that. The first time you run with a 5.X version the database will be upgraded,
and 4.X cannot open the new format. This means that you cannot go back to the old statically linked version without
significant hassle!

.. _`this Debian issue`: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=621425

Ubuntu 11.10 warning
====================

Ubuntu 11.10 has a package called 'qt-at-spi' installed by default.  At the time of writing, having that package
installed causes triangles-qt to crash intermittently.  The issue has been reported as `launchpad bug 857790`_, but
isn't yet fixed.

Until the bug is fixed, you can remove the qt-at-spi package to work around the problem, though this will presumably
disable screen reader functionality for Qt apps:

::

    sudo apt-get remove qt-at-spi

.. _`launchpad bug 857790`: https://bugs.launchpad.net/ubuntu/+source/qt-at-spi/+bug/857790
