#!/bin/sh

# The MIT License (MIT)
# 
# Copyright (c) 2016 River Yang
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
