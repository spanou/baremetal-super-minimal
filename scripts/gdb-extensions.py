import gdb 
import sys
from enum import IntEnum

class APSR(IntEnum):
    '''
        Defines a set of enumerations for the fields and masks of APSR
    '''
    N_FLAG_OFFSET = 31
    Z_FLAG_OFFSET = 30
    C_FLAG_OFFSET = 29
    V_FLAG_OFFSET = 28
    Q_FLAG_OFFSET = 27
    GE_FLAG_OFFSET = 16
    N_FLAG_MASK = (0x1 << N_FLAG_OFFSET)
    Z_FLAG_MASK = (0x1 << Z_FLAG_OFFSET)
    C_FLAG_MASK = (0x1 << C_FLAG_OFFSET)
    V_FLAG_MASK = (0x1 << V_FLAG_OFFSET)
    Q_FLAG_MASK = (0x1 << Q_FLAG_OFFSET)
    GE_FLAG_MASK= (0xF << GE_FLAG_OFFSET)
    BASE_OFFSET= 0
    BASE_MASK = N_FLAG_MASK | Z_FLAG_MASK | C_FLAG_MASK | V_FLAG_MASK | Q_FLAG_MASK | GE_FLAG_MASK

class IPSR(IntEnum):
    '''
        Defines a set of enumerations for the fields and masks of IPSR
    '''
    EXP_FLAGS_OFFSET = 0
    EXP_FLAGS_MASK = (0x1F << EXP_FLAGS_OFFSET)
    BASE_OFFSET = 0
    BASE_MASK = EXP_FLAGS_MASK

class EPSR(IntEnum):
    '''
        Defines a set of enumerations for the fields and masks of EPSR
    '''
    T_FLAG_OFFSET = 24
    T_FLAG_MASK = (0x1 << T_FLAG_OFFSET)
    BASE_OFFSET = 0
    BASE_MASK = T_FLAG_MASK

class ProgStatus(gdb.Command):
    '''
        Displays the PSR register values layed out by fields for each 
        of the APSR, IPSR and EPSR
    '''

    def __init__(self):
        super(ProgStatus, self).__init__("progstatus", gdb.COMMAND_USER)

    def invoke( self, arg, from_tty):
        xPSR =int(gdb.parse_and_eval("$xpsr"))
        print(f"{'xPSR':<20} = {xPSR:#010X}")
        aPSR = (xPSR & APSR.BASE_MASK) >> APSR.BASE_OFFSET
        print(f"{'APSR':<20} = {aPSR:#010X}")
        nFlag = (xPSR & APSR.N_FLAG_MASK) >> APSR.N_FLAG_OFFSET
        zFlag = (xPSR & APSR.Z_FLAG_MASK) >> APSR.Z_FLAG_OFFSET
        cFlag = (xPSR & APSR.C_FLAG_MASK) >> APSR.C_FLAG_OFFSET
        vFlag = (xPSR & APSR.V_FLAG_MASK) >> APSR.V_FLAG_OFFSET
        qFlag = (xPSR & APSR.Q_FLAG_MASK) >> APSR.Q_FLAG_OFFSET

        print(f"{'N':>20} = {nFlag}")
        print(f"{'Z':>20} = {zFlag}")
        print(f"{'C':>20} = {cFlag}")
        print(f"{'V':>20} = {vFlag}")
        print(f"{'Q':>20} = {qFlag}")

        geFlag = (xPSR & APSR.GE_FLAG_MASK) >> APSR.GE_FLAG_OFFSET
        print(f"{'GE':>20} = {geFlag}")

        iPSR = (xPSR & IPSR.BASE_MASK) >> IPSR.BASE_OFFSET
        print(f"{'IPSR':<20} = {iPSR:#010X}")
        exceptionNo = (xPSR & IPSR.EXP_FLAGS_MASK) >> IPSR.EXP_FLAGS_OFFSET
        print( f"{'Exception No':>20} = {exceptionNo}")

        ePSR = (xPSR & EPSR.BASE_MASK) >> EPSR.BASE_OFFSET
        print(f"{'EPSR':<20} = {ePSR:#010X}")
        # TODO: Set up the approriate description
        tFlag = (xPSR & EPSR.T_FLAG_MASK) >> EPSR.T_FLAG_OFFSET
        print(f"{'T':>20} = {tFlag}")

