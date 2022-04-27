## En DigitalOcean

Crea dos Droplets:

- `workstation`
- `devserver`
    - Reasigna la [IP flotante](https://cloud.digitalocean.com/networking/floating_ips) correspondiente a `devserver`

## En tu cliente liviano copia las credenciales hacia el servidor `workstation`

```shell
scp ~/.ssh/id_rsa root@<WORKSTATION IP>:/root/.ssh/
```

## En el servidor `workstation` configura el servidor `devserver`

1. Entra con: `ssh root@<WORKSTATION IP>`
1. Agrega [bóveda secreta](https://docs.google.com/document/d/1lY7ycXs4J8wp1OyJCmPsvfB7YdQqscqL52cIZxBP6Rw)
1. Ejecuta:
```shell
apt update && apt install --yes docker.io
git clone https://github.com/IslasGECI/development_server_setup.git
cd development_server_setup
git checkout feature/create_droplet
docker build --tag islasgeci/development_server_setup:latest .
docker login
docker push islasgeci/development_server_setup:latest
docker run --interactive --rm --tty --volume ${HOME}/.ssh/id_rsa:/root/.ssh/id_rsa --volume ${HOME}/.vault/.secrets:/root/.vault/.secrets islasgeci/development_server_setup:latest make
```

## En el servidor `devserver` crea una cuenta de usuario

1. Entra con:
    ```shell
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "islasgeci.dev"
    ssh root@islasgeci.dev
    ```
1. En el servidor ejecuta:
    ```shell
    export GITHUB_USERNAME=<GITHUB USERNAME>
    adduser $GITHUB_USERNAME
    usermod --append --groups docker,sudo $GITHUB_USERNAME
    sed --in-place 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo service ssh restart
    ```

> Reemplaza `<GITHUB USERNAME>` con tu nombre de usuario en GitHub

## En tu cliente liviano copia las credenciales hacia el servidor `devserver`

```shell
export GITHUB_USERNAME=<GITHUB USERNAME>
ssh-copy-id $GITHUB_USERNAME@islasgeci.dev
scp -pr ~/.vault $GITHUB_USERNAME@islasgeci.dev:/home/$GITHUB_USERNAME/.vault
ssh-add ~/.ssh/id_rsa
```

## En el servidor `devserver` instala tu configuración personal

1. Entra con: `ssh -o ForwardAgent=yes $GITHUB_USERNAME@islasgeci.dev`
1. Ejecuta:
    ```shell
    mkdir --parents ~/repositorios
    git clone --bare git@github.com:$USER/dotfiles.git ~/repositorios/dotfiles.git
    git --git-dir=${HOME}/repositorios/dotfiles.git --work-tree=${HOME} checkout
    git --git-dir=${HOME}/repositorios/dotfiles.git --work-tree=${HOME} config --local status.showUntrackedFiles no
    source ~/.profile
    ```
1. Instala PDE:
    ```shell
    cd ~/repositorios
    git clone git@github.com:devarops/pde.git
    cd pde
    make
    ```

## En tu cliente liviano monta los repositorios del servidor

```shell
sudo apt install sshfs
sudo mkdir --parents /mnt/$GITHUB_USERNAME/
sudo chown $USER:$USER /mnt/$GITHUB_USERNAME/
sshfs $GITHUB_USERNAME@islasgeci.dev:/home/$GITHUB_USERNAME/repositorios/ /mnt/$GITHUB_USERNAME/
```

> Para desmontar: `fusermount -u /mnt/$GITHUB_USERNAME/`
