# GUIs and X11 Forwarding
To interact with graphical applications on your virtual machine, you can use *X11 forwarding* when connecting via SSH. You will require an X server on your local machine for this --- most Linux distributions will have one. (For MacOS you may need to install XQuartz, if it's not already installed, and Windows users can install and use Xming).

To enable X11 forwarding, simply add the `-X` option to your SSH command i.e.

```console
ssh -i ~/.ssh/nectarkey.pem -X <username>@<ip-address>
```
or
```console
ssh -X nectar
```

Alternatively, you can configure the host you created [previously](../ssh-config/) to always enable X11 forwarding. Just add the line `ForwardX11 = yes` to your host like so

```console
Host nectar
   HostName = <ip-address>
   User = ubuntu
   IdentityFile = ~/.ssh/nectarkey.pem
   ForwardX11 = yes
```

Then you can still connect with just
```console
ssh nectar
```
