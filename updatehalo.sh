#!/usr/bin/env bash


rpm -qa | grep gluster
#must change all the values below

systemctl stop glusterd

rpm -e glusterfs-server-3.12.6-1.el7.x86_64

rpm -e glusterfs-fuse-3.12.6-1.el7.x86_64
rpm -e glusterfs-api-3.12.6-1.el7.x86_64

rpm -e glusterfs-3.12.6-1.el7.x86_64
rpm -e glusterfs-libs-3.12.6-1.el7.x86_64  glusterfs-client-xlators-3.12.6-1.el7.x86_64 glusterfs-cli-3.12.6-1.el7.x86_64



yum localinstall glusterfs-libs-3.12.7-0.3.git9edc5be24.el7rhgs.x86_64.rpm -y
yum localinstall glusterfs-cli-3.12.7-0.3.git9edc5be24.el7rhgs.x86_64.rpm -y
yum localinstall glusterfs-client-xlators-3.12.7-0.3.git9edc5be24.el7rhgs.x86_64.rpm -y
yum localinstall glusterfs-3.12.7-0.3.git9edc5be24.el7rhgs.x86_64.rpm -y
yum localinstall glusterfs-api-3.12.7-0.3.git9edc5be24.el7rhgs.x86_64.rpm -y
yum localinstall glusterfs-fuse-3.12.7-0.3.git9edc5be24.el7rhgs.x86_64.rpm -y
yum remove userspace-rcu-0.10.0-3.el7.x86_64 -y
yum localinstall glusterfs-server-3.12.7-0.3.git9edc5be24.el7rhgs.x86_64.rpm -y

systemctl start glusterd


