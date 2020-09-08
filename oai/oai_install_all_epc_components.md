[toc]
## Official Guide about openair-cn
> _Date: 2020.08.10 Monday_

> Ref:
> - [Install all EPC components in one host, one physical network adapter]
> - [Install all SPGW components in one host, one physical network adapter]


### A. KVM example on ubuntu (HSS MME)
Kernel-based Virtual Machine(KVM) is an open source virtualization technology 
built into Linux.

1. Install uvtool
   ```bash
   sudo apt -y install uvtool virt-manager
   sudo uvt-simplestreams-libvirt sync release=bionic arch=amd64
   ```
2. Create VM
   ```bash
   uvt-kvm create --memory 4096 --disk 10 --cpu 2  test-install-openair-cn \
   arch=amd64 release=bionic
   # 下面这条命令执行后, 并没有进入到虚拟机. 不过提示了虚拟机所在地址, 用ssh
   # 登录就行.
   sudo uvt-kvm ssh test-install-openair-cn --insecure
   ssh ubuntu@192.168.122.135
   ```
   ![uvt-kvm create failure]
   上述图片中第一条命令失败了, 原因是我开着virtualbox虚拟机. 关闭了virtualbox就可以
   了.

   ![log in error 1]
   ![log in error 2]
   ![success log in]

3. Enbale SSH
   ```bash
   # set ubuntu password
   sudo passwd ubuntu

   # generate ssh key
   ssh-keygen -t dsa

   # enable password authentication
   # in `/etc/ssh/sshd_config` set
   PasswordAuthentication yes
   ```

4. Download EPC source code
   ```bash
   git clone https://github.com/OPENAIRINTERFACE/openair-cn.git
   git clone https://github.com/OPENAIRINTERFACE/openair-cn-cups.git
   ```
   ![ssh transfer files]
   ![ssh transfer result]
   ![ssh transfer command]

