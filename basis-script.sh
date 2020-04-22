#!/bin/bash
case $1 in
  1)    #create VM
        uvt-kvm create $2;;

  2)    #destroy VM
        uvt-kvm destroy  $2;;

  3)    #create bridge
        printf  "<network>
                  <name>$2</name>
                  <bridge name='$2' stp='on' delay='0'/>
                  <ip address='$3' netmask='$4'>
                    <dhcp>
                      <range start='$5' end='$6'/>
                        <host mac='$7' ip='$8'/>
                        <host mac='$9'  ip='${10}'/>
                    </dhcp>
                  </ip>
                </network>"              >> $2.xml

        virsh net-define $2.xml
        virsh net-start $2
        virsh net-autostart $2;;

  4)    #VM interface
        uvt-kvm ssh $2 'sudo apt-get install ifupdown'
        uvt-kvm ssh $2 "sudo chmod 777 /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo auto ens7 >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo iface ens7 inet dhcp >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo        >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo auto lo >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo iface lo inet loopback >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo        >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo iface ens7 inet dhcp >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo        hwaddress ether $3 >> /etc/network/interfaces"
        ;;

  5)    #attach interface to the bridge
        sudo virsh attach-interface --domain $2 --type bridge --source $3 --model virtio $
        ;;

  6)    #delete bridge
        sudo ifconfig $2 down
        sudo brctl delbr $2
        sudo virsh net-destroy $2
        sudo virsh net-undefine $2
        ;;
esac
