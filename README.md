## Introduction

This is a Dockerfile to build a container image for python, with the ability to push and pull source code to and from git (including an optional automatic git pull whenever the container is restarted).

### Git repository

The source files for this project can be found here: [https://github.com/TheBoroer/docker-python](https://github.com/TheBoroer/docker-python)

If you have any improvements please submit a pull request.

### Docker hub repository

The Docker hub build can be found here: [https://hub.docker.com/u/boro/python/](https://hub.docker.com/u/boro/python/)

## Automated Builds

This repository uses Drone CI to automatically build and push multiple Python versions to Docker Hub. Every push to the `main` branch triggers builds for all supported Python versions.

### Build Process

- **CI/CD Platform**: Drone CI
- **Trigger**: Push to `main` branch
- **Build Strategy**: Parallel builds for each Python version using build args
- **Dockerfile**: Single Dockerfile with `ARG PYTHON_VERSION` for multi-version support
- **Registry**: Docker Hub (`boro/python`)

The build process uses Docker build arguments to dynamically select the Python base image version, ensuring all images have the same package set and configuration while supporting multiple Python versions.

## Versions

- **2.7**: Python 2.7.x
- **3.6**: Python 3.6.x
- **3.7**: Python 3.7.x
- **3.8**: Python 3.8.x
- **3.9**: Python 3.9.x
- **3.10**: Python 3.10.x
- **3.11**: Python 3.11.x
- **3.12**: Python 3.12.x
- **3.13**: Python 3.13.x

`.x` means it'll use the latest patch version available at the time this image was built.

All images are built from the official Python Alpine images and include the same comprehensive package set for development and deployment.

## Pulling from Docker Hub

Pull the latest Python 3.12 image:

```
docker pull boro/python:3.12
```

Or pull a specific Python version:

```
docker pull boro/python:3.11
docker pull boro/python:3.10
docker pull boro/python:3.9
```

View all available tags: [https://hub.docker.com/r/boro/python/tags](https://hub.docker.com/r/boro/python/tags)

## Running

To simply run the container with Python 3.12:

```
sudo docker run -d boro/python:3.12
```

Or run with a specific Python version:

```
sudo docker run -d boro/python:3.11
sudo docker run -d boro/python:2.7
```

### Installing PIP modules/requirements

To install modules/components for your python application to run simply include a `requirements.txt` file in the root of your application. The container will then install the components on start.

### Available Configuration Parameters

The following flags are a list of all the currently supported options that can be changed by passing in the variables to docker with the -e flag.

- **GIT_REPO** : URL to the repository containing your source code. If you are using a personal token, this is the https URL without https://, e.g github.com/project/ for ssh prepend with git@ e.g git@github.com:project.git
- **GIT_BRANCH** : Select a specific branch (optional)
- **GIT_EMAIL** : Set your email for code pushing (required for git to work)
- **GIT_NAME** : Set your name for code pushing (required for git to work)
- **GIT_PERSONAL_TOKEN** : Personal access token for your git account (required for HTTPS git access)
- **GIT_USERNAME** : Git username for use with personal tokens. (required for HTTPS git access)
- **GIT_REPULL** : Set to 1 to perform a git pull every time the container restarts
- **WORKDIR** : Change the default webroot directory from `/app` to your own setting
- **RUN_SCRIPTS** : Set to 1 to execute bash scripts in the `$WORKDIR/scripts` folder
- **PYTHON_CMD** : set to the command you want to follow the python command. E.g. if set to "--version" it would run python --version in the container and print the python version.
- **RUN_CMD** : set to the shell/bash command you want to run (works only if no PYTHON_CMD is specified).

### Dynamically Pulling code from git

One of the nice features of this container is its ability to pull code from a git repository with a couple of environmental variables passed at run time.

REQUIRED: To create a personal access token on Github follow this [guide](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).

#### Personal Access token

You can pass the container your personal access token from your git account using the **GIT_PERSONAL_TOKEN** flag. This token must be setup with the correct permissions in git in order to push and pull code.

Since the access token acts as a password with limited access, the git push/pull uses HTTPS to authenticate. You will need to specify your **GIT_USERNAME** and **GIT_PERSONAL_TOKEN** variables to push and pull. You'll need to also have the **GIT_EMAIL**, **GIT_NAME** and **GIT_REPO** common variables defined.

```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' boro/python:3.12
```

To pull a repository and specify a branch add the **GIT_BRANCH** environment variable:

```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' -e 'GIT_BRANCH=stage' boro/python:3.12
```

### Scripting

There is often an occasion where you need to run a bash script on code to do a transformation once code lands in the container. For this reason there's scripting support. By including a scripts folder in your git repository and passing the **RUN_SCRIPTS=1** flag to your command line the container will execute your bash scripts after code is pulled via git.

## Special Git Features

Specify the `GIT_EMAIL` and `GIT_NAME` variables for this to work. They are used to set up git correctly and allow the following commands to work.

### Push code to Git

To push code changes made within the container back to git run:

```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/push
```

### Pull code from Git (Refresh)

In order to refresh the code in a container and pull newer code from git run:

```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/pull
```

### Using environment variables

To set the variables pass them in as environment variables on the docker command line.

Example:

```
sudo docker run -d -e 'YOUR_VAR=VALUE' boro/python:3.12
```

## Logging and Errors

### Logging

All logs should now print out in stdout/stderr and are available via the docker logs command:

```
docker logs <CONTAINER_NAME>
```

### WorkDir

You can set your workdir in the container to anything you want using the `WORKDIR` variable e.g -e "WORKDIR=/app/some/other/director". By default code is checked out into /app/ so if your git repository does not have code in the root you'll need to use this variable.
