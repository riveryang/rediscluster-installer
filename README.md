# RedisCluster安装文档

## 安装环境

* OS: CentOS 6.5
* Redis: 3.2.1
* Ruby 2.3.1

## 安装依赖
```shell
# yum install gcc make
```

## 下载安装Redis
```shell
cd /usr/local/src
wget http://download.redis.io/releases/redis-3.2.1.tar.gz
tar -zxvf redis-3.2.1.tar.gz
cd redis-3.2.1
make
make install
cd src
cp redis-trib.rb /usr/local/bin

## 查看安装是否成功
redis-server -v
## Output
# Redis server v=3.2.1 sha=00000000:0 malloc=jemalloc-4.0.3 bits=64 build=f416a254f49da46f
```

## 下载安装Ruby
```shell
cd /usr/local/src
wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz
tar -zxvf ruby-2.3.1.tar.gz
cd ruby-2.3.1
./configure
make
make install

## 校验安装
ruby -v
## Output
# ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-linux]

## 如果运行 gem install xxx 出现zlib的错误，则执行如下命令
cd /usr/local/src/ruby-2.3.1/ext/zlib
ruby ./extconf.rb
make
make install
```

## 安装 Redis Ruby工具
```shell
gem install redis -v ‘3.2.1'

## 查看安装结果
gem list --local | grep redis
## Output
# redis (3.2.1)
```

## 构建RedisCluster数据目录
```shell
mkdir -p /data/redis-cluster
mkdir -p /data/redis-cluster/configs
```

## 创建实例构建脚本
```shell
cd /data/redis-cluster
vim cluster_instance.sh
```
[cluster_instance.sh](cluster_instance.sh)

## 创建redis.conf配置文件模板
```shell
cd /data/redis-cluster
vim redis.conf
```
[redis.conf](redis.conf)

## 创建redis初始化脚本模板文件（ 可在redis3.2.1/utils目录下获取 ）
```shell
cp /usr/local/src/redis-3.2.1/utils/redis_init_script.tpl /data/redis-cluster
```
[redis_init_script.tpl](redis_init_script.tpl)

## 创建服务器网络优化脚本
```shell
cd /data/redis-cluster
vim sysoptimize.sh
```
[sysoptimize.sh](sysoptimize.sh)

## 使用构建脚本创建集群实例
构建实例执行cluster_instance.sh脚本，默认创建7000端口的实例(配置文件)，在交互终端中输入端口创建不同端口的实例。
```shell
./cluster_instance.sh

# Welcome to the redis service installer
# This script will help you easily set up a running redis server
# 
# Please select the redis port for this instance: [7000]
# Selecting default: 7000
# Please select the redis config file name [/data/redis-cluster/7000/redis.conf]
# Selected default - /data/redis-cluster/7000/redis.conf
# Please select the redis cluster config file for this instance: [/data/redis-cluster/7000/nodes.conf]
# Selected default - /data/redis-cluster/7000/nodes.conf
# Please select the redis log file name [/data/redis-cluster/7000/redis.log]
# Selected default - /data/redis-cluster/7000/redis.log
# Please select the data directory for this instance [/data/redis-cluster/7000]
# Selected default - /data/redis-cluster/7000
# Please select the redis executable path [/usr/local/bin/redis-server]
# Installing service...
# Installation successful!

./cluster_instance.sh
# Welcome to the redis service installer
# This script will help you easily set up a running redis server
# 
# Please select the redis port for this instance: [7000] 7001
# Please select the redis config file name [/data/redis-cluster/7001/redis.conf]
# Selected default - /data/redis-cluster/7001/redis.conf
# Please select the redis cluster config file for this instance: [/data/redis-cluster/7001/nodes.conf]
# Selected default - /data/redis-cluster/7001/nodes.conf
# Please select the redis log file name [/data/redis-cluster/7001/redis.log]
# Selected default - /data/redis-cluster/7001/redis.log
# Please select the data directory for this instance [/data/redis-cluster/7001]
# Selected default - /data/redis-cluster/7001
# Please select the redis executable path [/usr/local/bin/redis-server]
# Installing service...
# Installation successful!

...
```

## 启动Redis实例
```shell
service redis_cluster_7000 start
service redis_cluster_7001 start
service redis_cluster_7002 start
service redis_cluster_7003 start
service redis_cluster_7004 start
service redis_cluster_7005 start
```

