+++
title = "Unattended updates in Debian"
date = 2020-04-19

[taxonomies]
tags = ["Debian"]
+++

Because Debian is really stable and has high security patching standards, you
should have auto-upgrades on if you are running `stable`.  This is one of the
things that you cannot have with more bleeding edge distros like
[ArchLinux](https://archlinux.org).

Read through [official docs](https://wiki.debian.org/UnattendedUpgrades) in order to set it up now.

TLDR:
```
$ sudo apt-get install unattended-upgrades
$ sudo dpkg-reconfigure -plow unattended-upgrades
$ echo 'APT::Periodic::Enable "1";
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "21";
APT::Periodic::Verbose "2";' | sudo tee /etc/apt/apt.conf.d/02periodic
```

And then to ensure that things are configured somewhat well:
```
$ sudo unattended-upgrade -d
```
