# Dice

!!! code under development, not yet ready for use !!!

dice is a simple build system for [KIWI](http://opensuse.github.com/kiwi)
images using virtual instances controlled by vagrant or a directly
contacted build machine. It can be used to fire up build jobs properly
processed on e.g a cloud instance.

## Contents

  * [Motivation](#motivation)
  * [Setup](#setup)
    - [VirtualBox](#virtualbox)
    - [Vagrant](#vagrant)
  * [Installation](#installation)
  * [Usage](#usage)

## Motivation

Given there is the need to build an appliance for a customer, one wants
to keep track of the updates from the distribution and software vendors
according to the components used in the appliance. This leads to a
regular rebuild of that appliance which should be automatically triggered
whenever the repository which stores all the software packages has
changed.

With Dice there is a tool which automatically builds all appliances
stored in a directory. Advantages of Dice are:

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

### VirtualBox

dice uses vagrant to manage instances of virtual systems. All
vagrant supported virtualization backends can be used with dice.
As of today there are build boxes available for libvirt and virtualbox.
This setup guide explains how to use the virtualbox based platform

  * Install the package 'virtualbox >= v4.3' and it's requirements via zypper

### Vagrant

  * Install the latest vagrant rpm package from here

    https://www.vagrantup.com/downloads.html

  * download the kiwi base box from here:

    http://download.opensuse.org/repositories/Virtualization:/Appliances/images/VagrantBox-openSUSE-13.1.x86_64-1.13.1.virtualbox-Build13.1.box

  * add the box via vagrant

    ```
    vagrant box add kiwi-13.1-build-box \
      VagrantBox-openSUSE-13.1.x86_64-1.13.1.virtualbox-Build13.1.box
    ```

## Installation

TODO

## Usage

    $ dice --descriptions path
