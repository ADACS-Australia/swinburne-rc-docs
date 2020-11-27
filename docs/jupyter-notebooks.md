# How to view Jupyter notebooks
If you wish to run a Jupyter notbook on your virtual machine, you can easily view it in your web browser, on your local machine, via **ssh port forwarding/tunnelling**.

### Port forwarding
When launching a jupyter notebook server, it will typically be run on port `8888`. We can *forward* this port on the *remote* machine to a port on our *local* machine. In this case, we will use port `8000` of our local machine.

Let's connect to our instance again, but this time type
```console
ssh -L 8000:localhost:8888 nectar
```
where the `-L` option specifies the ports to connect i.e. creates a tunnel. You shouldn't see anything different to when you connected previously.

Now launch a Jupyter notebook on the remote machine
```console
jupyter notebook --no-browser --port=8888
```
We specify the port to be sure that it is the same as the one that we setup our ssh tunnel with, and we requested no web browser, since the remote machine (typically) doesn't have one.

This will produce some output. Take note of the `token` that gets generated (it should be a long string of letters and numbers).

### Viewing the notebook

Open up a web browser and navigate to [http://localhost:8000](http://localhost:8000){target="_blank"}. This should bring up jupyter notebook, but it will request you enter the `token` before you can continue.

**Alternatively**, you can append the token to the end of the url like so [http://localhost:8000/?token=YOUR_TOKEN](http://localhost:8000/?token=YOUR_TOKEN){target="_blank"}, where you should replace `YOUR_TOKEN` with your token.

!!! seealso "See also"
    For more information regarding remote connections to jupyter notebooks, check out this guide [https://www.digitalocean.com/community/tutorials/how-to-install-run-connect-to-jupyter-notebook-on-remote-server](https://www.digitalocean.com/community/tutorials/how-to-install-run-connect-to-jupyter-notebook-on-remote-server){target="_blank"}.
