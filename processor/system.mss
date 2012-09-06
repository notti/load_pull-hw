
 PARAMETER VERSION = 2.2.0


BEGIN OS
 PARAMETER OS_NAME = device-tree
 PARAMETER OS_VER = 0.00.x
 PARAMETER PROC_INSTANCE = ppc440_0
 PARAMETER console device = RS232_Uart_1
 PARAMETER bootargs = console=ttyS0,115200 root=/dev/xsa2
END


BEGIN PROCESSOR
 PARAMETER DRIVER_NAME = cpu_ppc440
 PARAMETER DRIVER_VER = 1.00.b
 PARAMETER HW_INSTANCE = ppc440_0
 PARAMETER COMPILER = powerpc-eabi-gcc
 PARAMETER ARCHIVER = powerpc-eabi-ar
END


BEGIN DRIVER
 PARAMETER DRIVER_NAME = memcon
 PARAMETER DRIVER_VER = 1.00.a
 PARAMETER HW_INSTANCE = DDR2_SDRAM
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = uartns550
 PARAMETER DRIVER_VER = 1.11.a
 PARAMETER HW_INSTANCE = RS232_Uart_1
 PARAMETER CLOCK_HZ = 100000000
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = lltemac
 PARAMETER DRIVER_VER = 1.00.b
 PARAMETER HW_INSTANCE = Hard_Ethernet_MAC
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = sysace
 PARAMETER DRIVER_VER = 1.11.a
 PARAMETER HW_INSTANCE = SysACE_CompactFlash
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = llfifo
 PARAMETER DRIVER_VER = 1.00.a
 PARAMETER HW_INSTANCE = Hard_Ethernet_MAC_fifo
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER DRIVER_VER = 1.00.a
 PARAMETER HW_INSTANCE = clock_generator_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER DRIVER_VER = 1.00.a
 PARAMETER HW_INSTANCE = jtagppc_cntlr_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER DRIVER_VER = 1.00.a
 PARAMETER HW_INSTANCE = proc_sys_reset_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = intc
 PARAMETER DRIVER_VER = 1.11.a
 PARAMETER HW_INSTANCE = xps_intc_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = bram
 PARAMETER DRIVER_VER = 1.00.a
 PARAMETER HW_INSTANCE = xps_bram_if_cntlr_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = iic
 PARAMETER DRIVER_VER = 1.13.b
 PARAMETER HW_INSTANCE = IIC_DDR2
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpio
 PARAMETER DRIVER_VER = 2.12.a
 PARAMETER HW_INSTANCE = GPIO_LEDs
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = iic
 PARAMETER DRIVER_VER = 1.13.b
 PARAMETER HW_INSTANCE = IIC_SMBUS
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpio
 PARAMETER DRIVER_VER = 2.12.a
 PARAMETER HW_INSTANCE = GPIO_DIP
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpio
 PARAMETER DRIVER_VER = 2.12.a
 PARAMETER HW_INSTANCE = GPIO_PushButtons
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpio
 PARAMETER DRIVER_VER = 2.12.a
 PARAMETER HW_INSTANCE = GPIO_DirectionLEDs
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER DRIVER_VER = 1.00.a
 PARAMETER HW_INSTANCE = proc2fpga_0
END


