#!/usr/bin/env python2
# https://gist.github.com/EcmaXp/506e6255a654dd6f01a8

import sys
import base64

with open(sys.argv[1], 'rb') as fp, open(sys.argv[2], 'w') as out:
    out.write("/* i7-5775C microcode rev.0x13 */\n")
    while True:
        r = []
        STOP = False
        for i in range(4):
            block = fp.read(4)
            if not block:
                block = b"\0\0\0\0"
                STOP = True
                if not i:
                    break
            r.append("0x" + base64.b16encode(block[::-1]).decode())
            
        if STOP:
            break
        out.write(", ".join(r) + ',\n')
