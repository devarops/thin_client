# Cliente liviano para desarrollo remoto

## Prerequisitos

Si estas usando un cliente liviano es porque ya existe el **servidor de desarrollo**. El servidor de desarrollo es provisto por el **provisionador**.

- [Servidor de desarrollo](https://github.com/IslasGECI/development_server_setup)
- [Provisionador (servidor)](https://github.com/IslasGECI/provisioner)


## Configura tu cliente liviano

1. Crea tu llave SSH con: `ssh-keygen`
1. Agrega la llave SSH pública de tu estación de trabajo a:
    - [Bitbucket](https://bitbucket.org/account/settings/ssh-keys/) y
    - [GitHub](https://github.com/settings/keys/)
1. Agrega tu llave SSH al agente para hacer _forwarding_
    - En Linux ejecuta: `ssh-add ~/.ssh/id_ed25519`
    - En WSL agrega a `~/.bashrc`:
    ```shell
    eval `ssh-agent -s`
    ssh-add ~/.ssh/id_ed25519
    ```
1. Configura el usuario `evaro` para que `sudo` no requiera contraseña:
    ```shell
    sudo update-alternatives --config editor
    sudo visudo -f /etc/sudoers.d/evaro
    ```
    agregando esta línea:
    ```
    evaro ALL=(ALL) NOPASSWD: ALL
    ```
1. Instala Ansible, Git y Make:
    ```shell
    sudo apt update && sudo apt install --yes ansible-core git make
    ```
1. Crea el archivo `/etc/ansible/hosts` con el siguiente contenido:
    ```shell
    [development]
    islasgeci.dev ansible_host=islasgeci.dev ansible_user=evaro ansible_become_password="{{ lookup('env', 'DEVSERVER_SUDO_PASSWORD') }}"
    localhost ansible_connection=local
    ```
1. Configura tu cliente liviano
    ```shell
    mkdir --parents ~/repositorios/
    cd ~/repositorios/
    git clone git@github.com:devarops/thin_client.git
    cd thin_client
    make setup_client
    ```
1. Reinincia la terminal.
1. Verifica que tu cliente liviano cuenta con el software requerido:
    ```shell
    cd ~/repositorios/thin_client
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
1. Copia las credenciales hacia el servidor de desarrollo y configura el servidor de desarrollo desde tu cliente liviano: `init-devserver`[.](https://github.com/devarops/dotfiles/blob/develop/.bash_aliases#L9)
1. Finalmente, entra al servidor de desarrollo con: `ssh devserver`[.](https://github.com/devarops/dotfiles/blob/develop/.ssh/config)
