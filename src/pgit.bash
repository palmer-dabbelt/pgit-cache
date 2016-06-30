#!/bin/bash

set -e

CACHE_TOP="@@TOP@@"

op="$1"
shift

case "$op" in
  clone)
    unset recursive
    for arg in "$@"
    do
      case "$arg" in
      "--recursive") recursive="$arg"; shift;;
      *) break ;;
      esac
    done
      
    remote_path="$1"
    cache_offset="$(echo "$remote_path" | sed 's!^https://\([A-Za-z0-9.]*\)/!\1/!' | sed 's!^git@\([A-Za-z0-9.]*\):!\1/!' | sed 's@[.]git$@@' | sed 's!^git://\([A-Za-z0-9.]*\)/!/\1/!')"

    cache_dir="$CACHE_TOP/$cache_offset"
    unset reference
    if test -d "$cache_dir"
    then
      echo "Using local cache: $cache_dir"
      reference="--reference $cache_dir"
    fi

    git clone "$@" $reference

    if [[ "$recursive" != "" ]]
    then
      local_dir="$2"
      if [[ "$local_dir" == "" ]]
      then
        local_dir="$(basename "$cache_offset")"
      fi

      (
        cd $local_dir
	$0 smisur
      )
    fi
  ;;

  smisur)
    git submodule init
    git submodule sync
    git submodule status | while read info
    do
      local_path="$(echo "$info" | cut -d' ' -f2)"
      submodule_name="$(git config --file .gitmodules -l | grep "^submodule.*.path=$local_path$" | cut -d. -f2)"
      remote_path="$(git config -l | grep "^submodule.$submodule_name.url=" | cut -d= -f2-)"
      cache_offset="$(echo "$remote_path" | sed 's!^https://\([A-Za-z0-9.]*\)/!\1/!' | sed 's!^git@\([A-Za-z0-9.]*\):!\1/!' | sed 's@[.]git$@@' | sed 's!^git://\([A-Za-z0-9.]*\)/!/\1/!')"

      cache_dir="$CACHE_TOP/$cache_offset"
      unset reference
      if test -d "$cache_dir"
      then
        echo "Using local cache: $cache_dir"
        reference="--reference $cache_dir"
      else
        echo "Unable to find local cache: $cache_dir"
      fi
      git submodule update --init $reference $local_path
      (
        cd $local_path
	$0 smisur
      )
    done
  ;;

  *)
    exec git $op "$@"
  ;;
esac
