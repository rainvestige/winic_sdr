@[TOC](All in one OpenAirInterface)


本文几乎照搬 [all in one openairinterface]

- Reference
    - [all in one openairinterface]


# 安装环境
| Name             | Version                                         |
|------------------|-------------------------------------------------|
| Ubuntu           | 18.04.4(all packages upgraded)                  |
| UHD              | 3.15.0.HEAD-0-gaea0e2de                         |
| openair-cn       | commit 724542d0b59797b010af8c5df15af7f669c1e838 |
| openairinterface | commit edb74831dabf79686eb5a92fbf8fc06e6b267d35 |


# 准备工作

## 1. Add the OAI repository as authorized remote system

添加OAI库作为授权的远端系统
```bash
echo -n | openssl s_client -showcerts -connect gitlab.eurecom.fr:443 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | sudo tee -a /etc/ssl/certs/ca-certificates.crt
```


## 2. Install USRP drivers

参考链接--[安装USRP驱动(UHD)](https://editor.csdn.net/md/?articleId=107121328)


## 3. Download author's modifications

下载原作者Laurent的补丁
```bash
cd ~
wget https://open-cells.com/opencells-mods-20190923.tgz
tar xf opencells-mods-20190923.tgz
```

## 4. Download and patch EPC

```bash
# maybe go back to home directory (leave openairinterface5g directory)
git clone https://gitlab.eurecom.fr/oai/openair-cn.git
cd openair-cn
git checkout develop
```
当时的develop分支commit:724542d0b59797b010af8c5df15af7f669c1e838


克隆上面代码现在需要帐号了，如果你没用的话，可以考虑下载作者上传的压缩包
[openair-cn](
https://open-cells.com/d5138782a8739209ec5760865b1e53b0/openair-cn.tgz)

```bash
tar xf openair-cn.tgz
cd openair-cn
git checkout develop
```

Apply the patch(打上作者提供的补丁):
```bash
git apply ~/opencells-mods/EPC.patch
```


# Install third party SW for EPC

安装第三方依赖

## HSS
```bash
cd openair-cn 
source oaienv
cd scripts
./build_hss -i
```
- Answer yes to install: freeDiameter 1.2.0
- phpmyadmin:
    - We don’t use phpmyadmin later in this procedure to update the MySQL database
    - We removed the installation of phpmyadmin (of course you can use it if you prefer)


For ubuntu 18.04, we set back the legacy mysql security level
```bash
# 如果你有密码就用下面注释掉的那一句
sudo mysql -u root << END
#sudo mysql -u root -pYOURPASSWORD << END
USE mysql;
UPDATE user SET plugin='mysql_native_password' WHERE User='root';
FLUSH PRIVILEGES;
END

sudo systemctl restart mysql.service

sudo mysql_secure_installation
```

The last command will ask a few questions:

- password: set your password (linux is set in our default config files)
- VALIDATE PASSWORD PLUGIN: no
- Remove anonymous users: yes
- Disallow root login remotely: yes
- Remove test database and access to it: yes
- Reload privilege tables now: yes


## MME
```bash
./build_mme -i
```

- Do you want to install freeDiameter 1.2.0: no
- Do you want to install asn1c rev 1516 patched? <y/N>: yes
- Do you want to install libgtpnl ? <y/N>: yes
- wireshark permissions: as you prefer


## SPGW
```bash
./build_spgw -i
```

- Do you want to install libgtpnl? <y/N>: no


# Complie the EPC nodes
```bash
cd openair-cn 
source oaienv
cd scripts

./build_hss
./build_mme
./build_spgw
```

如果你遇到任何编译的问题，日志文件在 `openair-cn/build/log`下，在这个文件里找
`error:`的字符串



# Download & Complie the eNB on 18.04


```bash
git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git
cd openairinterface5g
git checkout edb74831da
```

```bash
source oaienv  
./cmake_targets/build_oai -I  # install SW packages from internet
./cmake_targets/build_oai -w USRP --eNB --UE # compile eNB and UE
```

## eNB Building Problems
- `./build_oai -w USRP` 找不到uhd库
    ![build_oai uhd.so not find]\
    具体的原因应该是你安装uhd库时没有安装到默认的目录(/usr/local), 比如我安装
    多个版本的uhd库时, 就会安装到(/usr/local/opt/uhd_x_x_x)目录下, 其中
    `uhd_x_x_x`的`x`指的是uhd的版本号. 多个版本可以创建软连接来管理. 

    解决办法是在`/path/to/cmake_targets/CMakeLists.txt`文件里添加uhd的头文件和
    库文件搜索目录, 如下图所示.\
    ![cmake add include and lib search path]


# Install author's configuration for EPC

```bash
sudo mkdir -p /usr/local/etc/oai
sudo cp -rp ~/opencells-mods/config_epc/* /usr/local/etc/oai

cd openair-cn; source oaienv; cd scripts
./check_hss_s6a_certificate /usr/local/etc/oai/freeDiameter hss.OpenAir5G.Alliance
./check_mme_s6a_certificate /usr/local/etc/oai/freeDiameter mme.OpenAir5G.Alliance
```

1. spgw.conf
    Only the SGi output to internet need to be configured.
    In /usr/local/etc/oai/spgw.conf,
    your should set the Ethernet interface that is connected to Internet, and,
    to tell to the PGW to implement NAPT for the UE traffic
    ```bash
    PGW_INTERFACE_NAME_FOR_SGI = "enp3s0";
    PGW_MASQUERADE_SGI = "yes";
    ```

2. SIM MCC/MNC should be duplicated in a couple of file
    - eNB
        ```bash
         ////////// MME parameters:
        mme_ip_address = ( { ipv4 = "127.0.0.20";
        ipv6 = "192:168:30::17";
        active = "yes";
        preference = "ipv4";
        }
        );

         NETWORK_INTERFACES :
        {
        ENB_INTERFACE_NAME_FOR_S1_MME = "lo";
        ENB_IPV4_ADDRESS_FOR_S1_MME = "127.0.0.10/8";

        ENB_INTERFACE_NAME_FOR_S1U = "lo";
        ENB_IPV4_ADDRESS_FOR_S1U = "127.0.0.10/8";
        ENB_PORT_FOR_S1U = 2152; # Spec 2152
        };
        ```
    - MME file: /usr/local/etc/oai/mme.conf to update
        ```bash
        GUMMEI_LIST = ( MCC="208" ; MNC="92"; MME_GID="4" ; MME_CODE="1"; } );
        TAI_LIST = ({MCC="208" ; MNC="92"; TAC = "1"; } );
        ```
    - HSS file: /usr/local/etc/oai/hss.conf to update
        设置mysql的账号和密码以及数据库的名字，然后用phpmyadmin网页修改。

3. eNB(x300) ( _Update Date: 2020.07.27 Monday_)
    [oai enb x300 additional config]\
    添加下面内容在`enb.band*.***`配置文件的`RUs = (`模块里\
    ```bash
    sdr_addrs = "type=x300,addr=192.168.10.2";
    ```

    The final `RUs` section should be edited as shown below.
    ```bash
    RUs = (
        {
           local_rf       = "yes"
           nb_tx          = 1
           nb_rx          = 1
           att_tx         = 5
           att_rx         = 0;
           bands          = [7];
           max_pdschReferenceSignalPower = -27;
           max_rxgain                    = 117;
           eNB_instances  = [0];
           sdr_addrs      = "type=x300,addr=192.168.40.2";
        }
    );
    ```
    


# Final test and verification
打开四个终端窗口

In each window
```bash
cd openair-cn; source oaienv; cd scripts; ./run_hss
```
```bash
cd openair-cn; source oaienv; cd scripts; ./run_mme
```
```bash
cd openair-cn; source oaienv; cd scripts; sudo -E ./run_spgw
```
```bash
sudo bash
cd ~/openairinterface5g; source oaienv
cd cmake_targets/lte_build_oai/build
sudo ./lte-softmodem -O ~/opencells-mods/enb.10MHz.b200
```


## Running Problems

1. 我在运行mme时遇到了如下图所示的问题，提示的是找不到freeDiameter动态库。
    ![build_mme error]\
    解决办法是从源码安装freeDiameter，不用脚本安装。
    ```bash
    GIT_SSL_NO_VERIFY=true git clone https://gitlab.eurecom.fr/oai/freediameter.git -b \ 
    eurecom-1.2.0
    cd freediameter
    git apply ~/opencells-mods/freediameter1.2.0.postOAI.patch
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ../
    make -j4
    sudo make install
    ```

- 目前手机可以连上，但是一是没有网络连接，二是mme运行会突然中断，应该是配置文件的
问题，后面继续调试。


[cmake add include and lib search path]:https://img-blog.csdnimg.cn/2020072521282533.png
[all in one openairinterface]: https://open-cells.com/index.php/2019/09/22/all-in-one-openairinterface/
[build_oai uhd.so not find]: https://img-blog.csdnimg.cn/20200725210421569.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[build_mme error]: https://img-blog.csdnimg.cn/20200722214602892.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[oai enb x300 additional config]: https://kb.ettus.com/Getting_Started_with_4G_LTE_using_Eurecom_OpenAirInterface_(OAI)_on_the_USRP_2974
