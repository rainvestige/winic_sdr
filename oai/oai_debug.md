@[TOC](OAI 运行调试)

## HSS Config setup  
> _Date: 2020.07.24 Friday_

HSS的配置文件有两个，一是`hss.conf`，另一个是`hss_fd.conf`.

1. `hss.conf`需要修改的参数如下：
    ![hss.conf]

2. `hss_fd.conf`需要修改的参数如下：
    ![hss_fd.conf]
    这里需要注意的是，如果你usim白卡没有OPC只有OP，那么OPERATOR_key要设置成对应的
    OP值；如果情况相反，没有OP只有OPC，那么`OPERATOR_key=""`设置为空。原因如下图
    所示：\
    ![OPc and OP]


## MME Config setup
MME配置文件也有两个，一是`mme.conf`，另一个是`mme_fd.conf`。

1.  `mme.conf`需要修改的内容如下：\
    ![mme.conf 1]
    ![mme.conf 2]
    ![mme.conf 3]
    ![mme.conf 4]
2. `mme_fd.conf`需要修改的内容如下：
    ![mme_fd.conf 1]
    ![mme_fd.conf 2]

## SPGW Config setup
spgw的配置如下：
    ![spgw.conf 1]
需要注意的是，下图中红框内的内容需要改为你自己可以上网的网卡和ip地址。
    ![spgw.conf 2]

## ENB Config setup
- 我们根据手机的型号设置可以连接的频段，这里我设置的是`band=3`频段。
    ![enb conf]
    这个band不确定要不要改，暂时由7改为3，和上图对应。
    ![band]
- eNB(x300) ( _Update Date: 2020.07.27 Monday_) \
    最开始, 我在使用x310时遇到了如下问题, 找不到USRP设备.
    ![can not find usrp x310]

    解决办法在[oai enb x300 additional config]有提到.\
    添加下面内容在`enb.band*.***`配置文件的`RUs = (`模块里
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

## 运行
1. 目前遇到的问题主要是，手机连上enb后，mme运行会中断。\
    ![running 1]
    报错的日志提示是Gtpv2  create local tunnel 出错。\
    ![running error 2]
    具体原因未知，不过出错的地方应该是spgw那块，那里有具体的Gtpv2日志。\
    ![running 3]

2. 不过，后面我突然发现，即使mme中断了，手机仍然可以上网，但是过七八分钟后，连接
    就中断了。下面是一些手机上网的截图。
    |            |            |            |
    |------------|------------|------------|
    | ![phone 1] | ![phone 2] | ![phone 3] |
    | ![phone 4] | ![phone 5] | ![phone 6] |

3. 还出现了一个问题, 当我将带宽从10M提升到20M时(x310), 会出现如下图所示问题.\
    (_Update Date: 2020.07.27 Monday_)
    ![problem receiving samples 1]
    ![problem receiving samples 2]

    网上看到一个类似的问题, 不过他的设备是b210.
    ![problem receiving samples resolution 1]


## oai epc debug 
> _Date: 2020.08.06 Thursday_


### A. 问题描述
S1接口无法连接

1. 正常的连接流程
    ![wireshark success result]

2. 出错的连接流程
    ![wireshark fail result]

3. 小区状态显示`cell down`, 表示S1接口阻断.
    ![enb check fail]


### B. 问题分析
1. 具体分析后发现是PLMN出错
    ![unknown-PLMN 1]
   |                   |             |
   |-------------------|-------------|
   | ![unknown-PLMN 2] | ![enb PLMN] |

2. 我们eNB的PLMN是
   - MCC: 460
   - MNC: 00

3. 从oai mme.log日志中发现, enb有两个公共陆地移动网PLMN, 一个是`460 00`, 一个是`
    460 01`. 和epc的PLMN`460 00`相比时, `plmn_mnc 0/1`0和1不同而出错. 顺带提一下
    , tac也是不同的, 一个是`mme.conf->tac:1`, 一个是`enb->tac:12345`.
    ![mme.log plmn]\
    基站配置了两个PLMN, 如下图所示:\
    ![two plmns]


### C. 解决办法
1. 删除enb中多余的`460 01`等效`PLMN ID`
    ![enb remove one PLMN]\
    日志仍然显示`S1 setup failure`
    ![mme.log s1 setup fail]

2. 修改`mme.conf`中的tac\
    ![change mme.conf tac]\
   日志结果\
    ![mme.log s1 setup pass]\
   enb小区状态UP, 问题已解决\
    ![enb check pass]

