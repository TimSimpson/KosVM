KallistiOS (KOS) Install Helper
===============================

This project makes building the Dreamcast operating KallistiOS dead simple.


Windows Instructions
--------------------

1. Download the Cygwin installer, 'setup-x86.exe', to some temp directory.

2. Now open the Windows command prompt, and run the following:

.. code:: shell

    setup-x86.exe --quiet-mode --packages gcc-core,gcc-g++,make,bison,flex,libelf0-devel,ELFIO,texinfo,git,wget,sed,lyx,patchutils,libiconv

If you haven't installed Cygwin yet, it may show you a GUI. Just click "next"
for every option and the packages listed above should install. Just to be sure,
you may wish to run the command above again after installing Cygwin the first
time.

3. Open up a Cygwin shell and run "Ubuntu / Debian Instructions" below:


Ubuntu / Debian Instructions
----------------------------

1. Download and run "install_kos.sh".


Vagrant VM Instructions
-----------------------

Execute "vagrant up", then "vagrant ssh" into the machine.
Inside the VM, run "/vagrant/install_kos.sh".


Afterwards
----------

.. code:: bash

    $ source ~/Tools/dreamcast/environ.sh
    $ cd ~/Tools/dreamcast/KallistiOS/examples/dreamcast/pvr/pvr_mark_strips_direct
    $ make
