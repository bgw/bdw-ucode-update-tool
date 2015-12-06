# Broadwell μcode Update Installer

Intel i5-5675C, i7-5775C, and i7-5700HQ microcode updates extracted from MSI's
UEFI updates, along with a tiny zero-dependency install script for Linux users.

---

**WARNING:** These updates have been extracted from UEFI firmware intended for
very specific hardware. This may (though highly unlikely) damage your hardware.
If that happens, that's your own fault. Not mine, not Intel's, and certainly not
MSI's.

In addition to potentially damaging your hardware, incorrect installation on a
system where `glibc` is compiled with hardware lock elision (hle) enabled may
cause anything linked to `libpthread` to segfault (e.g. `systemd`, `udev`, etc).
To safely install, *you must use use the kernel's early loading mechanism
(supported by `--persist-debian`).* If you wish to install this update without
the script, please [read and understand this post][henrique].

If you do make your computer unbootable (for software reasons), it should be
possible to fix it using a live CD.

[henrique]: https://bugzilla.kernel.org/show_bug.cgi?id=103351#c65

---

# Why?

Intel's late Broadwell chips shipped with [a][pt1] [whole][pt2] [slew][pt3]
[of][pt4] [stability][pt5] [issues][pt6], causing Machine Check Exception
kernel panics on Linux and BSODs on Windows.

[pt1]: http://www.phoronix.com/scan.php?page=news_item&px=i7-5775C-Idle-Problems
[pt2]: http://www.phoronix.com/scan.php?page=news_item&px=core-i7-5775c-oc-fixed-mode
[pt3]: http://www.phoronix.com/scan.php?page=news_item&px=fedora-22-good-for-5775
[pt4]: http://www.phoronix.com/scan.php?page=news_item&px=intel-5775c-msi-update
[pt5]: https://bbs.archlinux.org/viewtopic.php?id=201194
[pt6]: https://bugzilla.kernel.org/show_bug.cgi?id=103351
[reddit]: https://www.reddit.com/r/hardware/comments/3meznc/design_defect_in_i55675ci75775ci75700hq/

While [Intel hasn't directly distributed any new microcode updates since
January][intel-updates], they've apparently [distributed updates to some
motherboard vendors][msi-forum]. Until Intel updates the downloads on their
site, I've extracted the updates from MSI's firmware, using a [custom python
script][python].

[intel-updates]: https://downloadcenter.intel.com/search?keyword=Linux+Processor+Microcode+Data+File
[msi-forum]: https://forum-en.msi.com/index.php?topic=261054.msg1498718#msg1498718
[python]: http://benjam.info/blog/posts/2015-09-26-microcode/

# What *should* this fix?

- MCE kernel panics on Linux under normal usage
- BSOD with Office 2016 Installation on Windows
- BSOD with Certain Source-engine games on Windows
- BSOD with Linux virtual machines on Windows

I don't use Windows however, so I've only personally verified the first case.

# Install instructions

## Windows

Some motherboard manufacturers are now distributing UEFI updates with this
microcode update. Check with your motherboard manufacturer first to see if a
UEFI update is available containing the `0x13` microcode update for Broadwell.
If it's available, you should use that instead.

1.  Download the microcode update driver from [VMware's website][win-driver] and
    extract the files contained within the zip. Make sure to read and understand
    the information on that page.

2.  Download [`microcode_amd.bin`][] and [`microcode_amd_fam15h.bin`][] and
    place them in the same directory as where the files from step 1 were placed.

    > The VMware microcode update driver requires those two files even if you
    > don't have an AMD CPU. Alternatively, you can use two empty files with the
    > same name instead.

3.  Download [`0x13.dat`][] and rename it to `microcode.dat`. Place it in the
    same directory as where the files from step 1 were placed.

4.  Right click the `install.bat` file from step 1 and click
    "Run as an Administrator"; It should work!

5.  After everything is done, you can check "Event Viewer" for check update
    status.

Once everything is working, you can use virtual machines with Linux or play
Source Engine games, even if you reboot Windows.

*See [this github issue][issue-2] for more details.*

[win-driver]: https://labs.vmware.com/flings/vmware-cpu-microcode-update-driver
[`microcode_amd.bin`]: https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/plain/amd-ucode/microcode_amd.bin
[`microcode_amd_fam15h.bin`]: https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/plain/amd-ucode/microcode_amd_fam15h.bin
[`0x13.dat`]: https://github.com/bgw/bdw-ucode-update-tool/raw/master/0x13.dat
[issue-2]: https://github.com/bgw/bdw-ucode-update-tool/issues/2

## Linux

Before using this tool, check with your distribution's available packages. Some
distributions now carry this microcode as part of their intel-microcode
packages. For example, if you're running Debian Jessie, you should install
[`intel-microcode` from `jessie-backports`][backports]. Some motherboard
manufacturers also have UEFI updates that fix include this update.

You should be running microcode version `0x13` or greater. You can check this by
running `grep microcode /proc/cpuinfo`.

```sh
$ git clone https://github.com/bgw/bdw-ucode-update-tool.git
$ cd bdw-ucode-update-tool
$ sudo ./install.sh
```

Repeat this every time your machine starts up or resumes from hibernation, as
microcode updates aren't saved across reboots.

If you're on a Debian-based system, we have experimental persistence support:

```sh
$ sudo ./install.sh --persist-debian
```

By running with `--persist-debian`, you should no longer need to re-run this
script after every reboot.

To uninstall the persistent Debian updates, simply delete
`/lib/firmware/intel-ucode` and reinstall the `intel-microcode` package:

```
$ sudo rm -rf /lib/firmware/intel-ucode
$ sudo aptitude reinstall intel-microcode
```

[backports]: https://packages.debian.org/jessie-backports/intel-microcode

# Tested on...

I only have a i5-5675C, so I've only tested it on that. The system seems to run
fine, even under extreme CPU, GPU, and IO load, with Speedstep and Turbo boost
enabled. Other people have verified that this does work on the 5775C and 5700HQ.

| Processor | Verified?      |
| --------- | -------------- |
| i5-5675C  | Works for me.  |
| i7-5775C  | [Here][verif2] |
| i7-5700HQ | [Here][verif1] |

[verif1]: https://bugzilla.kernel.org/show_bug.cgi?id=103351#c29
[verif2]: https://bugzilla.kernel.org/show_bug.cgi?id=103351#c30

# Microcode sources:

- `0x13.bin` was extracted from `E16J2IMS.114` in
  <http://download.msi.com/bos_exe/nb/E16J2IMS.114.zip>
