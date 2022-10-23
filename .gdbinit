add-auto-load-safe-path ./.gdbinit
target extended-remote localhost:1234 
directory ./

# Break at the _start
break _start
break _endlessLoop

# Clear the registers 
set $r0 = 0
set $r1 = 0
set $r2 = 0
set $r3 = 0
set $r4 = 0
set $r5 = 0
set $r6 = 0
set $r7 = 0
set $r8 = 0
set $r9 = 0
set $r10 = 0
set $r11 = 0
set $r12 = 0
