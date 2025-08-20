#!/bin/bash

for gitpath in /home/git /home/git/ansible_roles ;do
  if [ -e $gitpath ]; then
    cd $gitpath
    for repo in $(ls -1 | grep '\.git$'); do
      reponame=$(echo $repo | awk -F. '{print $1}')
      echo "repo.url=${reponame}"
      echo "repo.path=${gitpath}/${repo}"
      echo "repo.desc=$(cat $gitpath/${repo}/description)"
      echo
    done
  fi
done

