# Intel NUC setup

## Hardware
If you only have one RAM stick, make sure to place it in the top RAM slot.



## Software
Ubuntu Server 18.04 seems to work fine. You might want to disable automatic
upgrades and snap support with:
```
sudo apt purge snapd unattended-upgrades
```



## Sharing Internet connection through Ethernet
Follow steps 1-5 from
[here](https://askubuntu.com/questions/359856/share-wireless-internet-connection-through-ethernet)
for the computer whose connection you want to share to the NUC.

The NUC will now be assigned some IP address using DHCP. To find the NUC's IP
run
```
nmap -sP 10.42.0.1/24
```
on the host computer.

To set a static IP address on the NUC first run `ip a` to see the Ethernet
interface's name. Should be something like `enp0s*`.  Then create the file
`/etc/netplan/01-netcfg.yaml` and paste in the following to set the NUC's IP
address to `10.42.0.2`
``` yaml
network:
    version: 2
    renderer: networkd
    ethernets:
        enp0s31f6:
            dhcp4: no
            addresses: [10.42.0.2/24]
            gateway4: 10.42.0.1
```
Then run
```
sudo netplan apply
```
and reboot the NUC.

