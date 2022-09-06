# Custom ADACS Apps
It is also possible to build your own custom applications and upload them to the Nectar Application Catalogue. Below are some custom packages put together by the ADACS team that you can upload to your Nectar project.

## GitHub and GitLab self-hosted runners
GitHub and GitLab allow users to host their own runners for running Continuous Integration and Continuos Deployment (CI/CD) workflows. This might be useful if you require a custom environment to run your jobs, or if you need more computational resources than what the native runners provide.

Setting up your own runner on the Nectar Cloud and registering them with GitHub or GitLab is fairly straightforward to do manually, but we've create some packages that will automate the process for you.

### Upload
To be able to use the apps, you'll need to upload them your Nectar Application Catalogue. The applications are packaged in zip archives, which you can find on the releases pages of our GitHub and GitLab self-hosted runner apps:

- <https://github.com/ADACS-Australia/murano-github-runner/releases>{target="_blank"}
- <https://github.com/ADACS-Australia/murano-gitlab-runner/releases>{target="_blank"}

Find the zip archive from the latest release, and copy its link address (you can do this by right clicking on it).

![](images/copy_link_address.png)

On your Nectar Dashboard, navigate to `Applications > Manage > Packages`.
From here you can upload, manage and delete custom apps. To upload a new application, select `+ Import Package`.
(Or click [here](https://dashboard.rc.nectar.org.au/app-catalog/packages/upload){target="_blank"}).

![](images/import_package.png)

Then select URL as the source and paste the link address of the zip archive, and hit `Next`. You will then be able to modify the package name, tags and description if you wish to. Select `Next` to accept the defaults. You can then choose a category for your package. This is optional also, and only used for filtering apps in the catalogue. Press `Create` to finish uploading your application.

### Launch App
Once you have uploaded your package, it should become available in the [application catalogue](https://dashboard.rc.nectar.org.au/app-catalog/catalog/){target="_blank"} on the dashboard.

![](images/uploaded_apps.png)

To launch your self-hosted runner, select quick-deploy, and fill out the relevant information in the forms.

You will require a **registration token** that you can find in your GitHub or GitLab repository settings.

- On GitHub, go to `Settings > Actions`, in the left sidebar, under `Actions`, click `Runners`, then click `New self-hosted runner`. (See [documentation](https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners#adding-a-self-hosted-runner-to-a-repository){target="_blank"}).
- On GitLab, go to `Settings > CI/CD` and expand the `Runners` section. (See [documentation](https://docs.gitlab.com/runner/register/index.html#requirements){target="_blank"}).

Once you've filled out all the forms and selected the flavour for your VM, your application will be added to an "environment" that you can deploy. It should look something like this:

![](images/deploy_environment.png)

Select `Deploy This Environment` to begin the automation procedure. This involves spinning up the virtual machine, installing the self-hosted runner software and registering the runner using the token provided. It may take a few minutes.

Once the procedure is complete, your self-hosted runner should appear in your GitHub or GitLab repository settings, and will be ready to receive jobs.

## The Littlest JupyterHub
This murano application installs and configures a server with [The Littlest JupyterHub](https://tljh.jupyter.org/en/latest/){target="_blank"}: <br />
*"A simple JupyterHub distribution for a small (0-100) number of users on a single server."*

JupyterHub is a great platform for getting students to easily use Jupyter notebooks. It avoids the fuss of having them install and maintain Python + Jupyter on their individual computers.

For more details about our exact configuration, see: <br />
- <https://github.com/ADACS-Australia/murano-jupyterhub>{target="_blank"} <br />
- <https://github.com/ADACS-Australia/openstack-tljh>{target="_blank"}

### Upload
As with the [self-hosted runners above](#github-and-gitlab-self-hosted-runners), each release contains a zip file that can be uploaded to your Nectar account.
You can upload a release directly using a URL.
From the dashboard, navigate to [Applications > Manage > Packages > Import Package](https://dashboard.rc.nectar.org.au/app-catalog/packages/upload){target="_blank"} and choose URL as the Package Source.
Paste the following link address:<br />
```shell
https://github.com/ADACS-Australia/murano-jupyterhub/releases/latest/download/jupyterhub.zip
```

Alternatively, go to the [releases](https://github.com/ADACS-Australia/murano-jupyterhub/releases){target="_blank"} and select your preferred release. (Under assets, right click on `jupyterhub.zip` and then copy the link address).

### Launch app
Once uploaded, the package will become available in the [application catalogue](https://dashboard.rc.nectar.org.au/app-catalog/catalog/){target="_blank"}. Select quick deploy and follow the prompts.

![](images/tljh-quick-deploy.png)

Note that you will need to provide an email address, which will be used to register an HTTPS certificate with [Let's Encrypt](letsencrypt.org){target="_blank"}. You may receive an email from them when your certificate is due to expire.

You can also optionally provide a volume for the data storage of this application. If provided, all user data will be stored on this volume and will persist even if the application is deleted. You'll need to create an empty volume before launching the app. See "[Creating a volume](volumes.md#creating-a-volume){target="_blank"}" (don't attach or create a filesystem on the volume, the app will do that for you).

Once you've filled in forms, press `Deploy This Environment` to launch the app.

![](images/tljh-deploy.png)

This may take up to 15 minutes, after which your JupyterHub will be available at your chosen domain name.

![](images/tljh-domain-name.png)

## Destroying an app environment
You can destroy the application enviroment from `Application > Applications > Environments` page on your Nectar Dashboard.
This will destroy the VM and any other cloud resources associated with it (such as security groups) in one go. We recommend removing them in this way, rather than destroying each component manually, one-by-one.