5. Install HSS
   ```bash
   cd openair-cn/scripts/
   ./build_cassandra -i -F
   ```

   - no valid OpenPGP data found
   ![gpg: no valid OpenPGP data found]
   ![attempt to solve "no valid OpenPGP data found"]
   ![solve the "no valid OpenPGP data found"]

   - [签名无法验证, no public key 的解决办法]
   ![GPG error: No PUBKEY]
   ![solve the NO PUBKEY error]

   成功安装Cassandra
   ![cassandra installation successful]


   > _Date: 2020.08.11 Tuesday_
   
   [virsh vm management tools]
   ```bash
   # 重新启动虚拟机
   virsh list --all
   virsh start test-install-openair-cn
   #virsh shutdown test-install-openair-cn
   uvt-kvm ip test-install-openair-cn
   ```

   __Set the JRE version 8 as default__
   ```bash
   sudo service cassandra stop
   sudo update-alternatives --config java
   sudo service cassandra start
   ```
   ![set the jre version 8]

   __Verify the Cassandra is installed and running__
   ```bash
   nodetool status
   ```
   ![verify the cassandra is installed and running]


   __Stop Cassandra and cleanup the log files before modifying the configuration__
   ```bash
   sudo service cassandra stop
   sudo rm -rf /var/lib/cassandra/data/system/*
   sudo rm -rf /var/lib/cassandra/commitlog/*
   sudo rm -rf /var/lib/cassandra/data/system_traces/*
   sudo rm -rf /var/lib/cassandra/saved_caches/*
   ```

   Update the Cassandra configuration __if needed__(default configuration set
   __1 cassandra node listening on localhost__). Update 
   `/etc/cassandra/cassandra.yaml` as indicated below. The 
   `<Cassandra_Server_IP>` address should be the IP address of the Cassandra
   server that the HSS will use to connect to Cassandra. The "..." below 
   indicate configuration lines between values taht need to be modified.
   ```yaml
   ...
   cluster_name: "HSS Cluster"
   ...
   # OAI Note: no to change Cassandra_Server_IP that is already 127.0.0.1
   seed_provider:
   - class_name: org.apache.cassandra.locator.SimpleSeedProvider
   - seeds: "127.0.0.1"
   ...
   listen_address: <Cassandra_Server_IP>
   ...
   rpc_address: <Cassandra_Server_IP>
   ...
   # OAI Note: seems to be this option that is working()
   # endpoint_snitch: SimpleSnitch
   endpoint_snitch: GossipingPropertyFileSnitch
   ```
   ![seed provider]
   ![endpoint snitch]

   ```bash
   sudo service cassandra start
   ```

   __Check cassandra service status__
   ```bash
   sudo service cassandra status
   ```
   ![check cassandra service status]

   __Install HSS software dependencies__
   ```bash
   ./build_hss_rel14 --check-installed-software --force
   ```
   ![install HSS dependencies]

   __Build HSS__
   ```bash
   ./build_hss_rel14 --clean
   ```
   ![build HSS]

   __Populate users table__
   
   Here you will have to feed scripts with your parameters:

   !!! IMPORTANT NOTICE !!! It is highly recommended that your APN contains a 
   realm, else you will have to enter in the SPGW config file ...gprs 
   APN (Access Point Name): --apn value # value is "default.ng4T.com" here.  

   LTE K: --key value # value is "fec86ba6eb707ed08905757b1bb44b8f" here.

   IMSI: --imsi value # value of IMSI of first subscriber is "208931234561000" 
   here, the IMSI of next subscribers will be incremented by one, if --no-of-
   users value is > 1. 

   REALM: --realm value # value of realm here is ng4T.com.

   MME FQDN: --mme-identity value # value of MME FQDN is mme.ng4T.com here (end 
   with realm).
   ```bash
   Cassandra_Server_IP='127.0.0.1'
   cqlsh --file ../src/hss_rel14/db/oai_db.cql $Cassandra_Server_IP
   ./data_provisioning_users --apn default.ng4T.com --apn2 internet \
   --key 12345678901234567890123456789012 --imsi-first 460000000000095 \
   --msisdn-first 001011234561000 --mme-identity mme.ng4T.com --no-of-users 1 \
   --realm ng4T.com --truncate True  --verbose True \
   --cassandra-cluster $Cassandra_Server_IP --opc 12345678901234567890123456789012

   ./data_provisioning_users --apn default.ng4T.com --apn2 internet \
   --key 12345678901234567890123456789012 --imsi-first 460111234567890 \
   --msisdn-first 001011234561001 --mme-identity mme.ng4T.com --no-of-users 1 \
   --realm ng4T.com --truncate True  --verbose True \
   --cassandra-cluster $Cassandra_Server_IP --opc 12345678901234567890123456789012
   ```
   ![populate users table 1]
   ```bash
   ./data_provisioning_mme \
   --id 3 --mme-identity mme.ng4T.com --realm ng4T.com --ue-reachability 1 \
   --truncate True  --verbose True -C $Cassandra_Server_IP
   ```
   ![populate users table 2]


   __Create HSS configuration files__
   ```bash
   # 将下面的文件保存到一个script里执行就行
   # prompt has been removed for easier Ctrl+C Ctrl+V
   # cd $OPENAIRCN_DIR/scripts
   
   openssl rand -out $HOME/.rnd 128
   
   cd ~/openair-cn/scriptes

   PREFIX='/usr/local/etc/oai'
   sudo mkdir -p $PREFIX
   sudo chmod 777 $PREFIX
   sudo mkdir  $PREFIX/freeDiameter
   sudo chmod 777 $PREFIX/freeDiameter
   sudo mkdir -m 0777 -p $PREFIX/logs
   sudo mkdir -m 0777 -p logs
   
   # freeDiameter configuration files
   sudo cp ../etc/acl.conf ../etc/hss_rel14_fd.conf $PREFIX/freeDiameter
   sudo chmod 666 $PREFIX/freeDiameter/acl.conf $PREFIX/freeDiameter/hss_rel14_fd.conf
   
   # HSS configuration files
   sudo cp ../etc/hss_rel14.conf ../etc/hss_rel14.json $PREFIX
   sudo chmod 666 $PREFIX/hss_rel14.conf $PREFIX/hss_rel14.json
   cp ../etc/oss.json $PREFIX
   
   declare -A HSS_CONF
   HSS_CONF[@PREFIX@]=$PREFIX
   HSS_CONF[@REALM@]='ng4T.com'
   HSS_CONF[@HSS_FQDN@]="hss.${HSS_CONF[@REALM@]}"
   HSS_CONF[@cassandra_Server_IP@]='127.0.0.1' 
   HSS_CONF[@cassandra_IP@]='127.0.0.1' # TODO harmonize these 2
   HSS_CONF[@OP_KEY@]='12345678901234567890123456789012'
   HSS_CONF[@ROAMING_ALLOWED@]='true'
   
   for K in "${!HSS_CONF[@]}"; do 
     egrep -lRZ "$K" $PREFIX | xargs -0 -l sed -i -e "s|$K|${HSS_CONF[$K]}|g"
   done
   
   ### freeDiameter certificate
   ../src/hss_rel14/bin/make_certs.sh hss ${HSS_CONF[@REALM@]} $PREFIX
   
   # Finally customize the listen address of FD server (if necessary because 
   # FD binds by default on available interfaces)
   # set in $PREFIX/freeDiameter/hss_rel14_fd.conf and uncomment the following line
   sudo sed -i -e 's/#ListenOn/ListenOn/g' $PREFIX/freeDiameter/hss_rel14_fd.conf 
   ```

   __Update OPC Cassandra DB if necessary(do it almost one time unless you have
   only OPC and populate it in DB__
   ```bash
   oai_hss -j $PREFIX/hss_rel14.json --onlyloadkey
   ```
   ![update OPC]

6. Install MME

   __Install MME software dependencies__
   ```bash
   ./build_mme --check-installed-software --force
   ```
   ![change build helper for easy install dependencies]
   ![install MME success]

   permission problem[TODO]

   __Build MME__
   ```bash
   ./build_mme --clean
   ```
   ![build mme success]

   __Create MME configuration files__
   ```bash
   # Put the following code in mme_conf.sh
   # prompt has been removed for easier Ctrl+C Ctrl+V
   openssl rand -out $HOME/.rnd 128
   # cd $OPENAIRCN_DIR/scripts
   # S6a

   cd ~/openair-cn/scripts

   INSTANCE=1
   PREFIX='/usr/local/etc/oai'
   sudo mkdir -m 0777 -p $PREFIX
   sudo mkdir -m 0777    $PREFIX/freeDiameter
   
   # First major difference with Lionel's setup: I am not setting up an `m1c`
   # sub-interface and directly use the physical interface `ens3`
   sudo ifconfig ens3:m11 172.16.1.102 up
   #sudo ifconfig ens3:m1c 192.168.247.102 up

   # freeDiameter configuration file
   cp ../etc/mme_fd.sprint.conf  $PREFIX/freeDiameter/mme_fd.conf
   cp ../etc/mme.conf  $PREFIX
   
   declare -A MME_CONF
   MME_CONF[@MME_S6A_IP_ADDR@]="127.0.0.11"
   MME_CONF[@INSTANCE@]=$INSTANCE
   MME_CONF[@PREFIX@]=$PREFIX
   MME_CONF[@REALM@]='ng4T.com'
   MME_CONF[@PID_DIRECTORY@]='/var/run'
   MME_CONF[@MME_FQDN@]="mme.${MME_CONF[@REALM@]}"
   MME_CONF[@HSS_HOSTNAME@]='hss'
   MME_CONF[@HSS_FQDN@]="${MME_CONF[@HSS_HOSTNAME@]}.${MME_CONF[@REALM@]}"
   MME_CONF[@HSS_IP_ADDR@]='127.0.0.1'

   MME_CONF[@MCC@]='460'
   MME_CONF[@MNC@]='00'
   MME_CONF[@MME_GID@]='32768'
   MME_CONF[@MME_CODE@]='3'
   MME_CONF[@TAC_0@]='600'
   MME_CONF[@TAC_1@]='601'
   MME_CONF[@TAC_2@]='602'


   MME_CONF[@MME_INTERFACE_NAME_FOR_S1_MME@]='ens3'
   MME_CONF[@MME_IPV4_ADDRESS_FOR_S1_MME@]='192.168.122.135/24'
   MME_CONF[@MME_INTERFACE_NAME_FOR_S11@]='ens3:m11'
   MME_CONF[@MME_IPV4_ADDRESS_FOR_S11@]='172.16.1.102/24'
   MME_CONF[@MME_INTERFACE_NAME_FOR_S10@]='ens3:m10'
   MME_CONF[@MME_IPV4_ADDRESS_FOR_S10@]='192.168.10.110/24'
   MME_CONF[@OUTPUT@]='CONSOLE'
   MME_CONF[@SGW_IPV4_ADDRESS_FOR_S11_TEST_0@]='172.16.1.104/24'
   MME_CONF[@SGW_IPV4_ADDRESS_FOR_S11_0@]='172.16.1.104/24'
   MME_CONF[@PEER_MME_IPV4_ADDRESS_FOR_S10_0@]='0.0.0.0/24'
   MME_CONF[@PEER_MME_IPV4_ADDRESS_FOR_S10_1@]='0.0.0.0/24'
   
   #implicit MCC MNC 001 01
   TAC_SGW_TEST='7'
   tmph=`echo "$TAC_SGW_TEST / 256" | bc`
   tmpl=`echo "$TAC_SGW_TEST % 256" | bc`
   MME_CONF[@TAC-LB_SGW_TEST_0@]=`printf "%02x\n" $tmpl`
   MME_CONF[@TAC-HB_SGW_TEST_0@]=`printf "%02x\n" $tmph`
   
   MME_CONF[@MCC_SGW_0@]=${MME_CONF[@MCC@]}
   MME_CONF[@MNC3_SGW_0@]=`printf "%03d\n" $(echo ${MME_CONF[@MNC@]} | sed 's/^0*//')`
   TAC_SGW_0='600'
   tmph=`echo "$TAC_SGW_0 / 256" | bc`
   tmpl=`echo "$TAC_SGW_0 % 256" | bc`
   MME_CONF[@TAC-LB_SGW_0@]=`printf "%02x\n" $tmpl`
   MME_CONF[@TAC-HB_SGW_0@]=`printf "%02x\n" $tmph`
   
   MME_CONF[@MCC_MME_0@]=${MME_CONF[@MCC@]}
   MME_CONF[@MNC3_MME_0@]=`printf "%03d\n" $(echo ${MME_CONF[@MNC@]} | sed 's/^0*//')`
   TAC_MME_0='601'
   tmph=`echo "$TAC_MME_0 / 256" | bc`
   tmpl=`echo "$TAC_MME_0 % 256" | bc`
   MME_CONF[@TAC-LB_MME_0@]=`printf "%02x\n" $tmpl`
   MME_CONF[@TAC-HB_MME_0@]=`printf "%02x\n" $tmph`
   
   MME_CONF[@MCC_MME_1@]=${MME_CONF[@MCC@]}
   MME_CONF[@MNC3_MME_1@]=`printf "%03d\n" $(echo ${MME_CONF[@MNC@]} | sed 's/^0*//')`
   TAC_MME_1='602'
   tmph=`echo "$TAC_MME_1 / 256" | bc`
   tmpl=`echo "$TAC_MME_1 % 256" | bc`
   MME_CONF[@TAC-LB_MME_1@]=`printf "%02x\n" $tmpl`
   MME_CONF[@TAC-HB_MME_1@]=`printf "%02x\n" $tmph`
   
   
   for K in "${!MME_CONF[@]}"; do 
     egrep -lRZ "$K" $PREFIX | xargs -0 -l sed -i -e "s|$K|${MME_CONF[$K]}|g"
     ret=$?;[[ ret -ne 0 ]] && echo "Tried to replace $K with ${MME_CONF[$K]}"
   done
   
   # Generate freeDiameter certificate
   sudo ./check_mme_s6a_certificate $PREFIX/freeDiameter mme.${MME_CONF[@REALM@]}
   ```
   ![](https://raw.githubusercontent.com/rainvestige/PicGo/master/20200812154046.png)
   ```bash
   chmod +x mme_conf.sh
   ./mme_conf.sh
   ```


### B. KVM example on ubuntu (SPGW)

1. Install SPGW-U
   __Install SPGW-U software dependencies__
   ```bash
   cd openair-cn-cups/
   cd ./build/scripts
   ./build_spgwu -I -f
   ```

   ![build spgwu error]
   ![install libfmt-dev]
   ![could not find <fmt/core.h>]
   ![install fmt from source]
   从源码安装fmt
   ```bash
   git clone https://github.com/fmtlib/fmt.git && cd fmt && \
   mkdir _build && cd _build && \
   cmake .. && \
   make -j$(nproc) && \
   sudo make install
   ```

   __Build SPGW-U__
   ```bash
   ./build_spgwu -c -V -b Debug -j
   ```
   ![spgwu installed]

   __Create SPGW-U configuration files__
   > _Date: 2020.08.12 Wednesday_
   ```bash
   # 将下面的内容放到一个shell脚本里
   # prompt has been removed for easier Ctrl+C Ctrl+V
   sudo ifconfig ens3:sxu 172.55.55.102 up   # SPGW-U SXab interface
   #sudo ifconfig ens3:s1u 192.168.248.159 up # SPGW-U S1U interface

   INSTANCE=1
   PREFIX='/usr/local/etc/oai'
   sudo mkdir -m 0777 -p $PREFIX
   cp ../../etc/spgw_u.conf  $PREFIX
   
   declare -A SPGWU_CONF
   
   SPGWU_CONF[@INSTANCE@]=$INSTANCE
   SPGWU_CONF[@PREFIX@]=$PREFIX
   SPGWU_CONF[@PID_DIRECTORY@]='/var/run'
   SPGWU_CONF[@SGW_INTERFACE_NAME_FOR_S1U_S12_S4_UP@]='ens3'
   SPGWU_CONF[@SGW_INTERFACE_NAME_FOR_SX@]='ens3:sxu'
   SPGWU_CONF[@SGW_INTERFACE_NAME_FOR_SGI@]='ens3'
   
   for K in "${!SPGWU_CONF[@]}"; do 
     egrep -lRZ "$K" $PREFIX | xargs -0 -l sed -i -e "s|$K|${SPGWU_CONF[$K]}|g"
     ret=$?;[[ ret -ne 0 ]] && echo "Tried to replace $K with ${SPGWU_CONF[$K]}"
   done
   ```
   Important: Customize in `$PREFIX/spgw_u.conf` file the "SPGW-C_LIST" and
   "PDN_NETWORK_LIST" sections.
   ![spgwu configuration]
   ![SPGW-C_LIST]


2. Install SPGW-C

   __Install SPGW-C software dependencies__
    ```bash
   cd openair-cn-cups/
   cd ./build/scripts
   ./build_spgwc -I -f
    ```
   ![spgw-c dep installation success]

   __Build SPGW-C__
   ```bash
   ./build_spgwc -c -V -b Debug -j
   ```
   ![spgwc installed]

   __Create SPGW-C configuration files__
   ```bash
   # 将下面的内容放到shell脚本里
   # prompt has been removed for easier Ctrl+C Ctrl+V
   sudo ifconfig ens3:sxc 172.55.55.101 up # SPGW-C SXab interface
   sudo ifconfig ens3:s5c 172.58.58.102 up # SGW-C S5S8 interface
   sudo ifconfig ens3:p5c 172.58.58.101 up # PGW-C S5S8 interface
   sudo ifconfig ens3:s11 172.16.1.104 up  # SGW-C S11 interface

   INSTANCE=1
   PREFIX='/usr/local/etc/oai'
   sudo mkdir -m 0777 -p $PREFIX
   cp ../../etc/spgw_c.conf  $PREFIX
   
   declare -A SPGWC_CONF
   
   SPGWC_CONF[@INSTANCE@]=$INSTANCE
   SPGWC_CONF[@PREFIX@]=$PREFIX
   SPGWC_CONF[@PID_DIRECTORY@]='/var/run'
   SPGWC_CONF[@SGW_INTERFACE_NAME_FOR_S11@]='ens3:s11'
   SPGWC_CONF[@SGW_INTERFACE_NAME_FOR_S5_S8_CP@]='ens3:s5c'
   SPGWC_CONF[@PGW_INTERFACE_NAME_FOR_S5_S8_CP@]='ens3:p5c'
   SPGWC_CONF[@PGW_INTERFACE_NAME_FOR_SX@]='ens3:sxc'
   SPGWC_CONF[@DEFAULT_DNS_IPV4_ADDRESS@]='8.8.8.8'
   SPGWC_CONF[@DEFAULT_DNS_SEC_IPV4_ADDRESS@]='4.4.4.4'
   
   for K in "${!SPGWC_CONF[@]}"; do 
     egrep -lRZ "$K" $PREFIX | xargs -0 -l sed -i -e "s|$K|${SPGWC_CONF[$K]}|g"
     ret=$?;[[ ret -ne 0 ]] && echo "Tried to replace $K with ${SPGWC_CONF[$K]}"
   done
   ```
   Important: Customize in `PREFIX/spgw_c.conf` file the "IP_ADDRESS_POOL" and
   "APN_LIST" section. 和上文对应, 这里apn设为"default.ng4T.com"
   ![customize apn]

### C. Run EPC Network Functions
0. For people running on their own servers, these manipulations have to be done
   each time you reboot either the EPC server or the orchestrator. 重启后, 
   需要重新设置下面的内容.
   ```bash
   sudo ifconfig ens3:m11 172.16.1.102 up
   sudo ifconfig ens3:m10 192.168.10.110 up
   sudo ifconfig ens3:sxu 172.55.55.102 up
   sudo ifconfig ens3:sxc 172.55.55.101 up
   sudo ifconfig ens3:s5c 172.58.58.102 up
   sudo ifconfig ens3:p5c 172.58.58.101 up
   sudo ifconfig ens3:s11 172.16.1.104 up
   
   # Once again: put your gateway IP address here (`route -n` to get it)
   sudo ip route add default via 192.168.122.1 dev ens3 table lte
   # Add each UE IP pool to the table routing
   sudo ip rule add from 12.0.0.0/8 table lte
   sudo ip rule add from 12.1.1.0/8 table lte
   ```

1. Run HSS
   ```bash
   PREFIX='/usr/local/etc/oai'
   oai_hss -j $PREFIX/hss_rel14.json
   ```
2. Run MME
   ```bash
   PREFIX='/usr/local/etc/oai'
   ./run_mme --config-file $PREFIX/mme.conf --set-virt-if
   ```
3. Run SPGW-C
   ```bash
   PREFIX='/usr/local/etc/oai'
   sudo spgwc -c $PREFIX/spgw_c.conf
   ```

4. Run SPGW-U
   Reminder: Run spgw-c prior to spgw-u

   You will have to do the following only once, each time you power on your host
   if you want to set a specific gateway for user traffic:
   ```bash
   echo '200 lte' | sudo tee --append /etc/iproute2/rt_tables
   # Here the gateway is at 192.168.122.1, use `route -n` to get the gateway
   sudo ip r add default via 192.168.122.1 dev ens3 table lte
   # you will have to repeat the following line for each PDN network set in your 
   # SPGW-U config file 
   sudo ip rule add from 12.0.0.0/8 table lte
   sudo ip rule add from 12.1.1.0/8 table lte
   ```

   ```bash
   PREFIX='/usr/local/etc/oai'
   sudo spgwu -c $PREFIX/spgw_u.conf
   ```

5. Run eNB
   ```bash
   ./lte_build_oai/build/lte-softmodem \
   -O ~/opencells-mods/enb.band7.tm1.25PRB.usrpb210.conf \
   --eNBs.[0].rrc_inactivity_threshold 0 --RUs.[0].max_rxgain 120 \
   --eNBs.[0].component_carriers.[0].pusch_p0_Nominal -90 \
   --eNBs.[0].component_carriers.[0].pucch_p0_Nominal -96 \
   --THREAD_STRUCT.[0].parallel_config PARALLEL_RU_L1_TRX_SPLIT
   ```
   可能是配置问题, 遇到了如下错误
   ![udp_eNB_create_socket()]
   修改mme `tac`参数, `tac`值等于enb里对应的`tac`值.






[uvt-kvm create failure]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810162921.png
[log in error 1]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810215439.png
[log in error 2]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810215506.png
[success log in]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810215523.png
[ssh transfer files]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810220125.png
[ssh transfer result]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810215731.png
[ssh transfer command]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810220148.png
[gpg: no valid OpenPGP data found]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810210011.png
[attempt to solve "no valid OpenPGP data found"]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810211409.png
[solve the "no valid OpenPGP data found"]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810211655.png
[签名无法验证, no public key 的解决办法]: https://blog.csdn.net/zhuiqiuzhuoyue583/article/details/90597499
[GPG error: No PUBKEY]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810211843.png
[solve the NO PUBKEY error]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200810212635.png
[Install all EPC components in one host, one physical network adapter]: https://github.com/OPENAIRINTERFACE/openair-cn/wiki/OpenAirSoftwareSupport
[Install all SPGW components in one host, one physical network adapter]: https://github.com/OPENAIRINTERFACE/openair-cn-cups/wiki/OpenAirSoftwareSupport
[cassandra installation successful]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811142417.png
[virsh vm management tools]: https://baijiahao.baidu.com/s?id=1612293596898577753&wfr=spider&for=pc
[set the jre version 8]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811143236.png
[verify the cassandra is installed and running]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811143445.png
[seed provider]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811145254.png
[endpoint snitch]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811144839.png
[check cassandra service status]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811145903.png
[install HSS dependencies]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811150955.png
[build HSS]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811151213.png
[populate users table 1]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811152809.png
[populate users table 2]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811153054.png
[update OPC]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811155657.png
[change build helper for easy install dependencies]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811165813.png
[install MME success]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811171028.png
[build mme success]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811171513.png
[build spgwu error]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811203134.png
[install libfmt-dev]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811202959.png
[could not find <fmt/core.h>]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811205156.png
[install fmt from source]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811210005.png
[spgwu installed]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811213056.png
[spgw-c dep installation success]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811214101.png
[spgwc installed]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200811215213.png
[spgwu configuration]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200812105029.png
[SPGW-C_LIST]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200812154722.png
[customize apn]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200812155158.png
[udp_eNB_create_socket()]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200812173703.png
