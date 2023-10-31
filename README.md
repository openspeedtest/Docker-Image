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

### Setup Free LetsEncrypt SSL with Automatic Certificate Renewal
***Requirements***
- PUBLIC IPV4 and/or IPV6 address.
- A domain name that resolves to speed test server's IP address.
- Email ID

The following command will generate a Let's Encrypt certificate for your domain name and configure a cron job to automatically renew the certificate.

````
docker run -e ENABLE_LETSENCRYPT=True -e DOMAIN_NAME=speedtest.yourdomain.com -e USER_EMAIL=you@yourdomain.pro --restart=unless-stopped --name openspeedtest -d -p 80:3000 -p 443:3001 openspeedtest/latest
````
#### Or use docker-compose.yml 
````
version: '3.3'
services:
    speedtest:
        environment:
            - ENABLE_LETSENCRYPT=True
            - DOMAIN_NAME=speedtest.yourdomain.com
            - USER_EMAIL=you@yourdomain.pro
        restart: unless-stopped
        container_name: openspeedtest
        ports:
            - '80:3000'
            - '443:3001'
        image: openspeedtest/latest
````

###  How to Use Your Own Secure Sockets Layer (SSL) Certificate, Self-Signed or Paid?
***Requirements***
- Folder with your Certificate, Self-Signed or Paid.
- Rename .cet file and .key file to `nginx.crt` & `nginx.key`

  The folder needs to contain:

- `nginx.crt`

- `nginx.key`


````
sudo docker run --restart=unless-stopped --name openspeedtest -d -p 3000:3000 -p 3001:3001 openspeedtest/latest
````

To mount a folder with your own SSL certificate to this Docker container, append the following line to the above command:
  

````bash

-v /${PATH-TO-YOUR-OWN-SSL-CERTIFICATE}:/etc/ssl/

````
  
I am adding a folder with nginx.crt and nginx.key from my desktop by using the following command.

````bash

sudo docker run -v /Users/vishnu/Desktop/docker/:/etc/ssl/ --restart=unless-stopped --name openspeedtest -d -p 3000:3000 -p 3001:3001 openspeedtest/latest

````
#### Or use docker-compose.yml 
````
version: '3.3'
services:
    speedtest:
        volumes:
            - '/Users/vishnu/Desktop/docker/:/etc/ssl/'
        restart: unless-stopped
        container_name: openspeedtest
        ports:
            - '3000:3000'
            - '3001:3001'
        image: openspeedtest/latest
````
## Advanced Configuration Options 

- Container Port Configuration
  
To enable port changes, set the `CHANGE_CONTAINER_PORTS` environment variable to `"True"` and provide appropriate values for the following variables.

`CHANGE_CONTAINER_PORTS=True`

`HTTP_PORT=3000`

`HTTPS_PORT=3001`

- Set User
  
`SET_USER=101`

- Only Allow `CORS Request` from listed domains. 

`ALLOW_ONLY=domain1.com;domain2.com;domain3.com`

- `SET_SERVER_NAME` Display the server name on the UI.
  
`SET_SERVER_NAME=HOME-NAS` 
