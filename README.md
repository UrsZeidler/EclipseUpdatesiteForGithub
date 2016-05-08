# Eclipse update site for Github

This document describes a jenkis job to create an updatesite hosted on the gh-pages and also releases the ziped udatesite.
The main source for hosting the updatesite are from the last answer of this thread  http://stackoverflow.com/questions/2801567/is-it-possible-to-host-an-eclipse-update-site-on-github . 


* [prequisite](#prequisite)
  * [Add buckminster and ant](#1-add-buckminster-and-ant)
  * [activate the github pages for your project](#2-activate-the-github-pages-for-your-project)
  * [Create an api token](#3-create-an-api-token)
  * [Configure your jekins job](#3-configure-your-jekins-job)
    * [Source code Management](#source-code-management)
    * [Build Environment](#build-environment)
    * [Before release build](#before-release-build)
    * [Build](#build)
    * [After successful release build](#after-successful-release-build)
  * [Trigger the release](#trigger-the-release)
  * [Activate the release](#activate-the-release)
  


#### prequisite

* jenkins  (https://jenkins.io/index.html) an already runnig job to create the p2 updatesite (can be a maven build or done with buckminster) and the following plugins installed :
 * Git Plugin  https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin
 * Parameterized Trigger Plugin https://wiki.jenkins-ci.org/display/JENKINS/Parameterized+Trigger+Plugin
 * Copy Artifact Plugin https://wiki.jenkins-ci.org/display/JENKINS/Copy+Artifact+Plugin
 * Buckminster PlugIn https://wiki.jenkins-ci.org/display/JENKINS/Buckminster+PlugIn
 * Release Plugin https://wiki.jenkins-ci.org/display/JENKINS/Release+Plugin
 * Ant Plugin https://wiki.jenkins-ci.org/display/JENKINS/Ant+Plugin
 * Maven Project Plugin https://wiki.jenkins-ci.org/display/JENKINS/Maven+Project+Plugin (when you use maven to build)

You will also need a shell environment which supports wget and curl. 
 
##### 1. Add buckminster and ant

The ant and buckminster plugins did not contain any working installation, instead it provides ways to install and manage them. This is very reasonable as it make it possible to have many versions installed and use different versions for different build jobs.
 
Add a working buckmister and ant installation. This is done on the "Configure System" page.   
 
 ![manage_jenkins](images/Manage_Jenkins.png) ==>  ![configure_jenkins](images/Configure_System.png) 

In jenkins 2 it is called ![configure_jenkins](images/global-tool-configuration.png).

Choose ![buckmister-installation-1](images/buckmister-installation-1.png) then ![buckmister-installation-3](images/buckmister-installation-3.png) to add an installation.

Use an automatic installation and give the java process some memory.

![buckmister-installation-2](images/buckmister-installation-2.png) 

The name you choose will point to the directory where the installation is stored. (Blanks will be converted to underscores). Take at least the version 4.2.

This path we later use in the bash script to mirror the update site.
In our example `/var/lib/jenkins/tools` is the base path where jenkins stores all the installed tools. 

The ant installation is straight forward like the buckminster installation. You may choose every version of ant as we use only the basics provided by any ant version.


##### 2. Activate the github pages for your project
 
This is a simple step described for example here: https://pages.github.com/.

##### 3. Create an api token

To create a release and push your artifact to githup you need an api token.
Open [Personal access tokens](https://github.com/settings/tokens)

![create_token](images/create_token.png)

Now create the token, name and configure it. We need access to the repository as we want to clone and push back some changes.

![configure_token](images/configure_token.png)

Create the token and copy it.

![copy_token](images/copy_token.png)


#### 3. Configure your jekins job

This is the main part. We go through this step by step. You will need the ant script contains in the `etc` folder of this project. Copy it to some place in in your project where it does not bother you.

###### Source code Management

We use github, of course, and we checkout the `*/gh-pages` branch, it is important to `Clean before checkout`
![Source_Code_Management](images/Source_Code_Management.png)


###### Build Environment

The build need to be a release build with two parameters, the version which will be used as the release version and a description for the release. Note that the description can't have multiple lines.

Both parameters will be used by the [ant script](https://github.com/UrsZeidler/EclipseUpdatesiteForGithub/blob/master/etc/build.xml).

![Build_Enviorment](images/Build_Enviorment.png) 


###### Before release build

Before we release we need to create the artifacts, the simples way is using the basic job of our project as this creates the updatesite.

![Before_release_build](images/Before_release_build.png) 

###### Build 

The main build action is to mirror the created update site in the gh-pages updatesite, with this the old update site will not get deleted instead the new updatesite will be merged in, so people can reverse the installation to an older version.

You will find the script in the `etc` folder of this project. Copy the content and adjust it to your needs and configuration.

There are two important variables to configure, at first the path to buckminster which is consisting of the main tool path `/var/lib/jenkins/tools` the `hudson.plugins.buckminster.BuckminsterInstallation` directory used by the buckminster plugin and the name of your installation here `bucky_4.2` in the script it is called `ECLIPSE`. 

The other variable `SOURCE` points to the created repository of the basic job accessible thru jenkins. To get the url simply move to the repository directory of the job building the update site.

![path-to-update-site](images/path-to-update-site.png)

The build action is `Execute shell`

![build_Execute_shell](images/build_Execute_shell.png) 

###### After successful release build

After we created the updatesite, first we need to commit the changes.

![Commit_updatesite](images/Commit_updatesite.png) 

And push it back to the gh-pages branch via the Git publisher.

![Git_publisher](images/Git_publisher.png)

Now we copy the ant script to the workspace with a simple wget from your repository. The ant script will use the github api to add the ziped updatesite on the release page and creating a release.

`wget https://raw.githubusercontent.com/UrsZeidler/uml2solidity/master/de.urszeidler.eclipse.solidity.master/etc/build.xml`

Adjust the path to your place of the ant script.

![Get_ant_script](images/Get_ant_script.png)

For this we copy the already created updatesite from the basic job in the workspace. Choose your file selector wisely to get only the updatesite and flatten the directories so the updatesite is in the root of the workspace. 

![Copy_artifacts_from_project](images/Copy_artifacts_from_project.png)

Finally we call the ant script, here we need the api token as we create a github release and push the artifact.

![Invoke_Ant](images/Invoke_Ant.png) 

Now save the job configuration as we are done.

### Trigger the release

To trigger the release choose ![release_job](images/release_job.png) which brings you to the `define release` page and set the release parameters.

![Define_release](images/Define_release.png) 


#### Activate the release

The ant script creates the release as a draft, so after the build the release is not visible to others.

Browse the the release page of your project, add the release information publish the release and your are done.

-----

Found a bug, a typo, a misleading description:
Feel free to open an [issue](https://github.com/UrsZeidler/EclipseUpdatesiteForGithub/issues).
