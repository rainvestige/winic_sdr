# 5G OpenAir first run


# Environment and Introduction
| Name               | Describe               |
|--------------------|------------------------|
| Date               | 2020.07.26 Sunday      |
| Ubuntu             | 18.04.4 LTS            |
| openairinterface5g | develop, tag: 2020.w28 |

下图为open-cells `5G OpenAir first run` 的简单介绍. 主要是OAI的代码目前实现的功
能非常有限, 貌似没有核心网模块. \
![introduction]


# References
- [open-cells 5G OpenAir first run]


# Build 

```bash
cd /path/to/openairinterface5g/
git checkout develop
source oaienv
cd cmake_targets/

./build_oai -I
./build_oai --gNB --nrUE
```

下面是一些编译的截图, 其中有一些warning, 但并没有错误.\
![build_oai command]
![build_oai result 1]
![build_oai result 2]


# Running

1. Run the gNB in one windows
    ```bash
    sudo ./nr-softmodem -O ../../../ci-scripts/conf_files/gnb.band78.tm1.106PRB.usrpn300.conf \ 
    --parallel-config PARALLEL_SINGLE_THREAD --rfsim --phy-test --rfsimulator.serveraddr server \ 
    --noS1 -d
    ```

2.  原文内容\
    ![ip address problem in one machine]

3. Solve the ip address problem
    ```bash
    sudo ip netns delete ueNameSpace
    sudo ip link delete v-eth1
    sudo ip netns add ueNameSpace
    sudo ip link add v-eth1 type veth peer name v-ue1
    sudo ip link set v-ue1 netns ueNameSpace
    sudo ip addr add 10.200.1.1/24 dev v-eth1
    sudo ip link set v-eth1 up
    
    sudo iptables -t nat -A POSTROUTING -s 10.200.1.0/255.255.255.0 -o enp34s0 -j MASQUERADE
    sudo iptables -A FORWARD -i enp34s0 -o v-eth1 -j ACCEPT
    sudo iptables -A FORWARD -o enp34s0 -i v-eth1 -j ACCEPT
    sudo ip netns exec ueNameSpace ip link set dev lo up
    sudo ip netns exec ueNameSpace ip addr add 10.200.1.2/24 dev v-ue1
    sudo ip netns exec ueNameSpace ip link set v-ue1 up
    
    
    # Set your window in the new namespace
    sudo ip netns exec ueNameSpace bash
    ```
    主要是修改`enp34s0`网络接口.

4. In the namespace, run
    ```bash
    sudo ./nr-uesoftmodem -d --rrc_config_path . --nokrnmod --phy-test --rfsim \
    --rfsimulator.serveraddr 10.200.1.1 --noS1
    ```

5. Results 
    可以看到, 有波形出现.
    ![running result]
   


[open-cells 5G OpenAir first run]: 
https://open-cells.com/index.php/2020/05/27/5g-openair-first-run/

[introduction]: https://img-blog.csdnimg.cn/20200726212024838.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[build_oai command]: https://img-blog.csdnimg.cn/20200726213110842.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[build_oai result 1]: https://img-blog.csdnimg.cn/20200726213127112.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[build_oai result 2]: https://img-blog.csdnimg.cn/20200726213136634.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[ip address problem in one machine]: https://img-blog.csdnimg.cn/20200726213848330.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[running result]: https://img-blog.csdnimg.cn/20200726214424935.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
