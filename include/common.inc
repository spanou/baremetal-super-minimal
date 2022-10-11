/**
 *
 * This file contains common defines that will be preprocessed to auto generate 
 * a consts.s and consts.c. 
 * 
 * The format of a define is <name>, <value> where value can be either
 * hexadecimal or decimal. 
 */

/**
 * 
 * --- MEMORY MONITOR ---
 *
 */
MEM_MONITOR_ADDR, 0x20001000
MEM_MONITOR_SIZE, 256

/**
 *
 * --- GPIO ----
 *
 */
GPIO_BASE_ADDR, 0x400E1000
