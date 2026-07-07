Here is a practical **step-by-step lab plan** for a   demo of OpenStack using **Windows 11 Pro as the host** and **VirtualBox + Ubuntu + DevStack** inside one VM.[1][2]

## Lab goal
Show  the main OpenStack services in a live, working setup: **Keystone, Glance, Nova, Neutron, Cinder, and Horizon**.[2][1]
The safest and simplest teaching model is a **single-node DevStack installation in one Ubuntu VM** rather than a multi-node deployment.[1][2]

For DevStack on VirtualBox, choose Ubuntu Server 24.04 LTS, not Ubuntu Desktop. DevStack’s own docs recommend starting from a clean, minimal install, and Ubuntu 24.04 (Noble) is the most tested release.

Here is the official Ubuntu Server download page for VirtualBox: [Ubuntu Server download](https://ubuntu.com/download/server).[1]

For your DevStack lab, download the **Ubuntu Server 24.04.4 LTS** ISO from that page, then attach the ISO to the VirtualBox VM when creating the machine.



## 1) Host machine setup
- Install the latest VirtualBox on Windows 11 Pro.
- Keep enough free resources: at least 16 GB RAM on the host is better, because the VM should get 8 GB if possible.
- Download an Ubuntu Server ISO for the guest VM.
- Use a fresh Linux installation, because DevStack documentation recommends a fresh system.[2]

## 2) VirtualBox VM settings
Create one VM called, for example, **OpenStack-Lab**.

Recommended VM settings:
- **Type:** Linux.
- **Version:** Ubuntu 64-bit.
- **CPU:** 2 cores or more.
- **Memory:** 8 GB if possible, minimum 4 GB for a tiny lab.[3][1]
- **Disk:** 50 GB or more, dynamically allocated.

## 3) VirtualBox network settings
Use **two adapters** so the VM gets internet access and can also be reached from the Windows host.[4][5]

### Adapter 1
- Enable Adapter 1.
- **Attached to:** NAT.
- Purpose: internet access for package installation and updates.[5][4]

### Adapter 2
- Enable Adapter 2.
- **Attached to:** Host-only Adapter.
- Choose or create a host-only network such as `vboxnet0`.
- Purpose: stable access from Windows host to OpenStack services and Horizon.[6][4][5]

### Host-only adapter IP plan
A common pattern is to give the VM a static IP on the host-only network, for example:
- Host Windows machine: `192.168.56.1`
- VM host-only IP: `192.168.56.10`

This makes it easy to open the Horizon dashboard from the host browser.[4][6]

## 4) Install Ubuntu in the VM
Install Ubuntu Server with a normal minimal setup.  
During installation, you can keep networking simple and then configure the second adapter after the first boot if needed.  
After boot, update the system and install basic tools like `git`.[1][2]

## 5) Configure the network inside Ubuntu
Check the interface names first, usually something like `enp0s3` for NAT and `enp0s8` for host-only.[4]
A typical netplan setup looks like this:
```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      dhcp4: true
```
For a teaching lab, DHCP on both adapters is acceptable at first; later you can make the host-only side static for easier access.[4]

## 6) Prepare the stack user
DevStack should run as a non-root user named `stack`.[7][3]
Use commands like:
```bash
sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
```
This matches the usual DevStack setup flow.[3][7]

## 7) Download DevStack
Log in as the `stack` user and clone DevStack:
```bash
su - stack
git clone https://opendev.org/openstack/devstack
cd devstack
```
DevStack documentation supports a single-VM all-in-one deployment for learning and testing.[2][1]

## 8) Create local.conf
Create `local.conf` and set passwords plus the host IP.  
A simple example for a single VM is:
```ini
[[local|localrc]]
ADMIN_PASSWORD=password
DATABASE_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
HOST_IP=192.168.56.10
```
Use the VM’s host-only IP as `HOST_IP` so you can reach OpenStack services from the Windows host.[1][4]

## 9) Run DevStack
Start the install with:
```bash
./stack.sh
```
This installs and configures the main OpenStack components, including the dashboard.[2][1]
The first run takes time, so it is best to do this before the class starts.

## 10) Verify the demo
After installation:
- Open Horizon from the Windows host browser using the VM’s host-only IP.
- Log in with the admin credentials from `local.conf`.
- Show Projects, Images, Instances, Networks, Routers, and Volumes.[1][2]

## 11) Suggested classroom demo flow
1. Show what OpenStack is.
2. Open Horizon login page.
3. Explain **Keystone** as identity.
4. Show **Glance** images.
5. Launch a VM with **Nova**.
6. Show networking with **Neutron**.
7. Show storage with **Cinder**.
8. Explain how these services work together.[2][1]
## 12) Video Resources


Installing VirtualBox and Ubuntu Server - OpenStack Beginners Guide Episode 1
https://www.youtube.com/watch?v=a4su8OLXSvc

Installing OpenStack and Launching an Instance - OpenStack Beginners Guide Episode 2
[Installing OpenStack and Launching an Instance - OpenStack Beginners Guide Episode 2](https://www.youtube.com/watch?v=ahbI65MauO4)


## Best recommendation
For a   demo, I recommend **VirtualBox on Windows 11 Pro with one Ubuntu Server VM and DevStack all-in-one**.[1][2]
That setup is simpler, faster to recover, and easier to explain than a downloaded prebuilt image unless you already trust and understand that image.[8][2][1]


Sources
[1] All-In-One Single VM — DevStack documentation https://docs.openstack.org/devstack/latest/guides/single-vm.html
[2] All-In-One Single Machine — DevStack documentation https://docs.openstack.org/devstack/latest/guides/single-machine.html
[3] #OSATH Deploy OpenStack: DevStack https://es.slideshare.net/slideshow/deploy-openstack-devstack/28272061
[4] Minimal DevStack in a VirtualBox VM for Keystone https://gist.github.com/markus-hentsch/b0f7315a9ad6f5dc8621727056df275e
[5] Install OpenStack Private Cloud https://net702sinharanmit.home.blog/2020/02/29/openstack/
[6] ¿Cuál es la correcta configuración de la red para un devStack máquina virtual (virtualbox)? https://www.enmimaquinafunciona.com/pregunta/17844/cual-es-la-correcta-configuracion-de-la-red-para-un-devstack-maquina-virtual-virtualbox
[7] All-In-One Single Machine https://docs.openstack.org/devstack/rocky/guides/single-machine.html
[8] Setup DevStack in VirtualBox https://medium.com/@shuvamkumarsk1/setup-devstack-in-virtualbox-e09d9f9e2d84
[9] Cloud e Datacenter Networking http://wpage.unina.it/rcanonic/didattica/dcn/lucidi/DCN-L09-b-OpenStack-Tour.pdf
[10] Swift/DevstackSetupForKeystoneV3 https://wiki.openstack.org/wiki/Swift/DevstackSetupForKeystoneV3
[11] OpenStack-DevStack all-in-one setup for VirtualBox host ... - GitHub https://github.com/BorisDundakov/OpenStack-DevStack

---

# PowerShell Commands to check IP adress

Use `Get-NetIPConfiguration` for the quick view, and `Get-NetIPAddress` if you want the IP details only. For the full subnet mask in dotted format, `ipconfig /all` is still the simplest command in PowerShell.[1][2]

## Useful commands
```powershell
Get-NetIPConfiguration
Get-NetIPAddress
Get-NetAdapter
ipconfig /all
```

## What each one shows
- `Get-NetIPConfiguration` shows the adapter, IPv4 address, gateway, and DNS settings in a readable format.[2][1]
- `Get-NetIPAddress` shows assigned IP addresses and prefix length, which is useful for the subnet size.[3][4]
- `ipconfig /all` shows the classic Windows network details, including subnet mask, default gateway, and DNS servers.[5][2]

## If you want one adapter only
```powershell
Get-NetIPConfiguration -InterfaceAlias "Ethernet"
Get-NetIPAddress -InterfaceAlias "Ethernet"
ipconfig /all
```

## For VirtualBox
If your host adapter name is different, replace `"Ethernet"` with the actual adapter name from `Get-NetAdapter`. That is often the easiest way to identify the host IP you will use for bridging or host-only networking.[1][5]

