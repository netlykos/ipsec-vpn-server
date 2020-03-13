# IPSec VPN Server on Raspberry PI as Docker instance

This project contains the code and build files required to run a IPSec VPN Server as a docker instance on a Raspberry PI. It's inspired by similar projects (see [Links](#Links)) and was used by myself to learn more about:
- Docker: Build process, management and other items
- IPSec: Configuration and management of a IPSec service
- Raspberry PI: What it can and cannot do

## Docker
This section covers items related to docker

### Build Docker image
To build the docker image and associate it the container, run the below command in the same directory as the ``docker-compose.yaml`` and ``Dockerfile``.

```
docker-compose build
```

### Docker image management
To see if the docker image from the above step - shows details like repository, tag, creation date and size (reason I switched to alpine).
```
docker images
```

To remove images (either because they have been updated or for another reason)
```
docker rmi <hash> | <repository>
```

### Commands related to docker container management
To see if the docker image from the above step - shows details like, repository, tag, creation date and size.
```
docker container ls -a
```

Spin up a container and interact with it
```
docker run -it netlykos/ipsec-vpn-server
```

Like previous, but reclaim/prune it upon exit
```
docker run --rm -it netlykos/ipsec-vpn-server
```

## Links
- Alpine Linux package management system - (https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management)
- Alpine Linux package content file finder (https://pkgs.alpinelinux.org/contents)
- Documentation on docker-compose (https://docs.docker.com/compose/compose-file/)
- Docker on Raspberry PI (https://blog.alexellis.io/getting-started-with-docker-on-raspberry-pi/)
- IPSec VPN on Raspberry PI (https://github.com/ritazh/l2tpvpn-docker-pi/)
- Docker IPSec VPN server on Raspberry PI (#2) (https://github.com/hwdsl2/docker-ipsec-vpn-server/)
- IPSec configuration (https://imdjh.github.io/sysadmin/2015/04/19/setup-pptp-with-l2tp-vpn-server-on-wheezy.html)
- ipsec.conf(5) man page (https://linux.die.net/man/5/ipsec.conf)
- Associative arrays in bash (https://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/)
