#!/usr/bin/env python2
# License: GPLv3+
# Extract .bin files from a uefi update that look like microcode updates.

import struct
import sys
import itertools

# struct intel_ucode_v1_hdr { /* 48 bytes */
#     uint32_t        hdrver; /* must be 0x1 */
#     int32_t         rev;    /* yes, it IS signed */
#     uint32_t        date;   /* packed BCD, MMDDYYYY */
#     uint32_t        sig;
#     uint32_t        cksum;
#     uint32_t        ldrver;
#     uint32_t        pf_mask;
#     uint32_t        datasize;  /* 0 means 2000 */
#     uint32_t        totalsize; /* 0 means 2048 */
#     uint32_t        reserved[3];
# } __attribute__((packed));

STRUCT_FMT = '<IiIIIIIIIIII'
STRUCT_SIZE = struct.calcsize(STRUCT_FMT)

with open(sys.argv[1], 'rb') as f:
    for i in itertools.count():
        f.seek(i)
        header_bytes = f.read(STRUCT_SIZE)
        if len(header_bytes) < STRUCT_SIZE: # EOF
            break
        hdrvr, rev, date, sig, \
            cksum, ldrvr, pf_mask, \
            datasize, totalsize, \
            reserved0, reserved1, reserved2 = \
            struct.unpack(STRUCT_FMT, header_bytes)

        # validate the header
        if hdrvr != 1:
            continue
        # newer microcode updates include a size field, whereas older containers
        # set it at 0 and are exactly 2048 bytes long
        totalsize = totalsize or 2048
        if not 1024 * 2 <= totalsize < 1024 * 50:
            # microcode updates should probably be 5KB to 50KB
            continue
        if datasize + STRUCT_SIZE > totalsize:
            continue

        body_nbytes = totalsize - len(header_bytes)
        body_bytes = f.read(body_nbytes)
        if len(body_bytes) < body_nbytes:
            continue # partial read
        with open('microcode/%s.bin' % i, 'wb') as out:
            out.write(header_bytes)
            out.write(body_bytes)
