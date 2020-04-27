# Security Groups

!!! note
    All incoming network traffic is blocked by default. In order to access you instance, you must apply a security group that allows SSH connections.

An SSH security group should already exist in your trial project. To check that it is there, click the `Network` tab on the left panel, and then select `Security Groups`.

You should see several items, including one named `ssh` with the description `Allow SSH`.

![](images/security_groups.png)

If you do not see this then select `+ Create Security Group` and follow the instructions [here](https://support.ehelp.edu.au/support/solutions/articles/6000055376-launching-virtual-machines#SecurityGroup) to create a security group that allows SSH connections.

