# Static configuration of client network interface

Click on play to launch everything. Then double click on each hosts to get a terminal.
Our interface is supposed to be call eth1 according to the subject, so we are going rename our interface eth0 to eth1

On both hosts:
```
$ ip link set eth0 down # stop interface.
$ ip link set eth0 name eth1 # change the mame of the interface.
$ ip link set eth1 up # start interface back.
```
We can check our interface using:
```
ip a
```
We can now add our ip address:

Client1:
```
$ ip addr add 30.1.1.1/24 dev eth1 # 24 is our mark
``` 
Client2:
```
$ ip addr add 30.1.1.2/24 dev eth1
``` 

Now that our clients ip are registered, we can set up our routers.
Router1:
```
$ ip addr add 10.1.1.1/24 dev eth0
$ ip addr add 30.1.1.3/24 dev eth1
$ ip link add vxlan10 type vxlan id 10 remote 10.1.1.2 dstport 4789 dev eth0
# Adding vxlan interface, going to the other router (10.1.1.2) through eth0
$ ip link set vxlan10 up
# activate vxlan 
$ ip addr add 30.1.1.3/24 dev vxlan10
#give vxlan10 the address of eth1

#Bridge configuration to link eth1 and vxlan10
ip link add name br0 type bridge
#create the bridge br0 
$ ip link set br0 up
# activate the bridge
$ ip link set vxlan10 master br0
# adding vxlan10 interface to the bridge
$ ip link set eth1 master br0
# adding eth1 interface to the bridge
```
Router2:
```
$ ip addr add 10.1.1.2/24 dev eth0
$ ip addr add 30.1.1.3/24 dev eth1
$ ip link add vxlan10 type vxlan id 10 remote 10.1.1.1 dstport 4789 dev eth0
# Adding vxlan interface, going to the other router (10.1.1.1) through eth0
$ ip link set vxlan10 up
# activate vxlan 
$ ip addr add 30.1.1.3/24 dev vxlan10

# Bridge configuration to link eth1 and vxlan10
ip link add name br0 type bridge
# create the bridge br0 
$ ip link set br0 up
# activate the bridge
$ ip link set vxlan10 master br0
# adding vxlan10 interface to the bridge
$ ip link set eth1 master br0
# adding eth1 interface to the bridge
```

We can now test the set up using ifconfig and ping
```
$ ifconfig eth1
$ ping 30.1.1.2
```

#Dynamic ip aka Multicast set up with vxlan

Router1:
```
$ ip addr add 10.1.1.1/24 dev eth0
$ ip addr add 30.1.1.3/24 dev eth1
$ ip link add vxlan10 type vxlan id 10 dstport 4789 group 239.1.1.1 dev eth0 ttl auto
# Same group address shown in the subject
$ ip link set up dev vxlan10
$ ip addr add 30.1.1.3/24 dev vxlan10
$ brctl addbr br0
$ ip link set dev br0 up
$ brctl addif br0 vxlan10
$ brctl addif br0 eth1
```

Router2:
```
$ ip addr add 10.1.1.2/24 dev eth0
$ ip addr add 30.1.1.3/24 dev eth1
$ ip link add vxlan10 type vxlan id 10 dstport 4789 group 239.1.1.1 dev eth0 ttl auto
# Same group address shown in the subject
$ ip link set up dev vxlan10
$ ip addr add 30.1.1.3/24 dev vxlan10
$ brctl addbr br0
$ ip link set dev br0 up
$ brctl addif br0 vxlan10
$ brctl addif br0 eth1
```

Let's check if it worked, we should have a group

```
$ ip -d link show vxlan10
```

and dispay our mac address table:

```
$ brctl showmacs br0
```
