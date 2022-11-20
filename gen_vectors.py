#!/usr/bin/python3
#
#	cm0test - Hello world program for Cortex-M0.
#	Copyright (C) 2019-2022 Johannes Bauer
#
#	This file is part of cm0test.
#
#	cm0test is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; this program is ONLY licensed under
#	version 3 of the License, later versions are explicitly excluded.
#
#	cm0test is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with cm0test; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#	Johannes Bauer <JohannesBauer@gmx.de>

import sys

vector_filename = sys.argv[1]

handlers = { }
with open(vector_filename) as f:
	offset = 4
	for line in f:
		line = line.rstrip("\r\n")
		if (line == "") or line.startswith("#"):
			continue
		if line.startswith("@"):
			offset = int(line[1:], 16)
			continue
		if line != "-":
			handlers[offset] = line
		offset += 4
last_offset = offset

print(".section .vectors, \"a\", %progbits")
print(".type vectors, %object")
print("vectors:")
print("	.word	_eram")
for offset in range(4, last_offset, 4):
	handler = handlers.get(offset)
	if handler is None:
		print("	.word	0		// %#x: Reserved" % (offset))
	else:
		print("	.word	%s_Handler		// %#x" % (handler, offset))
print()

for offset in range(8, last_offset, 4):
	handler = handlers.get(offset)
	if handler is not None:
		print("	.weak	%s_Handler" % (handler))
		print("	.thumb_set	%s_Handler, Default_Handler" % (handler))
print()
print(".size vectors, .-vectors")
print(".global vectors")

