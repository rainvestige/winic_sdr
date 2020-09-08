# OAI build and install

- ref
    1. Official `EPC_user_Guide.pdf`
##
| Name       | Version |
| oai5G      |         |
| openair-cn | master  |


# hss Step
1. Before run `sudo ./build_xxx`, subsititute `git clone` with 
    `proxychains4 git clone` in the `$OAIPATH/build/tools/build_helper.xx`

2. run `sudo ./build_hss -i` to install the required packages
    ```bash
    sudo apt autoremove
    sudo apt-get install phpmyadmin

    # browser can not show the `127.0.0.1/phpmyadmin` page
    sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
    sudo a2enconf phpmyadmin
    sudo /etc/init.d/apache2 reload
    # then it should work
    ```

    [reset the password for mysql](https://blog.csdn.net/qq_38737992/article/details/81090373?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-2.edu_weight&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-2.edu_weight)
    ```bash
    sudo cat /etc/mysql/debian.cnf

    mysql -u debian-sys-maint -p
    Enter password:
    
    use mysql;
    update mysql.user set authentication_string=password('root') where user='root' and Host ='localhost';
    update user set plugin="mysql_native_password"; 
    flush privileges;
    quit;

    sudo service mysql restart
    mysql -u root -p
    ```

3. `hss.conf and hss_fd.conf` set
    
4. hss build
    ```bash
    ./check_hss_s6a_certificate /usr/local/etc/oai/freeDiameter hss.openair4G.eur
    ./check_mme_s6a_certificate /usr/local/etc/oai/freeDiameter/ mme.openair4G.eur
    ./check_mme_s6a_certificate /usr/local/etc/oai/freeDiameter/ lyzh.openair4G.eur

    ./build_hss --clean --debug
    ```

5. hss run
    ```bash
    ./run_hss
    
    ```


# mme step

1. install required packages
    ```bash
    sudo ./build_mme -i
    ```

2. build mme
    ```bash
    sudo ./build_mme --clean
    ```

3. `mme.conf and mme_fd.conf`

