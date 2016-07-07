# RedisCluster安装文档

## 安装环境

* Server: CentOS 6.5
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
