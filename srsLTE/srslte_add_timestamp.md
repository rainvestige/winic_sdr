## srslte add timestamp to console output
因为有需求给srslte运行时的终端输出添加时间戳, 所以有如下对源码的修改. 修改的内
容不是很难, 但是对需要修改代码的位置进行定位花了点时间.

### A. srslte有一个logger类, 该类主要负责日志的记录和输出.
读程序一般从main函数开始, 这里从`srsepc/src/main.cc`开始. 从下图可以看出和
日志输出有关的类为`stdout_logger`和`log_filter`\
![srsepc code analyse]\
起初并不确定哪一个类决定了输出终端的内容, 所以打算一个一个尝试.

### B. 修改`logger_stdout.h`
1. 从`logger_stdout.h`头文件可以看出, 有日志直接输出到了标准输出流. 所以对这
    部分进行修改.
    ![srslte logger_stdout.h]
2. 查阅了`c/c++`处理时间的函数的相关资料.
    ![cpp ctime.h]
3. 修改`logger_stdout.h`代码
    ![srslte logger_stdout.h changed]
4. 修改结果如下图所示
    ![result after change logger stdout.h]
5. 分析
    从修改结果可以看出, 时间戳添加到了日志当中, 而且是将日志输出到终端时才会显
    示, 将日志输出到文件并不会显示. 并且日志文件已经有了时间戳, 不过时区是`UTC`
    后面这个时区也需要修改为本地时区.

### C. 修改`log_filter`类
1. 在浏览`log_filter`的源码时, 发现了一个函数`log_filter::console()`, 该函数也
    是直接打印到终端.
    ![srslte log_filter::console]\
2. 修改`log_filter::console()`函数体
    ![srslte log_filter::console changed]
3. 同时在`log_filter`源码里也找到了日志的时间变量, 用获取本地时间的函数替换获取
    `UTC`时间的函数.
    ![buffer time may affect the timezone]
    ![log timezone changed]
4. 修改后结果
    ![console result added timestamp]\
    ![log result changed timestamp]

### D. 生成补丁
生成`git patch`, 以便在其他机器上部署.
![git diff result]
![git patch generate]



[srsepc code analyse]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200731145721.png?token=AH3FL3MVJMJKANRVGAIS3SS7EPARC
[srslte logger_stdout.h]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200731150122.png?token=AH3FL3L2WHSDBS6NPEKPK5S7EPBAW
[cpp ctime.h]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200731152449.png?token=AH3FL3I7VJBRLR3G5N4WATK7EPDX6
[srslte logger_stdout.h changed]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200731153217.png?token=AH3FL3JE5VPGBLB6OGNPOAK7EPEUE
[result after change logger stdout.h]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200731154947.png?token=AH3FL3OTZSUSNKPWTL46DQ27EPGVY
[srslte log_filter::console]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200731172955.png?token=AH3FL3KPFKNXMNGP3S3MTI27EPSNE
[srslte log_filter::console changed]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200731173810.png?token=AH3FL3K44E6Y4MHWRWE7W2S7EPTMC
[buffer time may affect the timezone]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200731174621.png
[console result added timestamp]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200801151608.png
[log result changed timestamp]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200801151803.png
[log timezone changed]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200801153057.png
[git diff result]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200801153808.png
[git patch generate]: https://raw.githubusercontent.com/rainvestige/PicGo/master/20200801155902.png
