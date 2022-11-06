/* 
 * Check Notes for memory map (../docs/NOTES.md)
 */

MEMORY {
    FLASH(RX)  : ORIGIN = 0x00000000, LENGTH = 256K
    SRAM(RWX)  : ORIGIN = 0x20000000, LENGTH = 32K
    CACHE(RW)  : ORIGIN = 0x21000000, LENGTH = 4K
}

SECTIONS {

    .text : {
        *(._vectorTable)
        *(.text)
        /*
         * ------ Setting up a section for strings ------
         * _stringsStart:  start of the string section.
         * _stringsEnd :   end of the string section.
         * _stringsSz:     size of the string section.
         */
        _stringsStart = .;
        *(._strs);
        _stringsEnd = .;
    } >FLASH

    .data (NOLOAD) : {
        . = . + 0x400;
        _stackEnd = .;
        . = ALIGN(4);
        *(.data);
        . = ALIGN(4);
    } >SRAM

    .bss (NOLOAD) : {
        _bssStart = .;
        *(.bss);
        . = ALIGN(4);
        _bssEnd = .;
        _bssSize = _bssEnd - _bssStart;
    } >SRAM

}
