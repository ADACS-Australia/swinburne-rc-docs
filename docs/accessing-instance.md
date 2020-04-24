# Accessing your Instance/Virtual Machine via SSH
**Note: these instruction are for Unix based systems such as Ubuntu or MacOS. For Windows you need to do something similar via PuTTY + SSH.**

Before you can access your virtual machine, you need to know a few pieces of information:

1.  The *username* for your instance. The default usernames for the base images available on Nectar can be found [here](https://support.ehelp.edu.au/support/solutions/articles/6000106269-image-catalog#username). In our case the default username is `ubuntu`.
2.  The *IP address* of your instance. This can be found under the `IP address` column in the instances tab on your dashboard.
3.  The *path to the private key* on your computer. In our case it was `~/.ssh/nectarkey.pem`. (If you used your public key when setting up the key pair you won't need this).

### How to connect

Open a terminal and type:

```console
ssh -i ~/.ssh/nectarkey.pem <username>@<ip-address>
```

where you replace `<username>` with (in our case) `ubuntu`, and `<ip-address>` with the IP address for your instance.
> Note: the `-i` flag tells your connection to use the private key located at `~/.ssh/nectarkey.pem`.
> If you set up your VM with your public key then you do not need this and you can simply type the command `ssh <username>@<ip-address>`.

If you are connection for the first time it will ask for confirmation before connecting. Simply type `yes` and it will add your VM to the list of `known_hosts` on your local machine.

**You should now be successfully inside your new VM!**


### Add new host to SSH config file
To make it easier to connect to your VM via ssh, we can add it as a host in your ssh config file.

Open the file `~/.ssh/config` with your favourite editor, e.g. `nano`

```console
nano ~/.ssh/config
```

You may already have some configuration options listed.
Let's add a new one at the top, which should look something like this:

```bash
Host nectar
   HostName = <ip-address>
   User = ubuntu
   ForwardX11 = yes
   IdentityFile ~/.ssh/nectarkey.pem
```
where you should replace `<ip-address>` with the IP you found for your VM, and `nectar` is the *alias* we have given the VM (but you can choose a different name).

We can now connect to our VM much easier by typing

```console
ssh nectar
```