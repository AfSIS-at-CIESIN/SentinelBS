# !/bin/bash

for folder in ./dependencies/*
do
  pushd $folder
  python setup.py install --user
  if [[ $? -eq 0 ]]; then
    echo 'pkg '$folder' succeeded'
  else
    echo 'pkg '$folder' failed'
  fi
  popd
done
