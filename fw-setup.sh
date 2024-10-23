#!/usr/bin/env bash 
read -p "Palo IP: " palo_ip
read -p "Palo PW: " palo_pw
read -p "Cisco FTD IP: " ftd_ip
read -p "Cisco FMC IP: " fmc_ip
read -p "Cisco PW: " cisco_pw


# ssh-keygen -t rsa -b 4096 -C "ansible@localhost" -f ~/.ssh/id_rsa -N ""

#Line below came from chatgpt
API_KEY=$(curl -s -k -H "Content-Type: application/x-www-form-urlencoded" -X POST "https://$PALO_IP/api/?type=keygen" -d "user=admin&password=$PALO_PW" | grep -oP '(?<=<key>)[^<]+')

echo $API_KEY
# Output to fw.yml 
cat > data/inv.yml <EOF
palo:
  hosts:
    $PALO_IP:
  vars:
    ip_address: $PALO_IP
    api_key: $API_KEY
    fw: palo1

esxi:
  hosts:
    10.60.60.20:
      esxi_password: {{ ADD PASSWORD HERE }}
    10.60.60.21:
      esxi_password: {{ ADD PASSWORD HERE }}
  vars:
    ansible_user: root
    esxi_password: {{ ADD PASSWORD HERE }}

cisco:
  hosts:
    ${ftd_ip}:
      username: admin
      password: {{ cisco_pw }}
      fw: fw2
  vars:
    ftd_ip: ${ftd_ip}
EOF

cat ~/.ssh/id_rsa.pub
cat data/inv.yml

# sudo ansible-vault encrypt inv.yml