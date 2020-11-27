# Accessing your Instance/Virtual Machine via SSH

!!! note
    These instruction are for **Unix** based systems such as **Ubuntu** or **MacOS**. For **Windows** systems, users will need to do something similar but via **PuTTY + SSH**.

Before you can access your virtual machine, you need to know a few pieces of information:

1.  The *username* for your instance. The default usernames for the base images available on Nectar can be found [here](https://support.ehelp.edu.au/support/solutions/articles/6000106269-image-catalog#username){target="_blank"}. In our case the default username is `ubuntu`.
2.  The *IP address* of your instance. This can be found under the `IP address` column in the instances tab on your dashboard.
3.  The *path to the private key* on your computer. In our case it was `~/.ssh/nectarkey.pem`.

### How to connect

Open a terminal and type:

```console
ssh -i ~/PATH/TO/YOUR/KEY <username>@<ip-address>
```

where you should replace `~/PATH/TO/YOUR/KEY` with the path to your ssh key, `<username>` with (in our case) `ubuntu`, and `<ip-address>` with the IP address for your instance. For **example**,
```console
ssh -i ~/.ssh/nectarkey.pem ubuntu@115.146.87.187
```

!!! info
    The `-i` flag tells your connection to use a specific private key.
    If you used the **default** public key from your local machine when setting up the key pair you will not need this, and you can simply type the command `ssh <username>@<ip-address>`.

If you are connecting for the first time it will ask for confirmation before connecting. Simply type `yes` and it will add your VM to the list of `known_hosts` on your local machine.

!!! tip "Success"
    You should now be inside your new VM! To exit, press `ctrl + d` or type `exit` and hit enter.
    Remember to set your timezone, e.g. `sudo timedatectl set-timezone 'Australia/Melbourne'` (you can list all available timezones with `timedatectl list-timezones`).
