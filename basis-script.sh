#!/bin/bash

set -x

case $1 in
  create-vm)    #create VM
        uvt-kvm create $2 release=bionic
	uvt-kvm wait $2
        ;;

  remove-vm)    #destroy VM
        uvt-kvm destroy  $2 
        ;;

  reset-vm)
	uvt-kvm ssh $2 "sudo init 6"
	;;

  create-bridge)    #create bridge
        printf  "<network>
                  <name>$2</name>
                  <bridge name='$2' stp='on' delay='0'/>
                    <forward mode = 'route' />
                  <ip address='$3' netmask='$4'>
                    <dhcp>
                      <range start='$5' end='$6'/>
            </dhcp>
                  </ip>
                </network>"              >> $2.xml

        virsh net-define $2.xml
        virsh net-start $2
        virsh net-autostart $2
        ;;

  configure-interface)    #VM interface
        if [[ $3 -eq 7 ]]
        then
		uvt-kvm ssh $2 'sudo apt-get install ifupdown'
		uvt-kvm ssh $2 "sudo chmod  777 /etc/network/interfaces"

		uvt-kvm ssh $2 "sudo echo        >> /etc/network/interfaces"
		uvt-kvm ssh $2 "sudo echo auto lo >> /etc/network/interfaces"
		uvt-kvm ssh $2 "sudo echo iface lo inet loopback >> /etc/network/interfaces"

		uvt-kvm ssh $2 "sudo echo        >> /etc/network/interfaces"
		uvt-kvm ssh $2 "sudo echo auto ens3 >> /etc/network/interfaces"
		uvt-kvm ssh $2 "sudo echo iface ens3 inet dhcp >> /etc/network/interfaces"
	fi
	uvt-kvm ssh $2 "sudo echo        >> /etc/network/interfaces"
	uvt-kvm ssh $2 "sudo echo auto ens$3 >> /etc/network/interfaces"
	uvt-kvm ssh $2 "sudo echo iface ens$3 inet dhcp >> /etc/network/interfaces"
	uvt-kvm ssh $2 "sudo mv /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.unused"
	;;

  
  attach-interface)    #attach interface to the bridge
	virsh attach-interface --domain $2 --type network --source $3 --mac $4 --model virtio --config --live
        ;;
  6)    #detach -interface
        virsh detach-interface --domain $2 --type network --mac $3 --config
        ;;

  add-dhcp)    #add a dhcp static host entry to the network
        virsh net-update $2 add ip-dhcp-host \
          "<host mac='$3' \
           ip='$4' />" \
           --live --config
        ;;

  enable-ip-forwarding)    #enable ip forwarding
        uvt-kvm ssh $2 "sudo  chmod 777 /etc/sysctl.conf"
        uvt-kvm ssh $2 "sudo echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf"
        uvt-kvm ssh $2 "sudo /etc/init.d/procps restart"
        ;;

  add-route) # add route, danger: acts on the last interface!
	uvt-kvm ssh $2 "sudo echo post-up ip route add $3 via $4 dev ens$5 >> /etc/network/interfaces"
	;;

  delete-bridge)    #delete bridge
        # sudo ifconfig $2 down
        # sudo brctl delbr $2
        virsh net-destroy $2
        virsh net-undefine $2
        rm $2.xml
        ;;


esac