ProgStatus()

class SYST(IntEnum):
    '''
        Defines a set of fields and masks for the SysTick Registers
        (with the exception of the SYST_CALIB register.
    '''
    CSR_BASE = 0xE000E010
    CSR_EN_OFFSET = 0x0
    CSR_EN_MASK = 0x1
    CSR_TICKINT_OFFSET = 1
    CSR_TICKINT_MASK = (0x1 << CSR_TICKINT_OFFSET)
    CSR_CLKSOURCE_OFFSET = 2
    CSR_CLKSOURCE_MASK = (0x1 << CSR_CLKSOURCE_OFFSET)
    CSR_COUNTFLAG_OFFSET = 16
    CSR_COUNTFLAG_MASK = (0x1 << CSR_COUNTFLAG_OFFSET)
    RVR_BASE = 0xE000E014
    RVR_RELOAD_OFFSET = 0
    RVR_RELOAD_MASK = (0x00FFFFFF << RVR_RELOAD_OFFSET)
    CVR_BASE = 0xE000E018
    CVR_CURRENT_OFFSET = 0
    CVR_CURRENT_MASK = (0xFFFFFFFF << RVR_RELOAD_OFFSET)

class SysTick(gdb.Command):
    '''
        Displays the SysTick register values and fields for each of the
        SYST_CSR, SYST_RVR and SYST_CVR. Note: SYST_CALIB is intentionally
        omitted
    '''
    def __init__(self):
        super(SysTick, self).__init__("systickinfo", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        # Parse and Print the SYST_CSR register and its fields.
        strAddr = str(hex(SYST.CSR_BASE))
        strCmd = f"*(uint32_t *){strAddr}"
        sysTickCSR = int(gdb.parse_and_eval(strCmd))
        print(f"{'SYST_CSR':<20} = {sysTickCSR:#010X}")
        enableFlag = (sysTickCSR & SYST.CSR_EN_MASK) >> SYST.CSR_EN_OFFSET
        tickIntFlag = (sysTickCSR & SYST.CSR_TICKINT_MASK) >> SYST.CSR_TICKINT_OFFSET
        clkSourceFlag = (sysTickCSR & SYST.CSR_CLKSOURCE_MASK) >> SYST.CSR_CLKSOURCE_OFFSET
        countFlag = (sysTickCSR & SYST.CSR_COUNTFLAG_MASK) >> SYST.CSR_COUNTFLAG_OFFSET
        print(f"{'ENABLE':>20} = {enableFlag}")
        print(f"{'TICKINT':>20} = {tickIntFlag}")
        print(f"{'CLKSOURCE':>20} = {clkSourceFlag}")
        print(f"{'COUNTFLAG':>20} = {countFlag}")

        # Parse and Print the SYST_RVR register and its fields.
        strAddr = str(hex(SYST.RVR_BASE))
        strCmd = f"*(uint32_t *){strAddr}"
        sysTickRVR = int(gdb.parse_and_eval(strCmd))
        print(f"{'SYST_RVR':<20} = {sysTickRVR:#010X}")
        reloadField = (sysTickRVR & SYST.RVR_RELOAD_MASK) >> SYST.RVR_RELOAD_OFFSET
        print(f"{'RELOAD':>20} = {reloadField}")

        # Parse and Print the SYST_CVR register and its fields.
        strAddr = str(hex(SYST.CVR_BASE))
        strCmd = f"*(uint32_t *){strAddr}"
        sysTickCVR = int(gdb.parse_and_eval(strCmd))
        print(f"{'SYST_CVR':<20} = {sysTickCVR:#010X}")
        currentField = (sysTickCVR & SYST.CVR_CURRENT_MASK) >> SYST.CVR_CURRENT_OFFSET
        print(f"{'CURRENT':>20} = {currentField}")

SysTick()
