# Cloud Automation
Before you start trying to write a complicated program or script for managing your cloud resources using the OpenStack client, consider some of these cloud automation tools that already exist which might make your life easier.

## Terraform
[Terraform](https://www.terraform.io/){target="_blank"} is an "Infrastructure as Code" software tool that you can use to provision and manage your cloud resources. It is particularly useful when managing a large number of complex resources, such as a cluster of VMs on an advanced network. Instead of creating resources manually, you write simple declarative configuration files, and Terraform takes care of the rest. This makes it easy to collaborate and share your configuration, version your infrastructure, and ensures your production is reproducible.

### Create
For example, instead of manually creating a network, subnet, router, floating IP, VMs, and configuring all the attachments, you can write the following configuration into a simple text file with a`.tf` extension, (which you can version control, and split into multiple files if you wish)

```python
#----- Provider configuration (OpenStack) ------------------------------------------
terraform {
  required_providers {openstack = {source = "terraform-providers/openstack"} }
  required_version = ">= 0.13"
}
provider "openstack" {}

#----- Instance --------------------------------------------------------------------
resource "openstack_compute_instance_v2" "instance" {
  depends_on  = [openstack_networking_router_interface_v2.attach]
  name        = "my_first_instance"
  image_name  = "NeCTAR CentOS 7 x86_64"
  flavor_name = "m3.small"
  key_pair    = "nectarkey"
  security_groups = ["default","SSH"]
  network {
    uuid = openstack_networking_network_v2.private_network.id
  }
}

#----- Advanced networking ---------------------------------------------------------
# Network
resource "openstack_networking_network_v2" "private_network" {
  name = "my-network"
}

# Subnet
resource "openstack_networking_subnet_v2" "subnet" {
  name       = "my-subnet"
  network_id = openstack_networking_network_v2.private_network.id
  cidr       = "10.0.0.0/24"
  ip_version = 4
}

# Router
data "openstack_networking_network_v2" "external_network" {
  name = "swinburne"
}
resource "openstack_networking_router_v2" "router" {
  name                = "my-router"
  external_network_id = data.openstack_networking_network_v2.external_network.id
}
resource "openstack_networking_router_interface_v2" "attach" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

#------- Floating IP ---------------------------------------------------------------
data "openstack_networking_port_v2" "port" {
  device_id = openstack_compute_instance_v2.instance.id
}
resource "openstack_networking_floatingip_v2" "floatip" {
  pool = "swinburne"
  port_id = data.openstack_networking_port_v2.port.port_id
}
```

Then, you'll need to initialise Terraform (only needs to be done once)
```console
$ terraform init
...
```
Once Terraform has finished initialising, your directory should contain a hidden terraform folder and lockfile, alongside your configuration file
```console
$ tree -aL 1
.
├── .terraform
├── .terraform.lock.hcl
└── my_cloud.tf
```

Remember to load your OpenStack credentials, and then you can apply your configuration

```console
$ source my-project-openrc.sh
$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.openstack_networking_port_v2.port will be read during apply
  # (config refers to values not yet known)
 <= data "openstack_networking_port_v2" "port"  {
      + all_fixed_ips          = (known after apply)
      + all_security_group_ids = (known after apply)
      + all_tags               = (known after apply)
      + allowed_address_pairs  = (known after apply)
      + binding                = (known after apply)
      + device_id              = (known after apply)
      + dns_assignment         = (known after apply)
      + extra_dhcp_option      = (known after apply)
      + id                     = (known after apply)
    }

  # openstack_compute_instance_v2.instance will be created
  + resource "openstack_compute_instance_v2" "instance" {
      + access_ip_v4        = (known after apply)
      + access_ip_v6        = (known after apply)
      + all_metadata        = (known after apply)
      + all_tags            = (known after apply)
      + availability_zone   = (known after apply)
      + flavor_id           = (known after apply)
      + flavor_name         = "m3.small"
      + force_delete        = false
      + id                  = (known after apply)
      + image_id            = (known after apply)
      + image_name          = "NeCTAR CentOS 7 x86_64"
      + key_pair            = "nectarkey"
      + name                = "my_first_instance"
      + power_state         = "active"

...
...

Plan: 6 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Enter `yes` and then wait for all your resources to be created. Terraform understands dependencies between different resources, so everything will be created in order. Once all the resources have been created, you should be able to see your VM

```console
$ openstack server list
+--------------------------------------+-------------------+---------+--------------------------------------+------------------------+----------+
| ID                                   | Name              | Status  | Networks                             | Image                  | Flavor   |
+--------------------------------------+-------------------+---------+--------------------------------------+------------------------+----------+
| 7eac05a6-7207-45ba-b7a4-bb27ff99146a | my_first_instance | ACTIVE  | my-network=10.0.0.173, 136.186.94.93 | NeCTAR CentOS 7 x86_64 | m3.small |
+--------------------------------------+-------------------+---------+--------------------------------------+------------------------+----------+
```

### Modify
If you wish to make changes to your configuration or add new resources, you simply add them to your current configuration and run `terraform apply` again. Terraform will determine what, if any, resources need to be updated, recreated, or deleted.

For example, if you wanted your instance to respond to `ping` requests, you'd need to add a new security group that allows ingress ICMP. You can declare this security group in your existing configuration file (or a new one in the same directory) and then amend the `security_groups` list of your instance to include the ID or name of your new security group

```python
...

#----- ICMP security group --------------------------------------------------------
resource "openstack_networking_secgroup_v2" "icmp" {
  name        = "icmp"
  description = "Allow ping requests"
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  security_group_id = openstack_networking_secgroup_v2.icmp.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "icmp"
}

#----- Instance --------------------------------------------------------------------
resource "openstack_compute_instance_v2" "instance" {
  depends_on  = [openstack_networking_router_interface_v2.attach]
  name        = "my_first_instance"
  image_name  = "NeCTAR CentOS 7 x86_64"
  flavor_name = "m3.small"
  key_pair    = "nectarkey"
  security_groups = ["default","SSH",openstack_networking_secgroup_v2.icmp.id]
  network {
    uuid = openstack_networking_network_v2.private_network.id
  }
}

...

```

Then you simply run `terraform apply` again
```
$ terraform apply
openstack_networking_network_v2.private_network: Refreshing state... [id=a6464ee1-0d35-4a1d-b3ee-0d371666fc37]
openstack_networking_router_v2.router: Refreshing state... [id=11b13c96-a6d3-409a-b2b4-41ac396fafea]
openstack_networking_subnet_v2.subnet: Refreshing state... [id=ce603296-2ff5-45fd-b3fe-23d336234581]
openstack_networking_router_interface_v2.attach: Refreshing state... [id=bba04287-b253-41c5-95d1-526ac203bf4d]
openstack_compute_instance_v2.instance: Refreshing state... [id=24d86aa3-11b0-44ee-848d-529208a885e6]
openstack_networking_floatingip_v2.floatip: Refreshing state... [id=741b354f-74f6-4b8f-a0e6-e2bb9d7c3ae5]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
  ~ update in-place
 <= read (data resources)

Terraform will perform the following actions:

  # data.openstack_networking_port_v2.port will be read during apply
  # (config refers to values not yet known)
 <= data "openstack_networking_port_v2" "port"  {
      - admin_state_up         = true -> null
      ~ all_fixed_ips          = [
          - "10.0.0.35",
        ] -> (known after apply)
      ~ all_security_group_ids = [
          - "7b7e6e86-6c91-443d-beed-ccdd8ea03b06",
          - "cdee8f28-e4a3-4268-af8a-bb19d45e808c",
        ] -> (known after apply)
      ~ all_tags               = [] -> (known after apply)
      ~ allowed_address_pairs  = [] -> (known after apply)
      ~ binding                = [
          - {
              - host_id     = ""
              - profile     = "null"
              - vif_details = {}
              - vif_type    = ""
              - vnic_type   = "normal"
            },
        ] -> (known after apply)
      - device_owner           = "compute:swinburne-01" -> null
      ~ dns_assignment         = [] -> (known after apply)
      ~ extra_dhcp_option      = [] -> (known after apply)
      ~ id                     = "c8009fa8-65ac-49e8-ba69-8dbc0239bbd9" -> (known after apply)
      - mac_address            = "fa:16:3e:71:59:00" -> null
      - network_id             = "a6464ee1-0d35-4a1d-b3ee-0d371666fc37" -> null
      - port_id                = "c8009fa8-65ac-49e8-ba69-8dbc0239bbd9" -> null
      - project_id             = "8e3b01d1e81c4de784a5cc9092d57576" -> null
      - region                 = "Melbourne" -> null
      - tenant_id              = "8e3b01d1e81c4de784a5cc9092d57576" -> null
        # (1 unchanged attribute hidden)
    }

  # openstack_compute_instance_v2.instance will be updated in-place
  ~ resource "openstack_compute_instance_v2" "instance" {
        id                  = "24d86aa3-11b0-44ee-848d-529208a885e6"
        name                = "my_first_instance"
      ~ security_groups     = [
          - "SSH",
          - "default",
        ] -> (known after apply)
        tags                = []
        # (13 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

  # openstack_networking_secgroup_rule_v2.icmp will be created
  + resource "openstack_networking_secgroup_rule_v2" "icmp" {
      + direction         = "ingress"
      + ethertype         = "IPv4"
      + id                = (known after apply)
      + port_range_max    = (known after apply)
      + port_range_min    = (known after apply)
      + protocol          = "icmp"
      + region            = (known after apply)
      + remote_group_id   = (known after apply)
      + remote_ip_prefix  = "0.0.0.0/0"
      + security_group_id = (known after apply)
      + tenant_id         = (known after apply)
    }

  # openstack_networking_secgroup_v2.icmp will be created
  + resource "openstack_networking_secgroup_v2" "icmp" {
      + all_tags    = (known after apply)
      + description = "Allow ping requests"
      + id          = (known after apply)
      + name        = "ping"
      + region      = (known after apply)
      + tenant_id   = (known after apply)
    }

Plan: 2 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

openstack_networking_secgroup_v2.icmp: Creating...
openstack_networking_secgroup_v2.icmp: Creation complete after 1s [id=215d9e5b-5c66-46cd-b7cb-7cc46f980d4d]
openstack_networking_secgroup_rule_v2.icmp: Creating...
openstack_compute_instance_v2.instance: Modifying... [id=24d86aa3-11b0-44ee-848d-529208a885e6]
openstack_networking_secgroup_rule_v2.icmp: Creation complete after 1s [id=94add620-1c7e-4d7b-b725-fa6111cb64b3]
openstack_compute_instance_v2.instance: Modifications complete after 3s [id=24d86aa3-11b0-44ee-848d-529208a885e6]
data.openstack_networking_port_v2.port: Reading... [id=c8009fa8-65ac-49e8-ba69-8dbc0239bbd9]
data.openstack_networking_port_v2.port: Read complete after 0s [id=c8009fa8-65ac-49e8-ba69-8dbc0239bbd9]

Apply complete! Resources: 2 added, 1 changed, 0 destroyed.
```

Terraform will aim to alter your current cloud state to the new state that you've declared in your configuration files, taking care of all the API calls to make it happen.

### Destroy

If you want to completely remove all your resources, Terraform can do that for you with a single command

```console
$ terraform destroy

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # openstack_compute_instance_v2.instance will be destroyed
  - resource "openstack_compute_instance_v2" "instance" {
      - access_ip_v4        = "10.0.0.35" -> null
      - all_metadata        = {} -> null
      - all_tags            = [] -> null
      - availability_zone   = "swinburne-01" -> null
      - flavor_id           = "92e5a7b0-25a2-43bb-83c3-f714e7b58203" -> null
      - flavor_name         = "m3.small" -> null
      - force_delete        = false -> null
      - id                  = "24d86aa3-11b0-44ee-848d-529208a885e6" -> null
      - image_id            = "f14c6d0c-7967-4534-b035-9704c79393f2" -> null
      - image_name          = "NeCTAR CentOS 7 x86_64" -> null
      - key_pair            = "nectarkey" -> null
      - name                = "my_first_instance" -> null
      - power_state         = "active" -> null
      - region              = "Melbourne" -> null
      - security_groups     = [
          - "215d9e5b-5c66-46cd-b7cb-7cc46f980d4d",
          - "SSH",
          - "default",
        ] -> null
      - stop_before_destroy = false -> null
      - tags                = [] -> null

...

Plan: 0 to add, 0 to change, 8 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

openstack_networking_floatingip_v2.floatip: Destroying... [id=741b354f-74f6-4b8f-a0e6-e2bb9d7c3ae5]
openstack_networking_secgroup_rule_v2.icmp: Destroying... [id=94add620-1c7e-4d7b-b725-fa6111cb64b3]
openstack_networking_secgroup_rule_v2.icmp: Destruction complete after 6s
openstack_networking_floatingip_v2.floatip: Destruction complete after 6s
openstack_compute_instance_v2.instance: Destroying... [id=24d86aa3-11b0-44ee-848d-529208a885e6]
openstack_compute_instance_v2.instance: Still destroying... [id=24d86aa3-11b0-44ee-848d-529208a885e6, 10s elapsed]
openstack_compute_instance_v2.instance: Destruction complete after 11s
openstack_networking_router_interface_v2.attach: Destroying... [id=bba04287-b253-41c5-95d1-526ac203bf4d]
openstack_networking_secgroup_v2.icmp: Destroying... [id=215d9e5b-5c66-46cd-b7cb-7cc46f980d4d]
openstack_networking_secgroup_v2.icmp: Destruction complete after 9s
openstack_networking_router_interface_v2.attach: Still destroying... [id=bba04287-b253-41c5-95d1-526ac203bf4d, 10s elapsed]
openstack_networking_router_interface_v2.attach: Destruction complete after 10s
openstack_networking_router_v2.router: Destroying... [id=11b13c96-a6d3-409a-b2b4-41ac396fafea]
openstack_networking_subnet_v2.subnet: Destroying... [id=ce603296-2ff5-45fd-b3fe-23d336234581]
openstack_networking_router_v2.router: Destruction complete after 7s
openstack_networking_subnet_v2.subnet: Destruction complete after 9s
openstack_networking_network_v2.private_network: Destroying... [id=a6464ee1-0d35-4a1d-b3ee-0d371666fc37]
openstack_networking_network_v2.private_network: Destruction complete after 7s

Destroy complete! Resources: 8 destroyed.
```

## Packer
[Packer](https://www.packer.io/){target="_blank"} is a software tool for building automated machine images. It encourages you to automate the creation and maintenance of pre-baked machine images you can launch instances from, which have all your required software packages pre-installed and pre-configured. OpenStack is just one of the many 'builders' Packer can interface with, and it also integrates natively with a number of configuration management system such as Ansible and Puppet.

Packer uses a simple JSON template file and roughly follows these steps when executed:

1. Launches an instance from an existing image.
2. Connects to the instance and runs a configuration management tool (or shell script) to install and configure software.
3. Pauses the instance and takes a snapshot, saving it as a new reusable image.
4. Terminates the instance.

In the case of OpenStack, Packer also takes care of creating (and subsequently deleting) temporary keypairs to provide access to instance while the image is being built, making your life easier.

Below is an example of a Packer template, `packer.json`:
```json
{
  "builders": [
    {
      "name": "my_image",
      "type": "openstack",
      "communicator": "ssh",
      "ssh_username": "ec2-user",
      "source_image_name": "NeCTAR CentOS 7 x86_64",
      "image_name": "my_image",
      "instance_name": "packer_image_build",
      "flavor": "m3.small",
      "security_groups": [
        "default",
        "SSH"
      ]
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": ["echo 'Do some installation/configuration'"]
    }
  ]
}
```
Which produces the following output when executed (remember to load your OpenStack credentials first)

```console
$ source my-project-openrc.sh
$ packer build packer.json
my_image: output will be in this color.

==> my_image: Loading flavor: m3.small
    my_image: Verified flavor. ID: 92e5a7b0-25a2-43bb-83c3-f714e7b58203
==> my_image: Creating temporary keypair: packer_5fd179b4-9128-d910-30ff-c4b401fd60a4 ...
==> my_image: Created temporary keypair: packer_5fd179b4-9128-d910-30ff-c4b401fd60a4
    my_image: Found Image ID: f14c6d0c-7967-4534-b035-9704c79393f2
==> my_image: Launching server...
==> my_image: Launching server...
    my_image: Server ID: 3fcdd3fd-f473-4e87-9b2f-66c2b0cc4bf2
==> my_image: Waiting for server to become ready...
    my_image: Floating IP not required
==> my_image: Using ssh communicator to connect: 136.186.108.158
==> my_image: Waiting for SSH to become available...
==> my_image: Connected to SSH!
==> my_image: Provisioning with shell script: /var/folders/hp/b4hrd2nn7pn63znv9sjvp5gw2sck31/T/packer-shell717126813
    my_image: Do some installation/configuration
==> my_image: Stopping server: 3fcdd3fd-f473-4e87-9b2f-66c2b0cc4bf2 ...
    my_image: Waiting for server to stop: 3fcdd3fd-f473-4e87-9b2f-66c2b0cc4bf2 ...
==> my_image: Creating the image: my_image
    my_image: Image: 7f866629-8fe7-4e24-8bb2-285a25e2d4ba
==> my_image: Waiting for image my_image (image id: 7f866629-8fe7-4e24-8bb2-285a25e2d4ba) to become ready...
==> my_image: Terminating the source server: 3fcdd3fd-f473-4e87-9b2f-66c2b0cc4bf2 ...
==> my_image: Deleting temporary keypair: packer_5fd179b4-9128-d910-30ff-c4b401fd60a4 ...
Build 'my_image' finished after 2 minutes 18 seconds.

==> Wait completed after 2 minutes 18 seconds

==> Builds finished. The artifacts of successful builds are:
--> my_image: An image was created: 7f866629-8fe7-4e24-8bb2-285a25e2d4ba
```

You should then be able to see your new image in the list of images available to your project
```console
$ openstack image list
+--------------------------------------+-------------------------------+--------+
| ID                                   | Name                          | Status |
+--------------------------------------+-------------------------------+--------+
| 5b7fab75-6bbb-4ddf-9587-153d3ff34ba7 | Fedora-AtomicHost-29-20190121 | active |
| f284a08e-d588-4acb-ba6c-3c1ebbbc69fa | NeCTAR CentOS 6 x86_64        | active |
| f14c6d0c-7967-4534-b035-9704c79393f2 | NeCTAR CentOS 7 x86_64        | active |
...
...
| f8a27137-5679-4967-8008-fc8336de4a6d | fedora-coreos-32              | active |
| 7f866629-8fe7-4e24-8bb2-285a25e2d4ba | my_image                      | active |
+--------------------------------------+-------------------------------+--------+
```

## Ansible
[Ansible](https://www.ansible.com/){target="_blank"} is an open source IT automation engine, which allows you to automate repetitive system administration tasks. It only requires Python and SSH to be installed on systems that you wish to manage. Ansible uses simple YAML 'playbooks', which you can version control, making your configuration reproducible and easy to read. It comes with a large number of 'modules' that can do almost any administrative task you can think of.

For example, say you have a number of machines on your cloud that you wish to keep up to date and ensure that Nginx is installed on each of them. Instead of manually connecting to each machine and doing the updates, you can write a simple playbook that uses the [yum module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/yum_module.html){target="_blank"}:

```yaml
---

- name: This is my playbook
  hosts: all
  gather_facts: yes
  become: no

  tasks:

    - name: Upgrade
      become: yes
      yum:
        name: '*'
        state: latest
        update_cache: yes

    - name: Ensure these packages are installed and latest
      become: yes
      yum:
        name:
          - nginx
        state: latest
```

Then, declare the connection details for each of the instances you wish to manage in an 'inventory':
```yaml
---

all:
  hosts:
    VM_0:
      ansible_host: 136.186.108.210
    VM_1:
      ansible_host: 136.186.108.16
    VM_2:
      ansible_host: 136.186.108.204
    VM_3:
      ansible_host: 136.186.108.64
    VM_4:
      ansible_host: 136.186.108.55
  vars:
    ansible_user: ec2-user
    ansible_ssh_common_args: -o StrictHostKeyChecking=no
```

Run the playbook, using the inventory you created, and watch ansible do its magic.
``` console
$ ansible-playbook -i my_inventory.yml my_playbook.yml

PLAY [This is my playbook] ********************************************************************************************

TASK [Gathering Facts] ************************************************************************************************
ok: [VM_1]
ok: [VM_2]
ok: [VM_3]
ok: [VM_4]
ok: [VM_0]

TASK [Upgrade] ********************************************************************************************************
changed: [VM_2]
changed: [VM_4]
changed: [VM_1]
changed: [VM_3]
changed: [VM_0]

TASK [Ensure these packages are installed and latest] *****************************************************************
changed: [VM_2]
changed: [VM_1]
changed: [VM_3]
changed: [VM_0]
changed: [VM_4]

PLAY RECAP ************************************************************************************************************
VM_0                       : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
VM_1                       : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
VM_2                       : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
VM_3                       : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
VM_4                       : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

At the end, Ansible will show you a recap of what happened on each server. If you rerun the playbook, Ansible will only repeat tasks if they are required to achieve the desired state defined by your playbook.

```console
$ ansible-playbook -i my_inventory.yml my_playbook.yml

PLAY [This is my playbook] ********************************************************************************************

TASK [Gathering Facts] ************************************************************************************************
ok: [VM_4]
ok: [VM_0]
ok: [VM_1]
ok: [VM_3]
ok: [VM_2]

TASK [Upgrade] ********************************************************************************************************
ok: [VM_2]
ok: [VM_4]
ok: [VM_1]
ok: [VM_0]
ok: [VM_3]

TASK [Ensure these packages are installed and latest] *****************************************************************
ok: [VM_2]
ok: [VM_3]
ok: [VM_1]
ok: [VM_4]
ok: [VM_0]

PLAY RECAP ************************************************************************************************************
VM_0                       : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
VM_1                       : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
VM_2                       : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
VM_3                       : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
VM_4                       : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
