
@ Start Main for ASM
@
.syntax unified
.cpu cortex-m4
.thumb


@
@ For this exercise we want to:
@	1 - Declare and initialize a zero ended string in code space (.text), the size of the
@		string is up to you, try not to exceed the 100 character mark, purely for
@       convenience. Name the string DEBUG_STR.
@
@ 	2 - Create a region in RAM no less than 200 bytes, ensure the region is accessible
@       by the rest of the program. Name said region as MEMORY_MONITOR.
@
@	3 - Write two functions. The first function (strCopyAsm) will copy the zero ended
@		string (DEBUG_STR), from code to the RAM region pointed to by MEMORY_MONITOR.
@		The second function (clearMemMonitorAsm), will zero out the entire MEMORY_MONITOR
@		region. Both functions need to be global.
@
@	4 - Call the second function to ensure your MEMORY_MONITOR region is completely
@		zeroed out, make sure you call this from the startMain() function found in
@		main.s
@
@	5 - After calling the second function, next call the first function to copy the
@		DEBUG_STR into the MEMORY_MONITOR from the startMain() function found in
@		main.s
@
@ Constraints: All code must be written purely in assembly and the appropriate comments
@			   must be added to document your code.
@
@			   Use gdb to view the contents of the MEMORY_MONITOR before and after
@			   calling each function. x/128bc
@


@ <add your code here>
