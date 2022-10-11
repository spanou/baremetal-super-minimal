#
# Vector Table
#
.syntax unified
.cpu cortex-m4
.thumb


.section ._vectorTable, "a"
.word _stackEnd
.word resetHandler
.space 0x200

