# Dice

!!! code under development, not yet ready for use !!!

dice is a simple build system for kiwi images using vagrant

## Contents

  * [Setup](#setup)
    - [VirtualBox](#virtualbox)
    - [Vagrant](#vagrant)
  * [Installation](#installation)
  * [Usage](#usage)

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

    vagrant box add kiwi-13.1-build-box VagrantBox-openSUSE-13.1.x86_64-1.13.1.virtualbox-Build13.1.box

## Installation

TODO

## Usage

    $ dice --descriptions path
