## Ubuntu Server

## How to connect to Wifi
If minimal installation without the internet, there will be very less tools installed so we can use `netplan`.


check what devices you have
`ip link`
If you see something starting with wl (like wlan0, wlp2s0), that’s your Wi-Fi interface.

check if netplan exists
`ls /etc/netplan`
create netplan
`sudo nano /etc/netplan/01-wifi.yaml`
add into yaml file
```yaml
network:
  version: 2
  renderer: networkd
  wifis:
    <wlan>:
      dhcp4: true
      access-points:
        "<MySSID>":
          password: "<MyPassword>"
```
apply netplan
`sudo netplan apply`
check if you have a ip
`ip a`
check if working
```bash
sudo apt update
sudo apt install network-manager wireless-tools wpa_supplicant net-tools
```