## How to setup AWS VPC access with Wireguard VPN 

To set up AWS VPC access using Wireguard VPN, follow these clearer steps. This method is an alternative to using a jumpbox, which can be vulnerable as it exposes a server to potential attacks.

1. **Create a Wireguard EC2 Instance**:
   - Launch a new EC2 instance to serve as your Wireguard server. Make sure your EC2 instance is of the following: a Debian, Ubuntu, Fedora, CentOS, AlmaLinux, Oracle or Arch Linux system
   - Attach a new security group with the following rules:
     - SSH (port 22) open to 0.0.0.0/0 for initial setup.
     - Custom UDP (port 51280) open to 0.0.0.0/0 for Wireguard traffic.

1. **Assign a Static IP**:
   - Allocate and associate an Elastic IP to your Wireguard EC2 instance. This ensures the server's IP remains constant through reboots.

2. **Install Wireguard**:
   - Access the EC2 instance via SSH and install the Wireguard software.
   - Configure Wireguard as a VPN server.

https://github.com/angristan/wireguard-install/tree/master

3. **Configure Users**:
   - On the Wireguard instance, create user accounts. Each account will generate a unique configuration file necessary for client connections.

4. **Create a Webserver EC2 Instance**:
   - Launch another EC2 instance that will act as your web server.
   - Set up a new security group with the following rules:
     - Allow all traffic from the Wireguard instance's security group. This ensures communication between the Wireguard server and web server.
     - Open HTTP (port 80) to 0.0.0.0/0 for web access.

5. **Update Wireguard Security Group**:
   - Modify the Wireguard instance's security group:
     - Remove SSH access (if no longer needed) for increased security.
     - Allow all traffic from the web server's security group to ensure unrestricted communication within your private network.

6. **Install Wireguard Client**:
   - Install the Wireguard client on your local machine, which will be used to connect to your Wireguard server.

for M1: https://blog.scottlowe.org/2021/06/22/making-wireguard-from-homebrew-work-on-an-m1-mac/


7. **Connect to VPN**:
   - Import the previously generated user configuration file into your Wireguard client.
   - Activate the VPN to establish a secure connection to your AWS VPC.

8. **Access the Webserver**:
   - Once connected to the VPN, you should be able to remotely access your web server using its private IP address.
     - For Windows: use RDP 
     - For Linux: use SSH (will be given key)


-------
WebServer 2: launch-wizard-4
TestWireguardInstance: launch-wizard-2