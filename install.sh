#!/bin/sh -e

UPDATE_FILES="0x13.bin"

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

echo
echo '*** Applying microcode updates'
for i in $UPDATE_FILES; do
  cat "$i" > /dev/cpu/microcode
done;

# Currently only supports Debian for persistence, but we could add more later
PERSIST=0
if [ "$1" = '--persist-debian' ]; then
  echo '*** Setting up persistence'
  PERSIST=1
  IUCODE_FW_DIR=/lib/firmware/intel-ucode
  IUCODE_TOOL=/usr/sbin/iucode-tool
  UPDATE_INITRAMFS=/usr/sbin/update-initramfs
  if [ ! -d "$IUCODE_FW_DIR" ]; then
    echo 'Please install intel-microcode before continuing'
    exit 1;
  elif [ ! -x "$IUCODE_TOOL" ]; then
    echo 'Please install iucode-tool before continuing'
    exit 1;
  elif [ ! -x "$UPDATE_INITRAMFS" ]; then
    echo 'Cannot find update-initramfs. Is this a Debian-based system?'
    exit 1;
  fi
  echo 'FYI: You can safely ignore warnings about files already existing.'
  # iucode-tool does not overwrite existing files
  for i in $UPDATE_FILES; do
    "$IUCODE_TOOL" -q --write-firmware="$IUCODE_FW_DIR" "$i" || true
  done
  echo '*** Running update-initramfs'
  "$UPDATE_INITRAMFS" -u -k "$(uname -r)"
fi

echo
echo '*** Current microcode version information:'
grep microcode /proc/cpuinfo

echo
echo 'No errors encountered.'
echo 'If the microcode version did not change, no update has been applied.'
if [ "$PERSIST" = 0 ]; then
  echo 'Make sure to re-run this script after every reboot or hibernation.'
fi
