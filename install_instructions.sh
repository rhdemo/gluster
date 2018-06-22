#!/usr/bin/env bash
#Setting up Demo Machine


init-rhel() {

source pw.config
yum install subscription-manager -y
subscription-manager register --username=$RHNUSER --password=$RHNPASS
subscription-manager attach --pool=8a85f9833e1404a9013e3cddf99305e6
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.7-rpms" --enable="rhel-7-fast-datapath-rpms" --enable="rh-gluster-3-for-rhel-7-server-rpms"

rpm --import https://raw.githubusercontent.com/CentOS-Storage-SIG/centos-release-storage-common/master/RPM-GPG-KEY-CentOS-SIG-Storage

cat > /etc/yum.repos.d/gluster.repo <<END_TEXT
[centos-gluster312]
name=CentOS-7- Gluster 3.12
baseurl=http://mirror.centos.org/centos/7/storage/x86_64/gluster-3.12/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage
END_TEXT

subscription-manager repos --disable=rhel-7-server-htb-rpms

yum install wget -y
yum install git docker -y
}


install-gluster() {
    yum install glusterfs-server -y
}


install-ssh() {

systemctl stop firewalld; iptables -F

#<SETUP /etc/hosts>
#vi /etc/hosts
#<SETUP password-less SSH>

sed -i~ '2iPermitRootLogin without-password' /etc/ssh/sshd_config
sed -i~ '3iPubkeyAuthentication yes' /etc/ssh/sshd_config

systemctl restart sshd

#ssh-keygen

#cat ~/.ssh/id_ras.pub

#copy to (if ssh does not exist, do a quick sssh-keygen)
#vi ~/.ssh/authorized_keys

}
#-------------------------------- Blocks ----------------

init-block() {

lsblk
#GCE
# fdisk /dev/sdb
# at fsdisk prompt: new partition (n, accept all defaults), write to disk (w).
# mkfs.xfs -i size=512 /dev/sdb1
# mkdir -p /data/brick1
# echo '/dev/sdb1 /data/brick1 xfs loop,inode64,noatime,nodiratime 0 0' >> /etc/fstab
# mount -a && mount
#AWS
# fdisk /dev/xvdb
# at fsdisk prompt: new partition (n, accept all defaults), write to disk (w).
# mkfs.xfs -i size=512 /dev/xvdb1
# mkdir -p /data/brick1
# echo '/dev/xvdb1 /data/brick1 xfs loop,inode64,noatime,nodiratime 0 0' >> /etc/fstab
# mount -a && mount
#AZURE
# fdisk $1
# at fsdisk prompt: new partition (n, accept all defaults), write to disk (w).
# mkfs.xfs -i size=512 /dev/sdc1
# mkdir -p /data/brick1
# echo '$1 /data/brick1 xfs loop,inode64,noatime,nodiratime 0 0' >> /etc/fstab
# mount -a && mount
}

init-swift() {
yum install openstack-swift-* -y
yum install python-scandir python-prettytable git -y
git clone https://github.com/gluster/gluster-swift; cd gluster-swift
python setup.py install
mkdir -p /etc/swift/; cp etc/* /etc/swift/; cd /etc/swift
for tmpl in *.conf-gluster ; do cp ${tmpl} ${tmpl%.*}.conf; done
yum install python-swiftclient -y
yum install memcached -y
#For security, add -U 0 to OPTIONS in vi /etc/sysconfig/memcached
sed -i '5s/.*/OPTIONS="-U 0"/' /etc/sysconfig/memcached
systemctl start memcached
systemctl enable memcached

wget https://pypi.python.org/packages/source/s/setuptools/setuptools-7.0.tar.gz --no-check-certificate
tar xzf setuptools-7.0.tar.gz;  cd setuptools-7.0
python setup.py install
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install --upgrade requests

git clone https://github.com/openstack/swift3; cd swift3/
sed -i '1s/.*/ /' requirements.txt
sed -i '3s/.*/ /' requirements.txt
python setup.py install

}

init-configs() {
#From wherever you install clone
git clone https://github.com/rhdemo/django-swiftbrowser.git
cd ./conf/
cp account-server.conf container-server.conf proxy-server.conf object-server.conf /etc/swift/.
cp webhook.py /usr/lib/python2.7/site-packages/swift/common/middleware/.
}


init-volume() {
#PEER PROBE?

#Build Volume Examples
#gluster volume create gv0 replica 3 azr-storage4:/data/brick1/gv0 gce-storage-west4:/data/brick1/gv0 storage-aws-node4:/data/brick1/gv0
#gluster volume create gv1 azr-storage4:/data/brick1/gv1
gluster volume start $1

cd /etc/swift; gluster-swift-gen-builders $1
swift-init main start
}

update-uis() {
cat > /root/uihosts.txt <<END_TEXT
aws-node1
aws-node2
storage-aws-node5
azr-storage1
azr-storage2
azr-storage5
gce-storage-west1
gce-storage-west2
gce-storage-west5
END_TEXT


for i in $(cat uihosts.txt); do echo =====$i=====; ssh $i "cd /root/django-swiftbrowser; git pull; ./install-ui.sh"; done

}
