#!/bin/sh

# Disable Strict Host checking for non interactive git clones
mkdir -p -m 0700 /root/.ssh
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

# Set custom WORKDIR
if [ -z "$WORKDIR" ]; then
 WORKDIR=/app
fi

# Setup git variables
if [ ! -z "$GIT_EMAIL" ]; then
 git config --global user.email "$GIT_EMAIL"
fi
if [ ! -z "$GIT_NAME" ]; then
 git config --global user.name "$GIT_NAME"
 git config --global push.default simple
fi

# Dont pull code down if the .git folder exists
if [ ! -d "/app/.git" ]; then
 # Pull down code from git for our site!
 if [ ! -z "$GIT_REPO" ]; then
   # Remove the test index file
   rm -Rf /app/*
   if [ ! -z "$GIT_BRANCH" ]; then
     if [ -z "$GIT_USERNAME" ] && [ -z "$GIT_PERSONAL_TOKEN" ]; then
       git clone --recursive -b $GIT_BRANCH $GIT_REPO /app/
     else
       git clone --recursive -b ${GIT_BRANCH} https://${GIT_USERNAME}:${GIT_PERSONAL_TOKEN}@${GIT_REPO} /app
     fi
   else
     if [ -z "$GIT_USERNAME" ] && [ -z "$GIT_PERSONAL_TOKEN" ]; then
       git clone --recursive $GIT_REPO /app/
     else
       git clone --recursive https://${GIT_USERNAME}:${GIT_PERSONAL_TOKEN}@${GIT_REPO} /app
     fi
   fi
 fi
else
 if [ ! -z "$GIT_REPULL" ]; then
   git -C /app rm -r --quiet --cached /app
   git -C /app fetch --all -p
   git -C /app reset HEAD --quiet
   git -C /app pull
   git -C /app submodule update --init
 fi
fi

## Install PIP requirements
if [ -f "$WORKDIR/requirements.txt" ] ; then
  cd $WORKDIR && pip install --no-cache-dir -r requirements.txt && echo "PIP requirements installed"
fi

# Run custom scripts
if [[ "$RUN_SCRIPTS" == "1" ]] ; then
  if [ -d "/app/scripts/" ]; then
    # make scripts executable incase they aren't
    chmod -Rf 750 /app/scripts/*
    # run scripts in number order
    for i in `ls /app/scripts/`; do /app/scripts/$i ; done
  else
    echo "Can't find script directory"
  fi
fi

# Finally, run python script
cd $WORKDIR
if [ ! -z "$PYTHON_CMD" ]; then
  python $PYTHON_CMD
else
  echo "No PYTHON_CMD environment variable found. Printing Python version info instead."
  python --version
fi