## 构建RedisCluster集群
```shell
redis-trib.rb create --replicas 1 10.1.240.15:7000 10.1.240.15:7001 10.1.240.15:7002 10.1.240.15:7003 10.1.240.15:7004 10.1.240.15:7005
# >>> Creating cluster
# >>> Performing hash slots allocation on 6 nodes...
# Using 3 masters:
# 10.1.240.15:7000
# 10.1.240.15:7001
# 10.1.240.15:7002
# Adding replica 10.1.240.15:7003 to 10.1.240.15:7000
# Adding replica 10.1.240.15:7004 to 10.1.240.15:7001
# Adding replica 10.1.240.15:7005 to 10.1.240.15:7002
# M: 4fa04df2193f1afa5af4a8401cf7f20b25050d85 10.1.240.15:7000
#    slots:0-5460 (5461 slots) master
# M: 2ce926ba15ceea0e7db5e4a3d0046b558c78a7e3 10.1.240.15:7001
#    slots:5461-10922 (5462 slots) master
# M: 655384940962e2b77e749e3541014953e64e6855 10.1.240.15:7002
#    slots:10923-16383 (5461 slots) master
# S: 783e1642b3f5581e0b6cc21dd49ddc084b013fed 10.1.240.15:7003
#    replicates 4fa04df2193f1afa5af4a8401cf7f20b25050d85
# S: 191daaa4c572cb0d73bf02fb316196de6b7f5ca9 10.1.240.15:7004
#    replicates 2ce926ba15ceea0e7db5e4a3d0046b558c78a7e3
# S: 6827274e14bea490dcc2b0b72a64b77bfd5e6975 10.1.240.15:7005
#    replicates 655384940962e2b77e749e3541014953e64e6855
# Can I set the above configuration? (type 'yes' to accept): yes
# >>> Nodes configuration updated
# >>> Assign a different config epoch to each node
# >>> Sending CLUSTER MEET messages to join the cluster
# Waiting for the cluster to join...
# >>> Performing Cluster Check (using node 10.1.240.15:7000)
# M: 4fa04df2193f1afa5af4a8401cf7f20b25050d85 10.1.240.15:7000
#    slots:0-5460 (5461 slots) master
# M: 2ce926ba15ceea0e7db5e4a3d0046b558c78a7e3 10.1.240.15:7001
#    slots:5461-10922 (5462 slots) master
# M: 655384940962e2b77e749e3541014953e64e6855 10.1.240.15:7002
#    slots:10923-16383 (5461 slots) master
# M: 783e1642b3f5581e0b6cc21dd49ddc084b013fed 10.1.240.15:7003
#    slots: (0 slots) master
#    replicates 4fa04df2193f1afa5af4a8401cf7f20b25050d85
# M: 191daaa4c572cb0d73bf02fb316196de6b7f5ca9 10.1.240.15:7004
#    slots: (0 slots) master
#    replicates 2ce926ba15ceea0e7db5e4a3d0046b558c78a7e3
# M: 6827274e14bea490dcc2b0b72a64b77bfd5e6975 10.1.240.15:7005
#    slots: (0 slots) master
#    replicates 655384940962e2b77e749e3541014953e64e6855
# [OK] All nodes agree about slots configuration.
# >>> Check for open slots...
# >>> Check slots coverage...
# [OK] All 16384 slots covered.
```

## 查看集群状态
```shell
redis-trib.rb check 10.1.240.15:7000
# >>> Performing Cluster Check (using node 10.1.240.15:7000)
# M: 4fa04df2193f1afa5af4a8401cf7f20b25050d85 10.1.240.15:7000
#    slots:0-5460 (5461 slots) master
#    1 additional replica(s)
# S: 191daaa4c572cb0d73bf02fb316196de6b7f5ca9 10.1.240.15:7004
#    slots: (0 slots) slave
#    replicates 2ce926ba15ceea0e7db5e4a3d0046b558c78a7e3
# M: 655384940962e2b77e749e3541014953e64e6855 10.1.240.15:7002
#    slots:10923-16383 (5461 slots) master
#    1 additional replica(s)
# S: 783e1642b3f5581e0b6cc21dd49ddc084b013fed 10.1.240.15:7003
#    slots: (0 slots) slave
#    replicates 4fa04df2193f1afa5af4a8401cf7f20b25050d85
# M: 2ce926ba15ceea0e7db5e4a3d0046b558c78a7e3 10.1.240.15:7001
#    slots:5461-10922 (5462 slots) master
#    1 additional replica(s)
# S: 6827274e14bea490dcc2b0b72a64b77bfd5e6975 10.1.240.15:7005
#    slots: (0 slots) slave
#    replicates 655384940962e2b77e749e3541014953e64e6855
# [OK] All nodes agree about slots configuration.
# >>> Check for open slots...
# >>> Check slots coverage...
# [OK] All 16384 slots covered.
```
