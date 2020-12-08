# Adding a host to your SSH config file
To make it easier to connect to your VM, we can add it as a host to your ssh config file.

On your local machine, open the file `~/.ssh/config` with your favourite editor, e.g. `nano`

```console
$ nano ~/.ssh/config
```

You may already have some configuration options listed.
Let's add a new one at the top, which should look something like this:

```console
Host nectar
   HostName = 115.146.87.187
   User = ubuntu
   IdentityFile = ~/.ssh/nectarkey.pem
```

We have chosen `nectar` as the *alias* for our VM, but you can choose whatever name you like. Make sure you replace each option with the correct information for **your** virtual machine.
Once you save the config file, you can ssh into your machine by simply typing

```console
$ ssh nectar
```

!!! tip
    Adding your VM as a host in your ssh config will also make other operations over ssh (such as `scp` or port forwarding) much simpler --- you can refer to the host by its alias, instead of having to specify its IP address and key location each time.
    For example, to copy a `local.file` to a `~/REMOTE/DIRECTORY/` you can just type `scp local.file nectar:~/REMOTE/DIRECTORY/`.

!!! seealso "See also"
    For more information regarding SSH configurations, check out this guide at [https://www.digitalocean.com/community/tutorials/how-to-configure-custom-connection-options-for-your-ssh-client](https://www.digitalocean.com/community/tutorials/how-to-configure-custom-connection-options-for-your-ssh-client){target="_blank"}.
