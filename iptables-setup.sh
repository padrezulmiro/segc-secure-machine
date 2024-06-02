#!/usr/bin/env bash

iotserver_port="12345"
gcc_ip="10.101.151.5"
dcs_subnet="10.101.52.0/27"

# Reset INPUT, OUTPUT and FORWARD to default, i.e. accept all
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -F

# R3 - Accepts all TCP connections to IoTServer's port
iptables --append INPUT --protocol tcp --dport $iotserver_port --match state \
    --state NEW,ESTABLISHED --jump ACCEPT
iptables --append OUTPUT --protocol tcp --sport $iotserver_port --match state \
    --state --state ESTABLISHED --jump ACCEPT

# R2 R8 - Accept SSH but only from GCC
# SSH runs on top of TCP/IP stack, 22 is the SSH reserved port
iptables --append INPUT --protocol tcp --source $gcc_ip --dport 22 \
    --match state --state NEW,ESTABLISHED --jump ACCEPT
iptables --append OUTPUT --protocol tcp --destination $gcc_ip --sport 22 \
    --match state --state ESTABLISHED --jump ACCEPT

# R8 - Accept SSH from subnet that includes DC1, 2 and 3
# 10.101.52.0/27 implies a 255.255.255.224 subnet mask
iptables --append INPUT --protocol tcp --source $dcs_subnet --dport 22 \
    --match state --state NEW,ESTABLISHED --jump ACCEPT
iptables --append OUTPUT --protocol tcp --destination $dcs_subnet --sport 22 \
    --match state --state ESTABLISHED --jump ACCEPT

# R7

# R8

# R9

# R10

# R11

# R12

# Default behaviour
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
