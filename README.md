# Cliente liviano para desarrollo remoto

## Prerequisitos

Si estas usando un cliente liviano es porque ya existe el **servidor de desarrollo**. El servidor de desarrollo es provisto por el **provisionador**.

- [Servidor de desarrollo](https://github.com/IslasGECI/development_server_setup)
- [Provisionador (servidor)](https://github.com/IslasGECI/provisioner)


## Configura tu cliente liviano

1. Crea tu clave SSH con: `ssh-keygen`
1. Agrega la clave SSH pública de tu estación de trabajo a:
    - [Bitbucket](https://bitbucket.org/account/settings/ssh-keys/) y
    - [GitHub](https://github.com/settings/keys/)
1. Agrega tu clave SSH al agente para hacer _forwarding_
    - En Linux ejecuta: `ssh-add ~/.ssh/id_ed25519`
    - En WSL agrega a `~/.bashrc`:
    ```shell
    eval `ssh-agent -s`
    ssh-add ~/.ssh/id_ed25519
    ```
1. Crea directorio para clonar repositorios:
    ```shell
    mkdir --parents ~/repositorios/
    ```
1. Verifica que tu cliente liviano cuenta con el softare requerido
    ```shell
    cd ~/repositorios/
    git clone git@github.com:devarops/thin_client.git
    cd thin_client
    make check
    ```
1. Instala [dotfiles](https://github.com/devarops/dotfiles):
    ```shell
    cd ~/repositorios/
    git clone git@github.com:devarops/dotfiles.git
    cd dotfiles
    make install
    ```
1. Agrega tu [bóveda secreta](https://docs.google.com/document/d/1lY7ycXs4J8wp1OyJCmPsvfB7YdQqscqL52cIZxBP6Rw/).
1. Copia las credenciales hacia el servidor de desarrollo
    ```shell
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "islasgeci.dev"
    ssh-keyscan "islasgeci.dev" >> "$HOME/.ssh/known_hosts"
    export USERNAME=<Tu nombre de usuario del servidor>
    scp -pr ~/.vault $USERNAME@islasgeci.dev:/home/$USERNAME/.vault
    scp ~/todo.md $USERNAME@islasgeci.dev:/home/$USERNAME/todo.md
    ```
1. Crea el archivo `/etc/ansible/hosts` con el siguiente contenido:
    ```ini
    [devserver]
    islasgeci.dev ansible_host=islasgeci.dev ansible_user=evaro ansible_become_password="{{ lookup('env', 'DEVSERVER_SUDO_PASSWORD') }}"
    localhost ansible_connection=local
    ```
1. Desde tu cliente liviano, configura el servidor de desarrollo
    ```shell
    cd ~/repositorios/thin_client
    make setup_server
    ```
1. Finalmente, entra al servidor de desarrollo con: `ssh -o ForwardAgent=yes $USERNAME@islasgeci.dev`[^forward].

[^forward]:
    Alternativamente, puedes agregar la opción `ForwardAgent yes` a `~/.ssh/config` en tu cliente liviano:
    ```
    Host islasgeci.dev
      ForwardAgent yes
    ```
    Revisa [este ejemplo](https://github.com/devarops/dotfiles/blob/develop/.ssh/config).

---

## Opcional: En tu cliente liviano monta los repositorios del servidor

```shell
sudo apt install sshfs
sudo mkdir --parents /mnt/$GITHUB_USERNAME/
sudo chown $USER:$USER /mnt/$GITHUB_USERNAME/
sshfs $GITHUB_USERNAME@islasgeci.dev:/home/$GITHUB_USERNAME/repositorios/ /mnt/$GITHUB_USERNAME/
```

> Para desmontar: `fusermount -u /mnt/$GITHUB_USERNAME/`
