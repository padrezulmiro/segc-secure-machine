#!/usr/bin/env bash

iotserver_port="12345"
gcc_ip="10.101.151.5"
dcs_subnet="10.101.52.0/27"
internal_subnet="10.101.85.0/24"

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

# R3 - Accepts all TCP connections to IoTServer's port
iptables --append INPUT --protocol tcp --dport $iotserver_port --match state \
    --state NEW,ESTABLISHED --jump ACCEPT
iptables --append OUTPUT --protocol tcp --sport $iotserver_port --match state \
    --state ESTABLISHED --jump ACCEPT

# R2 R5 R8 - Accept SSH but only from GCC, and can initiate it to SSH too
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

# R7 - Only receive and respond to ping requests from GCC and the internal subnet
iptables --append INPUT --protocol icmp --icmp-type echo-request \
    --source $gcc_ip,$internal_subnet --jump ACCEPT
iptables --append OUTPUT --protocol icmp --icmp-type echo-reply \
    --destination $gcc_ip,$internal_subnet --jump ACCEPT

# R9

# R10

# R11

# R12
