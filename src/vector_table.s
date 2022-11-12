@
@ Vector Table
@
.syntax unified
.cpu cortex-m4
.thumb

@
@
@ Macro set ISRs in the vector table.
@ Makes each entry global, weak and aliased
@
@
.macro setISR name
   .global \name
   .weak \name
   .thumb_set \name, defaultISR
   .word \name
.endm


@
@
@ The Actual Vector Table placed in
@ the section _vectorTable as defined
@ in the linker script
@
@
.global vectorTable
.section ._vectorTable, "a"
.type vectorTable, %object
vectorTable:
.word _stackEnd
setISR resetHandler
setISR nmiHanlder
setISR hardFaultHandler
setISR memManageHandler
setISR busFaultHanlder
setISR usageFaultHandler
.word 0 @ 0x1C
.word 0 @ 0x20
.word 0 @ 0x24
.word 0 @ 0x28
setISR svCallHandler
setISR debugMonitorHanlder
.word 0
setISR pEndSVHandler
setISR sysTickHandler
@
@ SoC Specific Handlers
@
.if PLATFORM == 0 @QEMU
    setISR wdgTimer
    setISR pvdHandler
    setISR tampStampHandler
    setISR rtcWakeUpHandler
    setISR flashHandler
    setISR rccHandler
    setISR ext0Handler
    setISR ext1Handler
    setISR ext2Handler
    setISR ext3Handler
    setISR ext4Handler
    setISR dma1Stream0Handler
    setISR dma1Stream1Handler
    setISR dma1Stream2Handler
    setISR dma1Stream3Handler
    setISR dma1Stream4Handler
    setISR dma1Stream5Handler
    setISR dma1Stream6Handler
    setISR adcHandler
    setISR can1TxHandler
    setISR can1Rx0Handler
    setISR can1Rx1Handler
    setISR can1SceHanlder
    setISR exti9to5Handler
    setISR tim1BrkTim9Handler
    setISR tim1UpTim10Handler
    setISR tim1TrgComTim11Handler
    setISR tim1CCHandler
    setISR tim2Handler
    setISR tim3Handler
    setISR tim4Handler
    setISR i2c1EvtHandler
    setISR i2c1ErrHandler
    setISR i2c2EvtHandler
    setISR i2c2ErrHandler
    setISR spi1Handler
    setISR spi2Handler
    setISR usart1Handler
    setISR usart2Handler
    setISR usart3Handler
    setISR exti15to10Handler
    setISR rtcAlarmHandler
    setISR otgFsWakeUpHandler
    setISR tim8BrkTim12Handler
    setISR tim8UpTim13Handler
    setISR tim8TrgComTim14Handler
    setISR tim8CCHandler
    setISR dma1Stream7Handler
    setISR fsmcHandler
    setISR sdioHandler
    setISR tim5Handler
    setISR spi3Handler
    setISR uart4Handler
    setISR uart5Handler
    setISR tim6DacHandler
    setISR tim7Handler
    setISR dma2Stream0Handler
    setISR dma2Stream1Handler
    setISR dma2Stream2Handler
    setISR dma2Stream3Handler
    setISR dma2Stream4Handler
    setISR ethHandler
    setISR ethWakeUpHandler
    setISR can2TxHandler
    setISR can2Rx0Handler
    setISR can2Rx1Handler
    setISR can2SceHanlder
    setISR otgFsHandler
    setISR dma2Stream50Handler
    setISR dma2Stream6Handler
    setISR dma2Stream7Handler
    setISR usart6Handler
    setISR i2c3EvtHandler
    setISR i2c3ErrHandler
    setISR otgHsEp1OutHandler
    setISR otgHsEp1InHandler
    setISR otgHsWakeUpHandler
    setISR dcmiHandler
    setISR cyrpHandler
    setISR hashRngHandler
    setISR fpuHandler
.elseif PLATFORM == 1 @SAM4L
    .error "SAM 4L not supported yet"
.else
    .error "Unrecognized Platform Selected"
.endif

.text
.type defaultISR, %function
.global defaultISR
defaultISR:
    NOP
    B defaultISR

.end
