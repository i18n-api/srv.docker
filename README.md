开发请先安装 docker ( mac 推荐安装 [orbstock](https://orbstack.dev) ), 然后运行

```
direnv exec . ./up.sh
```

因为mysql表名需要区分大小写, ./dev 请放到区分大小写的分区 ,

可以用磁盘工具点添加卷 , 选择区分大小写 , 然后到 /Volumes/xxx 下面运行

用创建 它 和 conf 的软连接 可以让 它 和 srv 物理上不在一个根目录

## redis 集群配置文件

```
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
cluster-announce-ip 192.168.20.122
```

redis 的 cluster-announce-ip 参数用于指定集群通信和重定向时使用的 IP 地址。

这个参数的主要作用是让节点在集群内部通信时宣传一个不同于自己实际 IP 的地址。(DOCKER 应该用宿主机的 ip)

举个例子 , 如果一个 redis 节点实际 IP 是 192.168.1.100, 但你设置 cluster-announce-ip 为 10.0.0.100, 那么这个节点与其他节点通信时 , 会宣传它的 IP 是 10.0.0.100, 而不是 192.168.1.100。

这样做的目的是为了让集群节点对外使用一个稳定的内网 IP 进行通信 , 而不暴露节点的真实本地 IP, 增强集群的安全性。

另外 , 在云环境中 , 如果节点的内网 IP 会因为迁移等原因经常变化 , 那么设置一个固定的 cluster-announce-ip 也可以避免集群重定向出现问题。

https://zhuanlan.zhihu.com/p/631038890

https://www.macrozheng.com/blog/redis_cluster.html

Redis 集群指定主从关系及动态增删节点
https://zhuanlan.zhihu.com/p/401032957

指定主从，思路如下：

先创建具有三个主节点的集群，没有从节点

使用添加节点的命令添加从节点，这样就可以在添加时指定它们的主节点，建立主从对应关系

具体如下：

1. 使用以下命令创建主节点：

redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 --cluster-replicas 0

2. 增加从节点：

redis-cli --cluster add-node 127.0.0.1:7003 127.0.0.1:7000 --cluster-slave --cluster-master-id ***************

其中：

slave 表示要添加从节点
cluster-master-id 要添加到哪一个主节点，id 是*****
127.0.0.1:7003 要添加的从节点
127.0.0.1:7000 原集群中任意节点
ok，这样添加完后得到的就是指定的想要的节点架构。

动态增删节点
1. 增加主节点

redis-cli --cluster add-node 127.0.0.1:7008 127.0.0.1:7000
其中：

127.0.0.1:7008 要向集群添加新的节点
127.0.0.1:7000 原集群中任意节点
这里，节点已经加入集群，但：

由于它还没有分配到 hash slots，所以它还没有数据
由于它是还没有 hash slots 的主节点，所以它不会参与到从节点升级到主节点的选举中
此时，执行 resharding 指令来为它分配 hash slots，这会进入交互式命令行，由用户输入相关信息：

redis-cli --cluster reshard 127.0.0.1:7000
只需要指定一个节点，redis 会自动发现其他节点。

How many slots do you want to move (from 1 to 16384)?
target node id？
from what nodes you want to take those keys？
第一个问题需要需要填写，如 1000.

第二个问题可以通过命令查看：`redis-cli -p 7000 cluster nodes | grep myself`

第三个问题：all，这样会从每个节点上移动一部分 hash slots 到新节点

然后开始迁移，每迁移一个 key 就会输出一个点。

待所有迁移完成后，执行下面的指令查看集群是否正常：

redis-cli --cluster check 127.0.0.1:7000

2. 增加从节点

redis-cli --cluster add-node 127.0.0.1:7006 127.0.0.1:7000 --cluster-slave
该指令与增加主节点语法一致，与添加主节点不同的是，显式指定了是从节点。

这会为该从节点随机分配一个主节点，优先从那些从节点数目最少的主节点中选取。

如果要在添加从节点时就为其指定主节点，需要指定 master-id，执行下面的指令（需要替换为真实的 id）：

redis-cli --cluster add-node 127.0.0.1:7006 127.0.0.1:7000 --cluster-slave --cluster-master-id 3c3a0c74aae0b56170ccb03a76b60cfe7dc1912e
另一种添加从节点的方式是添加一个空的主节点，然后把该节点指定为某个主节点的从节点：

cluster replicate 3c3a0c74aae0b56170ccb03a76b60cfe7dc1912e

3. 删除节点

注意，只能删除从节点或者空的主节点，指令如下：

redis-cli --cluster del-node 127.0.0.1:7000 <node-id>
其中：

127.0.0.1:7000 为集群中任意节点
node-id 为要删除的节点的 id
如果想删除有数据的主节点，必须先执行 resharding 把它的数据分配到其他节点后再删除。
