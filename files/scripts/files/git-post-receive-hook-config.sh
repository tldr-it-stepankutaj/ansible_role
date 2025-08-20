#!/bin/bash

for gitpath in /home/git /home/git/ansible_roles ;do
  if [ -e $gitpath ]; then
    cd $gitpath
    for repo in $(ls -1 | grep '\.git$'); do
      reponame=$(echo $repo | awk -F. '{print $1}')
      cd $repo
      grep -c showrev config >/dev/null 2>/dev/null
      if [ $? -gt 0 ]; then
        echo "configuring ${reponame} repository"
        git config hooks.showrev "t=%s; printf 'https://git.wtnet.cz/cgit/${reponame}/commit/?id=%%s' \$t; echo;echo; git show -C \$t; echo"
      else
        echo "skipping..."
      fi
      cd $gitpath
      echo
    done
  fi
done

