@[TOC](free5gc installation and test)


## Reference
- [github free5gc readme]
- [free5gc forum]
- [github free5gc wiki]


## Environment
| Name   | Version                       |
|--------|-------------------------------|
| OS     | Ubuntu 18.04.4                |
| Go     | 1.14.4 linux/amd64            |
| kernel | 5.0.0-23-generic(MUST for UPF |


## Installation

### A. Pre-requisite

1. 需要内核版本`5.0.0-23-generic`, 
    ```bash
    uname -r
    # 5.0.0-23-generic
    ```
    更换内核方法直接使用:
    ```bash
    sudo apt-get install linux-image-5.0.0-23-generic
    sudo apt-get install linux-headers-5.0.0-23-generic
    ```

2. Go language requirement
    - 如果存在安装的其他Go版本, 
        - 卸载.
            - `sudo rm -rf /usr/local/go`
        - Install Go 1.14.4
            ```bash
            wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz
            sudo tar -C /usr/local -zxvf go1.14.4.linux-amd64.tar.gz
            # 后面的配置和下面一样
            ```
    - 如果是第一次安装Go
        - Install Go 1.14.4
            ```bash
            wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz
            sudo tar -C /usr/local -zxvf go1.14.4.linux-amd64.tar.gz
            mkdir -p ~/go/{bin,pkg,src}
            echo 'export GOPATH=$HOME/go' >> ~/.bashrc
            echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
            echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> ~/.bashrc
            source ~/.bashrc
            
            ```

3. Required packages for control plane 控制侧需要的依赖包
    ```bash
    sudo apt -y update
    sudo apt -y install mongodb wget git
    sudo systemctl start mongodb
    ```

4. Required packages for user plane 用户侧需要的依赖包
    ```bash
    sudo apt -y update
    sudo apt -y install git gcc cmake autoconf libtool pkg-config libmnl-dev libyaml-dev
    go get -u github.com/sirupsen/logrus
    ```
    这里遇到了一个问题, Go 下载模块的时候需要外网. 
    ![GoConnectError]
    解决办法--添加代理
    ![GoProxy]

### B. Install Control Plane Entities

1. Clone free5GC project
    ```bash
    cd ~
    git clone --recursive -b v3.0.3 -j `nproc` https://github.com/free5gc/free5gc.git
    cd free5gc
    ```
    (Optional) If you want to use the nightly version, runs:
    ```bash
    cd ~/free5gc
    git checkout master
    git submodule sync
    git submodule update --init --jobs `nproc`
    git submodule foreach git checkout master
    git submodule foreach git pull --jobs `nproc`
    ```

2. Run the script to install dependent packages
    ```bash
    cd ~/free5gc
    go mod download
    ```
    不要改变任何文件名, In step 2, the folder name should remain free5gc.

3. Complie free5gc 
    ```bash
    ./build.sh
    ```


### C. Install User Plane Function(UPF)

1. Check the kernel version
    ```bash
    uname -r
    
    ```
    Get linux kernel module 5G GTP-U
    ```bash
    git clone -b v0.1.0 https://github.com/PrinzOwO/gtp5g.git
    cd gtp5g
    make
    sudo make install
    ```

2. Build from sources
    ```bash
    cd ~/free5gc/src/upf
    mkdir build
    cd build
    cmake ..
    make -j`nproc`
    ```
    Note: UPF's config is located at
    `free5gc/src/upf/build/config/ufcfg.yaml`


## Run

### A. Run Core Network

- Option 1. Run network function service individually, e.g. AMF(redo this for 
    each NF)
    ```bash
    cd ~/free5gc
    ./bin/amf
    ```
    Note For N3IWF needs specific configuration in section B

- Option 2. Run whole core network with command
    ```bash
    ./run.sh
    ```
    运行结果图如下\
    ![run.sh result]


### B. Run N3IWF(Individually)
TODO


## Test
```bash
cd ~/free5gc
chmod +x ./test.sh
```

- a. TestRegistration
    ```bash
    (in directory: ~/free5gc)
    ./test.sh TestRegistration
    ```
    测试的时候遇到如下问题
    ![test problem 1]

- b. TestServiceRequest
    ```bash
    ./test.sh TestServiceRequest
    ```

- c. Other test
    TODO


[github free5gc readme]: https://github.com/free5gc/free5gc
[github free5gc wiki]: https://github.com/free5gc/free5gc/wiki
[free5gc forum]: https://forum.free5gc.org/

[GoConnectError]: https://img-blog.csdnimg.cn/20200729220042935.png
[GoProxy]: https://img-blog.csdnimg.cn/2020072921594552.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[run.sh result]: https://img-blog.csdnimg.cn/20200730082921761.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[test problem 1]: https://img-blog.csdnimg.cn/20200730083612439.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70#pic_center

