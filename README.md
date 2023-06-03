# Beta
````sudo docker run -e ENABLE_SSL=True -e DOMAIN_NAME=exampla.com -e USER_EMAIL=you@example.com --restart=unless-stopped --name openspeedtest -d -p 80:3000 -p 443:3001 openspeedtest/beta````


#  **[SpeedTest by OpenSpeedTest™](https://openspeedtest.com?Run&ref=Github)** - Free & Open-Source HTML5 Network Performance Estimation Tool.
##  **[OpenSpeedTest™ Docker Image](https://hub.docker.com/r/openspeedtest/latest)**

[![OpenSpeedTest Docker Image](https://github.com/openspeedtest/v2-Test/raw/main/images/10G-S.gif)](https://hub.docker.com/r/openspeedtest/latest  "OpenSpeedTest Docker Image")
**No client-side software or plugin is required. You can run a network speed test from any device with a [Web Browser that is IE10 or new.](https://www.youtube.com/watch?v=9f-OM_WQ7Bw&list=PLt-deStxFJOMEAs2O1lJhscMNzcg9E3Po&index=1)**

**This is docker implementation using nginxinc/nginx-unprivileged:stable-alpine. uses significantly fewer resources.**

- NGINX Docker image that runs NGINX as a non root, unprivileged user.
 
 ###  Docker install instructions:

 Install Docker and run the following command!

````bash

sudo docker run --restart=unless-stopped --name openspeedtest -d -p 3000:3000 -p 3001:3001 openspeedtest/latest

````
#### Or use docker-compose.yml 
````
version: '3.3'
services:
    speedtest:
        restart: unless-stopped
        container_name: openspeedtest
        ports:
            - '3000:3000'
            - '3001:3001'
        image: openspeedtest/latest
````
- Warning! If you run it behind a **[Reverse Proxy](https://github.com/openspeedtest/Speed-Test/issues/4#issuecomment-1229157193)**, you should increase the `post-body content length` to 35 megabytes.

- **[Follow our Nginx Config.](https://github.com/openspeedtest/Nginx-Configuration)**

Now open your browser and direct it to:

A: For **HTTP** use: `http://YOUR-SERVER-IP:3000`

B: For **HTTPS** use: `https://YOUR-SERVER-IP:3001`

#### Container-Port for http is 3000
If you need to run this image on a different port for `HTTP`, Eg: change to `80` = `-p 80:3000`
#### Container-Port for https is 3001
If you need to run this image on a different port for `HTTPS`, Eg: change to `443` =  `-p 443:3001`

###  How to use your own SSL Certificate?

You can mount a folder with your own SSL certificate to this docker container by adding the following line to the above command.

  

````bash

-v /${PATH-TO-YOUR-OWN-SSL-CERTIFICATE}:/etc/ssl/

````

The folder needs to contain:

- `nginx.crt`

- `nginx.key`

  

I am adding a folder with nginx.crt and nginx.key from my desktop by using the following command.

````bash

sudo docker run -v /Users/vishnu/Desktop/docker/:/etc/ssl/ --restart=unless-stopped --name openspeedtest -d -p 3000:3000 -p 3001:3001 openspeedtest/latest

````
