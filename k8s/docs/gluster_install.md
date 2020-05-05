Inspired by: (https://www.howtoforge.com/tutorial/high-availability-storage-with-glusterfs-on-ubuntu-1804/)

## All Worker
```bash
echo<<"EOF">>/etc/hosts
192.168.1.20 master
192.168.1.21 w1
192.168.1.22 w2
192.168.1.23 w3
EOF

apt -y install glusterfs-server glusterfs-client
systemctl enable glusterd
systemctl start glusterd
systemctl restart glusterd

mkdir -p /srv/gluster
```

## First Worker
```bash
gluster peer probe w2
gluster peer probe w3

gluster peer status
gluster pool list

gluster volume create mine-vol replica 3 arbiter 1 transport tcp \
  w1:/srv/gluster \
  w2:/srv/gluster \
  w3:/srv/gluster \
  force

gluster volume start mine-vol
gluster volume info mine-vol
```

## All Worker
```bash
mkdir -p /mnt/minecraft
echo "$(hostname -s):/mine-vol /mnt/minecraft glusterfs defaults,_netdev 0 0" >> /etc/fstab
mount -a
```
