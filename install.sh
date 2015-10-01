#!/bin/sh -eu

if [ "$(id -u)" != "0" ]; then
  echo 'Please run this script as root (eg. using sudo)'
  exit 1
fi

echo '*** Current microcode version information:'
grep microcode /proc/cpuinfo

echo
echo '*** Applying microcode updates'
for i in 5700hq/*.bin 5x75c/*.bin; do
  cat "$i" > /dev/cpu/microcode
done;

echo
echo '*** Current microcode version information:'
grep microcode /proc/cpuinfo

echo
echo 'No errors encountered.'
echo 'If the microcode version did not change, no update has been applied.'
echo 'Make sure to re-run this script after every reboot or hibernation.'
