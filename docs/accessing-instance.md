# Accessing your Instance/Virtual Machine via SSH

!!! note
    These instruction are for **Unix** based systems such as **Ubuntu** or **MacOS**. For **Windows** systems, users will need to do something similar but via **PuTTY + SSH**.

Before you can access your virtual machine, you need to know a few pieces of information:

1.  The *username* for your instance. The default usernames for the base images available on Nectar can be found [here](https://support.ehelp.edu.au/support/solutions/articles/6000106269-image-catalog#username). In our case the default username is `ubuntu`.
2.  The *IP address* of your instance. This can be found under the `IP address` column in the instances tab on your dashboard.
3.  The *path to the private key* on your computer. In our case it was `~/.ssh/nectarkey.pem`.

### How to connect

Open a terminal and type:

```console
ssh -i ~/.ssh/nectarkey.pem <username>@<ip-address>
```

where you replace `<username>` with (in our case) `ubuntu`, and `<ip-address>` with the IP address for your instance.

!!! info
    The `-i` flag tells your connection to use the private key located at `~/.ssh/nectarkey.pem`.
    If you used your default public key from your local machine when setting up the key pair you will not need this, and you can simply type the command `ssh <username>@<ip-address>`.

If you are connection for the first time it will ask for confirmation before connecting. Simply type `yes` and it will add your VM to the list of `known_hosts` on your local machine.

**You should now be successfully inside your new VM!**


### Add new host to SSH config file
To make it easier to connect to your VM, we can add it as a host to your ssh config file.

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
where you should replace `<ip-address>` with the IP you found for your VM.

We have chosen `nectar` as the *alias* for our VM, but you can choose whatever name you like.

We can now ssh into our machine much easier by simply typing
```console
ssh nectar
```

!!! seealso "See also"
    For more information regarding SSH configurations, check out this guide at [https://www.digitalocean.com/community/tutorials/how-to-configure-custom-connection-options-for-your-ssh-client](https://www.digitalocean.com/community/tutorials/how-to-configure-custom-connection-options-for-your-ssh-client).