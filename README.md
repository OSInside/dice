# Dice

Dice is a simple build service for [KIWI](http://opensuse.github.com/kiwi)
images using virtual instances controlled by vagrant or a directly
contacted build machine. It can be used to fire up build jobs
on e.g public cloud instances.

## Contents

  * [Motivation](#motivation)
  * [Installation](#installation)
  * [Setup](#setup)
    - [Vagrant Virtual Worker System](#vagrant-virtual-worker-system)
    - [Generic Worker System](#generic-worker-system)
    - [Accessing Worker System](#accessing-worker-system)
  * [Dicefile](#dicefile)
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
  * Benefit from prebuild worker boxes by us for virtualbox, libvirt and docker.
  * No need to have kiwi installed on your machine
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

Dice is available as rpm package, installation can be done via
zypper as follows:

```
$ zypper ar \
  http://download.opensuse.org/repositories/Virtualization:/Appliances:/ContainerBuilder/<distribution>/ \
  dice

$ zypper se dice

  select the '.*-rubygem-dice' package listed for the ruby version of
  the distribution
``` 

## Setup

Dice starts a build job on a build worker. The worker machine could be
anything starting from the local system up to a cloud instance at a cloud
service provider, or a local virtual system.

If you don't plan to use virtual systems for building you can skip
the following and head directly to the [Build Worker Generic Machine](#build-worker-generic-machine)
chapter

Building in virtual systems requires the
[vagrant framework](https://docs.vagrantup.com)
which is used by dice to manage instances of virtual machines. In order
to do that vagrant requires a base machine called a box which ships with
all the required software to run an image build. As of today there are
build boxes available for docker, libvirt and virtualbox. This setup guide
explains how to use the docker based platform

[docker](https://www.docker.com) is one out of some other
virtualization/container frameworks supported by vagrant.
Basically dice supports all virtualization frameworks supported by
vagrant. That means it's also possible to run a dice build in kvm using
libvirt as well as VMware, VirtualBox and more. For more
information about these so called providers check out the vagrant
documentation here:

  * https://docs.vagrantup.com/v2/providers/index.html

In order to install vagrant, docker and the base box
for running a build in a virtual system do the following:

### Vagrant Virtual Worker System

  * As user root Install the latest vagrant rpm package from here

    https://www.vagrantup.com/downloads.html

  * As user root Install docker via zypper

    ```
    $ zypper install docker
    ```

    Please make sure that the user who is intended to build images
    is a member of the docker group. The following command requires
    root permissons:

    ```
    $ useradd -G docker builduser
    ```

  * Start dockerd using the btrfs storage backend

    ```
    $ qemu-img create /var/lib/docker-storage.btrfs 20g
    $ mkfs.btrfs /var/lib/docker-storage.btrfs
    $ mkdir -p /var/lib/docker
    $ mount /var/lib/docker-storage.btrfs /var/lib/docker

    $ vi /etc/fstab
    /var/lib/docker-storage.btrfs /var/lib/docker btrfs defaults 0 0

    $ vi /etc/sysconfig/docker
    DOCKER_OPTS="-s btrfs"

    systemctl start docker
    ```

  * As normal user download the .tar.bz2 file which starts with
    Docker-Tumbleweed from here:

    http://download.opensuse.org/repositories/Virtualization:/Appliances:/Images/images

    This box is able to build images for the distributions:

    * RHEL >= 7
    * CentOS >= 7
    * openSUSE Tumbleweed / Leap
    * SLES >= 12

  * As normal user add the box via docker

    ```
    $ cat Docker-Tumbleweed.XXXXXXX.docker.tar.xz |\
      docker import - opensuse/dice:latest
    ```

### Generic Worker System

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
  * a build user e.g vagrant
  * passwordless root access for build user via sudo
  * ssh login as build user with ssh key


## Accessing Worker System

Access to the machine running the build job is performed by the public ssh key
method. Therefore the machine has to have the sshd service running as well as
the public keys of users who are allowed to login stored in the
`~<build_user>/.ssh/authorized_keys` file.

All vagrant capable build worker images provided by us are prepared
to allow access via the __vagrant__ user and the default vagrant
private key. This is done for backward capability with older versions
of vagrant.

The vagrant private key is publicly distributed and therefore __not__ a secure
key ! Current versions of vagrant detects this key and creates a new
key pair which it then inject into the instance. The insecure key will
be removed during that process.

When dice works with vagrant it asks for the generated key and uses
this key for any ssh connection to perform jobs on the instance.
Because of this it's not required to provide a path to the private
key file as part of the Dicefile when working with vagrant worker
systems.

However for generic reachable worker systems the knowledge about the
path to the ssh private key is mandatory. If using the vagrant private
key is acceptable the following steps are required to make the key
available to the user who starts build jobs:

```
$ cd ~<build_user>

$ mkdir -p .dice/key

$ cp -a /usr/share/doc/packages/dice/key/vagrant .dice/key

$ chmod 600 .dice/key/vagrant
```

This key can now be referenced in the dice configuration [DiceFile](#dicefile)
as follows:

```ruby
Dice.configure do |config|
  config.ssh_private_key = File.join(ENV["HOME"], ".dice/key/vagrant")
end
```

By analogy with this process any other than the insecure vagrant private
key can be configured.


# DiceFile

The DiceFile is part of the dice recipe and represents dice specific
configuration parameters such as the user and/or ssh key to use to access
the build worker, as well as the name or ip address of the machine to
contact if no extra virtual machine should be started for a job.

Following parameters can be set in a DiceFile

```ruby
Dice.configure do |config|
  # The build worker machine which should run the build job. If no such
  # information is present dice starts a virtual instance which is
  # configured by an additional VagrantFile. Refer to the vagrant
  # documentation for further details
  config.buildhost = "ip/name"

  # The ssh user name to contact the build worker, default is: vagrant
  config.ssh_user = "vagrant"

  # The ssh private key which belongs to the public key setup in
  # the ssh_user/.ssh/authorized_keys file stored inside of the build
  # worker. Default path is: <dice-install-path>/key/vagrant
  config.ssh_private_key = File.join(ENV["HOME"], ".dice/key/vagrant")
end
```

## Dice it

Given you have imported the vagrant docker build box as described in
[Vagrant Virtual Worker System](#vagrant-virtual-worker-system) you can
start an example build as normal user as follows:

```
$ git clone https://github.com/SUSE/kiwi-descriptions

$ dice build suse/x86_64/suse-leap-42.1-JeOS
```

you can check the progress with


```
$ dice buildlog suse/x86_64/suse-leap-42.1-JeOS
```

