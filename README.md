# Dice

Dice is a simple build service for [KIWI](http://opensuse.github.com/kiwi)
images using virtual instances controlled by vagrant or a directly
contacted build machine. It can be used to fire up build jobs
on e.g public cloud instances.

## Contents

  * [Motivation](#motivation)
  * [Installation](#installation)
  * [Setup](#setup)
    - [Vagrant and VirtualBox](#vagrant-and-virtualbox)
    - [BuildWorker](#buildworker)
  * [Usage](#usage)

## Motivation

Given there is the need to build an appliance for a customer, one wants
to keep track of the updates from the distribution and software vendors
according to the components used in the appliance. This leads to a
regular rebuild of that appliance which should be automatically triggered
whenever the repository which stores all the software packages has
changed.

With Dice there is a tool which allows on demand and/or automatically
building of appliances stored in a directory. Advantages are:

  * Build as normal user
  * Build for different distributions on appropriate worker
  * Setup your own buildsystem and keep control
  * Allow to access the machine which builds your image
  * Self control where the result gets stored

Disadvantages are:

  * It's not a dynamic service which runs as a daemon
  * It's not a management platform providing a web interface
  * It does not provide build resources

That having said, Dice is a light weight static build system. If there
is the need for more please reach out to the
[open build service](https://build.opensuse.org) which provides a web service
also for image building using KIWI.

## Installation

Dice is available as rpm package for the openSUSE 13.1 (x86\_64) distribution.
Installation can be done via zypper as follows:

```
$ zypper ar \
  http://download.opensuse.org/repositories/Virtualization:/Appliances/openSUSE_13.1/ \
  dice

$ zypper in dice
``` 

## Setup

Dice can either run a build job on a build worker machine which could be
anything starting from the local system up to a cloud instance at a cloud
service provider, or it starts a local virtual system and dedicates the
build to this virtual system.

If you don't plan to use virtual systems for building you can skip
the following and head directly to the [BuildWorker](#buildworker)
chapter

Building in virtual systems requires the
[vagrant framework](https://docs.vagrantup.com)
which is used by dice to manage instances of virtual machines. In order
to do that vagrant requires a base machine called a box which ships with
all the required software to run an image build. As of today there are
build boxes available for libvirt and virtualbox. This setup guide
explains how to use the virtualbox based platform

VirtualBox is one out of some other virtualization frameworks supported by
vagrant. Using VirtualBox together with vagrant is the most
simple way to get started which is why this setup guide recommends it.
Basically dice supports all virtualization frameworks supported by
vagrant. That means it's also possible to run a dice build in kvm using
libvirt as well as VMware, containers with docker and more. For more
information about these so called providers check out the vagrant
documentation here:

  * https://docs.vagrantup.com/v2/providers/index.html

In order to install vagrant, VirtualBox and the base box
for running a build in a virtual system do the following:

### Vagrant and VirtualBox

  * As user root Install the latest vagrant rpm package from here

    https://www.vagrantup.com/downloads.html

  * As user root Install virtualbox >= v4.3 via zypper

    ```
    $ zypper ar \
      http://download.opensuse.org/repositories/Virtualization/openSUSE_13.1 \
      virtualbox

    $ zypper install virtualbox
    ```

  * As normal user download the
    VagrantBox-openSUSE-13.1.x86\_64-1.13.1.virtualbox-Build[XX].box file
    from here:

    http://download.opensuse.org/repositories/Virtualization:/Appliances/images

    There are regularly updates on the box which is the reason why Build[XX] is
    a moving target. This box is able to build images for the distributions:

    * RHEL6
    * RHEL7
    * openSUSE 12.3
    * openSUSE 13.1
    * SLES11
    * SLES12

  * As normal user add the box via vagrant

    ```
    $ vagrant box add kiwi-build-box \
      VagrantBox-openSUSE-13.1.x86_64-1.13.1.virtualbox-Build[XX].box
    ```

  * As normal user check if the box was added

    ```
    $ vagrant box list

    kiwi-build-box (virtualbox)
    ```

### BuildWorker

While the vagrant box files already contains all software and configurations
to perform a build, a worker machine might not have it. In order to make a
machine a dice worker the following software and configurations must exist:

  * package kiwi
  * package kiwi-desc-isoboot
  * package kiwi-desc-netboot
  * package kiwi-desc-vmxboot
  * package kiwi-desc-oemboot
  * package rsync
  * package tar
  * package psmisc
  * a build user e.g kiwi
  * passwordless root access for build user via sudo
  * ssh login as build user with ssh key

## Dice it

Given you have imported the vagrant build box as described in
[Vagrant and VirtualBox](#vagrant-and-virtualbox) you can start an
example build as normal user by calling:

```
$ rsync -zavL /usr/share/doc/packages/dice/recipes/suse-13.1-JeOS /tmp

$ mkdir -p ~/.dice/key

$ cp -a /usr/share/doc/packages/dice/key/vagrant ~/.dice/key

$ chmod 600 ~/.dice/key/vagrant

$ dice build /tmp/suse-13.1-JeOS
```
