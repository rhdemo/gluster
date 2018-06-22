# Federated Gluster - A single volume spread over 3 cloud providers
### The notes and scripts contained within this repo provide the basic info needed to setup up a single volume that stretches across 3 cloud providers.

## Steps
- Setup VMs in each cloud environment
- Setups storage disks
- Prepare disks
- Create Stretch or federeated volume
- Install gluster-swift for object storage 
- (Optional) Install swift browser to view data in volume

### Setup VMs
- Always `sudo su` to root 
- On each cloud provider, create 3 VMs with at least 8GB RAM and 2 CPUs.  We have used RHEL 7.4 as the OS but the latest version of CentOS 7 should work as well.
- The 3 cloud providers used for this demo include GCP, AWS, and Azure.  There are scripts and CLI tools to make the setup more automated, but you can simply use each cloud provider's Web UI to make your machines.
- At minimum, you should install wget, git, and docker on the VMs
- Add the repo for the 3.12 version of glusterd, there are some example scripts in the install_instructions.sh

rpm --import https://raw.githubusercontent.com/CentOS-Storage-SIG/centos-release-storage-common/master/RPM-GPG-KEY-CentOS-SIG-Storage

cat > /etc/yum.repos.d/gluster.repo <<END_TEXT
[centos-gluster312]
name=CentOS-7- Gluster 3.12
baseurl=http://mirror.centos.org/centos/7/storage/x86_64/gluster-3.12/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage
END_TEXT

- yum install glusterfs-server -y
- Turn off firewall or if you want to be safer, open proper ports for gluster which you can find in the gluster manual
- systemctl stop firewalld; iptables -F
- Create an ssh-key and setup the /etc/hosts file so passwordless ssh can occur from your designated "master" machine (this can be any of the VMs, just pick one and always use it)
- Update ssh config for passwordless root:
`sed -i~ '2iPermitRootLogin without-password' /etc/ssh/sshd_config
 sed -i~ '3iPubkeyAuthentication yes' /etc/ssh/sshd_config
 systemctl restart sshd`

- Copy pub key you generated to each VMs authorized_hosts file:
`cat ~/.ssh/id_ras.pub
copy to (if ssh directory does not exist, do a quick sssh-keygen on that VM)
vi ~/.ssh/authorized_keys and paste in the pub key from master`

-Configure /etc/hosts and assign each instance a shorthand name to its external IP. E.g.:
 
 For some reason, glusterd does not like accessing a host via its own external ip. This means that for each node, append the hostname to the localhost line. E.g.
 
 
 127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 gce-node1
 ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
 10.128.0.5 preserve-jcope-rhs-7nvd.c.openshift-gce-devel.internal preserve-jcope-rhs-7nvd  # Added by Google
 169.254.169.254 metadata.google.internal  # Added by Google
 
 35.202.110.25    gce-node2
 52.90.27.26      aws-node1
 54.147.233.113   aws-node2
 102.134.12.123   azr-node1

### Setup disks
- At minimum, you will need a 100GB SSD drive on each VM.  We used 4 100GB SSD drives per VM giving us 36 disks to create our volume
- Note on Azure, we had to use 1 TB to get fast enough iops

### Prepare Disks
- These are the basic steps
- `lsblk` to get the disk name
- `fdisk <disk_name>` i.e. `fdisk /dev/sdb`
- at fsdisk prompt: new partition (n, accept all defaults), write to disk (w).
- mkfs.xfs -i size=512 <disk_partition> i.e. `mkfs.xfs -i size=512 /dev/sdb1`
- `mkdir -p /data/brick1`
- echo '<disk_partition>  /data/brick1 xfs loop,inode64,noatime,nodiratime 0 0' >> /etc/fstab
- `mount -a && mount` (this should have no errors)

### Create Volume
- Once passwordless ssh is setup, you should connect to all VMs from your designated master (again, master can be any VM)
- Now use peer probe command to connect gluster on all the VMs using the names you setup in the /etc/hosts file
- i.e. `peer probe aws-node2` or `peer probe azr-node3` or whatever you named them
- Do the peer probe for all VMs
- `peer probe status` should show you connect to 8 nodes when you are done
- TROUBLESHOOTING: if peer probe is not working you may need to manually start glusterd: `systemctl start glusterd`
- Create volume using replica three.  This is an example assuming you have created a 12x3 gluster cluster:
gluster volume create gv0 replica 3 \ 
aws-storage1:/data/brick1/gv0 azr-storage1:/data/brick1/gv0 gce-storage-west1:/data/brick1/gv0 \
aws-storage1:/data/brick2/gv0 azr-storage1:/data/brick2/gv0 gce-storage-west1:/data/brick2/gv0 \
aws-storage1:/data/brick3/gv0 azr-storage1:/data/brick3/gv0  gce-storage-west1:/data/brick3/gv0 \
aws-storage1:/data/brick4/gv0 azr-storage1:/data/brick4/gv0 gce-storage-west1:/data/brick4/gv0 \
aws-storage2:/data/brick1/gv0 azr-storage2:/data/brick1/gv0 gce-storage-west2:/data/brick1/gv0 \
aws-storage2:/data/brick2/gv0 azr-storage2:/data/brick2/gv0 gce-storage-west2:/data/brick2/gv0 \
aws-storage2:/data/brick3/gv0 azr-storage2:/data/brick3/gv0  gce-storage-west2:/data/brick3/gv0 \
aws-storage2:/data/brick4/gv0 azr-storage2:/data/brick4/gv0 gce-storage-west2:/data/brick4/gv0 \
aws-storage3:/data/brick1/gv0 azr-storage3:/data/brick1/gv0  gce-storage-west3:/data/brick1/gv0 \
aws-storage3:/data/brick2/gv0 azr-storage3:/data/brick2/gv0 gce-storage-west3:/data/brick2/gv0 \
aws-storage3:/data/brick3/gv0 azr-storage3:/data/brick3/gv0 gce-storage-west3:/data/brick3/gv0 \
aws-storage3:/data/brick4/gv0 azr-storage3:/data/brick4/gv0 gce-storage-west3:/data/brick4/gv0 \

### Setup gluster-swift
- Here just use the script in the install_instructions.sh function called init-swift()
- Then run the script in the install_instructions.sh function called init-configs()

### Setup swift-browser (optional)
- See the rhdemo/django-swiftbrowser repo for instructions

### Test your storage and proxy connection
- Create a bucket:
`curl -i -X PUT -H "X-Auth-Token:ANYVALUEHERE" http://localhost:8080/v1/AUTH_gv0/mybucket`
- Add file to the bucket
`touch test1.txt`
`curl -v -X PUT  -H "X-Auth-Token: ANYVALUEHERE" -T test1.txt http://localhost:8080/v1/AUTH_gv0/mybucket/test1.txt`













Installing Gluster
This can be done before or after prepping the blocks.

Configure /etc/hosts and assign each instance a shorthand name to its external IP. E.g.:

For some reason, glusterd does not like accessing a host via its own external ip. This means that for each node, append the hostname to the localhost line. E.g.


127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 gce-node1
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.128.0.5 preserve-jcope-rhs-7nvd.c.openshift-gce-devel.internal preserve-jcope-rhs-7nvd  # Added by Google
169.254.169.254 metadata.google.internal  # Added by Google

35.202.110.25    gce-node2
52.90.27.26      aws-node1
54.147.233.113   aws-node2