3. 尝试添加多个PLMN 
    在`mme.conf`中额外添加`460 01`PLMN, 如下图所示:
    ![mme.conf set multi plmn]\
    日志也显示S1建立成功
    ![mme.log multi plmn success]


## oai enb + srs epc
> _Date: 2020.08.13 Thursday_

```bash
# srs epc located in raspi 3
ssh ubuntu@192.168.2.101

# srs enb raspi 4
ssh ubuntu@192.168.2.104
```

能连上, track area code 没有设置对, 从信令和输出日志看出的, 信令和日志显示不停的显示
`tracking are update requests`请求更新追踪区域.

再将`tracking_area_code` 设置为相同的1, 有概率能连上, 但是不能上网. 
设置为16进制的1后, 可以上网, 但是测速会导致概率中断. 同样的, 有时能连上,
有时连不上.
```bash
tracking_area_code = 0x0001
```
和正常的连接日志有差别
`unhandled S1AP intiating message: UECapabilityInfoIndication`

hornor v9 能连上但是速度很慢

> _Date: 2020.08.17 Monday_
test band B41 2600M


[hss.conf]: https://img-blog.csdnimg.cn/20200723214845352.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[hss_fd.conf]: https://img-blog.csdnimg.cn/20200723214845318.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[OPc and OP]: https://img-blog.csdnimg.cn/20200723215556306.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70#pic_center
[mme.conf 1]: https://img-blog.csdnimg.cn/20200723220050448.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[mme.conf 2]: https://img-blog.csdnimg.cn/20200723220046676.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[mme.conf 3]: https://img-blog.csdnimg.cn/20200723220046670.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[mme.conf 4]: https://img-blog.csdnimg.cn/20200723220046635.png

[mme_fd.conf 1]: https://img-blog.csdnimg.cn/20200723220204194.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[mme_fd.conf 2]: https://img-blog.csdnimg.cn/20200723220204235.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70

[spgw.conf 1]: https://img-blog.csdnimg.cn/20200723220420833.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70#pic_center
[spgw.conf 2]: https://img-blog.csdnimg.cn/20200723220420821.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70

[enb conf]: https://img-blog.csdnimg.cn/20200723174847606.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[band]: https://img-blog.csdnimg.cn/20200723175100342.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70#pic_center

[running 1]: https://img-blog.csdnimg.cn/20200723220952363.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70#pic_center
[running error 2]: https://img-blog.csdnimg.cn/20200723221701771.png
[running 3]: https://img-blog.csdnimg.cn/20200723221059328.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70#pic_center

[phone 1]: https://img-blog.csdnimg.cn/20200724092051916.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[phone 2]: https://img-blog.csdnimg.cn/20200724092051914.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[phone 3]: https://img-blog.csdnimg.cn/20200724092051911.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[phone 4]: https://img-blog.csdnimg.cn/20200724092051904.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[phone 5]: https://img-blog.csdnimg.cn/20200724092051901.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[phone 6]: https://img-blog.csdnimg.cn/20200724092051911.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[oai enb x300 additional config]: https://kb.ettus.com/Getting_Started_with_4G_LTE_using_Eurecom_OpenAirInterface_(OAI)_on_the_USRP_2974
[can not find usrp x310]: https://img-blog.csdnimg.cn/20200727204638992.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70

[problem receiving samples 1]: https://img-blog.csdnimg.cn/20200727210150255.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[problem receiving samples 2]: https://img-blog.csdnimg.cn/20200727210234576.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70
[problem receiving samples resolution 1]: https://img-blog.csdnimg.cn/2020072721015730.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTE3NDUyMjg=,size_16,color_FFFFFF,t_70

[mme.conf set multi plmn]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805220628.png
[mme.log multi plmn success]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805220530.png
[wireshark success result]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805202602.png
[wireshark fail result]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805202637.png
[enb check fail]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805202807.png
[unknown-PLMN 1]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805204050.png
[unknown-PLMN 2]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805204116.png
[enb PLMN]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805204104.png
[mme.log plmn]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805204913.png
[two plmns]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805210008.png
[enb remove one PLMN]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805211209.png
[mme.log s1 setup fail]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805211646.png
[change mme.conf tac]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805212040.png
[mme.log s1 setup pass]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805212257.png
[enb check pass]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200805212352.png
