#!/usr/bin/env bash

iotserver_port="12345"
gcc_ip="10.101.151.5"
dc1_ip="10.121.52.14"
dc2_ip="10.121.52.15"
dc3_ip="10.121.52.16"
storage_ip="10.121.72.23"
falua_ip="10.101.85.138"
luna_ip="10.101.85.24"
gateway_ip="10.101.204.1"
proxy_ip="10.101.85.137"
lab_ip_list="10.121.52.14,10.121.52.15,10.121.52.16,10.121.72.23,10.101.85.138,"\
"10.101.85.24,10.101.204.1,10.101.85.137"
twofa_endpoint="lmpinto.eu.pythonanywhere.com"
dcs_subnet="10.101.52.0/27,10.121.52.0/27"
ping_res_subnet="10.101.85.0/24"
local_subnet="10.96.0.0/11"

# Reset INPUT, OUTPUT and FORWARD to default, i.e. accept all
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# Flush every rule from every chain
iptables -F

# Default behaviour
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# R10 - Loopback traffic is unconditionally accepted
iptables --append INPUT --in-interface lo --jump ACCEPT
iptables --append OUTPUT --out-interface lo --jump ACCEPT

# R9
iptables --append OUTPUT --protocol icmp --icmp-type echo-request \
    --destination $local_subnet --match limit --limit 7/second --limit-burst 1 \
    --jump ACCEPT
iptables --append OUTPUT --protocol icmp --icmp-type echo-request \
    --destination $local_subnet --jump DROP
iptables --append INPUT --protocol icmp --icmp-type echo-reply \
    --source $local_subnet --jump ACCEPT

# R11 - Accept all traffic with an already established connection
iptables --append INPUT --match state --state ESTABLISHED --jump ACCEPT
iptables --append OUTPUT --match state --state ESTABLISHED --jump ACCEPT

# Allow DNS resolution queries
iptables --append OUTPUT --protocol tcp --dport 53 --jump ACCEPT
iptables --append OUTPUT --protocol udp --dport 53 --jump ACCEPT

# R3 - Accepts all TCP connections to IoTServer's port
iptables --append INPUT --protocol tcp --dport $iotserver_port --match state \
    --state NEW,ESTABLISHED --jump ACCEPT
iptables --append OUTPUT --protocol tcp --sport $iotserver_port --match state \
    --state ESTABLISHED --jump ACCEPT

# R2 R5 R8 - Accept SSH but only from GCC, and can initiate it to GCC too
# SSH runs on top of TCP/IP stack, 22 is the SSH reserved port
iptables --append INPUT --protocol tcp --source $gcc_ip --dport 22 \
    --match state --state NEW,ESTABLISHED --jump ACCEPT
iptables --append OUTPUT --protocol tcp --destination $gcc_ip --sport 22 \
    --match state --state NEW,ESTABLISHED --jump ACCEPT

# R8 - Accept SSH from subnet that includes DC1, 2 and 3
# 10.101.52.0/27 implies a 255.255.255.224 subnet mask
iptables --append INPUT --protocol tcp --source $dcs_subnet --dport 22 \
    --match state --state NEW,ESTABLISHED --jump ACCEPT
iptables --append OUTPUT --protocol tcp --destination $dcs_subnet --sport 22 \
    --match state --state ESTABLISHED --jump ACCEPT

# R6 - Accept TCP traffic to 2FA endpoint
iptables --append OUTPUT --protocol tcp --destination $twofa_endpoint \
    --match state --state NEW,ESTABLISHED --jump ACCEPT
iptables --append INPUT --protocol tcp --source $twofa_endpoint \
    --match state --state ESTABLISHED --jump ACCEPT

# R7 - Only receive and respond to ping requests from GCC and the internal subnet
iptables --append INPUT --protocol icmp --icmp-type echo-request \
    --source $gcc_ip,$ping_res_subnet --jump ACCEPT
iptables --append OUTPUT --protocol icmp --icmp-type echo-reply \
    --destination $gcc_ip,$ping_res_subnet --jump ACCEPT

# R12 - All traffic from selected internal IPs is accepted except SSH and pings
iptables --append INPUT --protocol tcp --source $lab_ip_list --dport 22 \
    --match state --state NEW,ESTABLISHED --jump DROP
iptables --append OUTPUT --protocol tcp --destination $lab_ip_list --sport 22 \
    --match state --state ESTABLISHED --jump DROP
