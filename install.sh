#!/bin/sh -e

if [ "$1" = '-h' -o "$1" = '--help' ]; then
  echo "sudo $0 [--help] [--persist-debian]"
  echo ''
  echo '--persist-debian: (EXPERIMENTAL) Persist fix across reboots. Only works'
  echo '                  on Debian or Debian-derived systems (eg. Ubuntu)'
  exit 0
fi

if [ "$(id -u)" != 0 ]; then
  echo 'Please run this script as root (eg. using sudo)'
  exit 1
fi

echo '*** Initial microcode version information:'
grep microcode /proc/cpuinfo

# Currently only supports Debian for persistence, but we could add more later
PERSIST=0
if [ "$1" = '--persist-debian' ]; then
  echo
  echo '*** Setting up persistence'
  PERSIST=1
  FW_DIR=/lib/firmware/intel-ucode
  UPDATE_INITRAMFS=/usr/sbin/update-initramfs
  if [ ! -d "$FW_DIR" ]; then
    echo 'Please install intel-microcode before continuing'
    exit 1;
  elif [ ! -x "$UPDATE_INITRAMFS" ]; then
    echo 'Cannot find update-initramfs. Is this a Debian-based system?'
    exit 1;
  fi
  echo 'FYI: You can safely ignore warnings about files already existing.'
  # -i prompts before overwriting, uses initramfs extension to disallow anything
  # but early loading
  cp -i 0x13.bin /lib/firmware/intel-ucode/06-47-01.initramfs

  echo
  echo '*** Running update-initramfs'
  "$UPDATE_INITRAMFS" -u -k "$(uname -r)"
fi

if [ "$PERSIST" = 0 ]; then
  echo
  echo '*** Applying microcode updates'
  echo 'This is potentially unsafe. If your machine locks up, try rebooting and'
  echo 'installing with `--persist-debian`.'
  echo
  echo 'Press [Enter] to continue'
  read IGNORED_VALUE
  cat 0x13.bin > /dev/cpu/microcode

  echo
  echo '*** Current microcode version information:'
  grep microcode /proc/cpuinfo

  echo
  echo 'No errors encountered.'
  echo 'Make sure to re-run this script after every reboot or hibernation.'
  echo 'If the microcode version did not change, no update has been applied.'
else
  echo
  echo 'No errors encountered.'
  echo 'Please reboot to finish installation. Then run'
  echo '`grep microcode /proc/cpuinfo`. You should be on version 0x13.'
fi
