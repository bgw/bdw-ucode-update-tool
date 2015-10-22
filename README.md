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
- Office 2016 Installation on Windows
- Certain Steam games on Windows
- Linux virtual machines on Windows

I don't use Windows however, so I've only personally verified the first case. I
also don't have installation instructions for Windows, as I don't know how to
install custom microcode updates on Windows.

# Install instructions

On Linux:

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
