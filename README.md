# Dice

!!! code under development, not yet ready for use !!!

dice is a simple build system for [KIWI](http://opensuse.github.com/kiwi)
images using virtual instances controlled by vagrant or a directly
contacted build machine. It can be used to fire up build jobs properly
processed on e.g a cloud instance.

## Contents

  * [Motivation](#motivation)
  * [Setup](#setup)
    - [Vagrant+VirtualBox](#vagrant+virtualbox)
    - [BuildWorker](#buildworker)
  * [Installation](#installation)
  * [Usage](#usage)

## Motivation

Given there is the need to build an appliance for a customer, one wants
to keep track of the updates from the distribution and software vendors
according to the components used in the appliance. This leads to a
regular rebuild of that appliance which should be automatically triggered
whenever the repository which stores all the software packages has
changed.

With Dice there is a tool which allows on demand and/or automatically
building of appliances stored in a directory. Advantages of Dice are:

  * Setup your own buildsystem and keep control
  * Allow to access the machine which builds your image
  * Self control where the result gets stored

Disadvantages of Dice are:

  * It's not a dynamic service which runs a daemon
  * It's not a management platform providing a web interface
  * It does not provide build resources

That having said, Dice is a light weight static build system. If there
is the need for more please reach out to the
[open build service](http://opensuse.org) which provides a web service
also for image building using KIWI.

## Setup

Dice can either dedicate a build to a build worker machine which could be
anything starting from the local system up to a cloud instance at a cloud
service provider, or it starts a local virtual system and dedicates the
build to this machine.

The latter requires the [vagrant framework](https://docs.vagrantup.com)
which is used by dice to manage instances of virtual machines. In order
to do that vagrant requires a base machine called a box which ships with
all the required software to run an image build. As of today there are
build boxes available for libvirt and virtualbox. This setup guide
explains how to use the virtualbox based platform

VirtualBox is one out of other virtualization frameworks supported by
vagrant. I found Using VirtualBox together with vagrant is the most
simple way to get started which is why I put it in this setup guide.
Basically dice supports all virtualization frameworks supported by
vagrant. That means it's also possible to run a dice build in kvm using
libvirt as well as VMware, containers with docker and more. For more
information about these so called providers check out the vagrant
documentation here:

  * https://docs.vagrantup.com/v2/providers/index.html

If you don't plan to use virtual systems for building you can skip
the following and head directly to the [BuildWorker](#buildworker)
chapter

### Vagrant+VirtualBox

  * As user root Install the latest vagrant rpm package from here

    https://www.vagrantup.com/downloads.html

  * As user root Install virtualbox >= v4.3 via zypper

    ```
    $ zypper install virtualbox
    ```

  * As normal user download the
    VagrantBox-openSUSE-13.1.x86\_64-1.13.1.virtualbox-Build[XX].box file
    from here:

    http://download.opensuse.org/repositories/Virtualization:/Appliances/images

    There are regularly updates on the box which is the reason why Build[XX] is
    a moving target

  * As normal user add the box via vagrant

    ```
    $ vagrant box add kiwi-13.1-build-box \
      VagrantBox-openSUSE-13.1.x86_64-1.13.1.virtualbox-Build[XX].box
    ```

  * As normal user check if the box was added

    ```
    $ vagrant box list
    ```

    should list the following information

    ```
    kiwi-13.1-build-box (virtualbox)
    ```

  * More information about vagrant can be found here:

    https://docs.vagrantup.com


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

## Installation

TODO

## Usage

    $ dice build path
