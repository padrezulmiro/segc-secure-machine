#!/usr/bin/env bash

# Reset INPUT, OUTPUT and FORWARD to default, i.e. accept all
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -F

# R2 R8 - Accept SSH but only from GCC
# SSH runs on top of TCP/IP stack, 22 is the SSH reserved port
iptables --append INPUT --protocol tcp --source 10.101.151.5 --dport 22 \
    --match state --state NEW,ESTABLISHED --jump ACCEPT
iptables --append OUTPUT --protocol tcp --destination 10.101.151.5 --sport 22 \
    --match state --state ESTABLISHED --jump ACCEPT

# R8 - Accept SSH from subnet that includes DC1, 2 and 3
# 10.101.52.0/27 implies a 255.255.255.224 subnet mask
iptables --append INPUT --protocol tcp --source 10.101.52.0/27 --dport 22 \
    --match state --state NEW,ESTABLISHED --jump ACCEPT
iptables --append OUTPUT --protocol tcp --destination 10.101.52.0/27 --sport 22 \
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
