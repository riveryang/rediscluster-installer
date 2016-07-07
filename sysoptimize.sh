#!/bin/sh

sysctl vm.overcommit_memory=1
sysctl net.ipv4.tcp_max_tw_buckets=6000
sysctl net.ipv4.ip_local_port_range="1024 65000"
sysctl net.ipv4.tcp_tw_recycle=1
sysctl net.ipv4.tcp_tw_reuse=1
sysctl net.ipv4.tcp_syncookies=1
sysctl net.core.somaxconn=262144
sysctl net.core.netdev_max_backlog=262144
sysctl net.ipv4.tcp_max_orphans=262144
sysctl net.ipv4.tcp_max_syn_backlog=262144
sysctl net.ipv4.tcp_timestamps=0
sysctl net.ipv4.tcp_synack_retries=1
sysctl net.ipv4.tcp_syn_retries=1
sysctl net.ipv4.tcp_fin_timeout=1
sysctl net.ipv4.tcp_keepalive_time=30
sysctl fs.file-max=262144
