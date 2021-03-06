###############################################################################
##$Date: 2009/11/11 05:22:01 $
##$Revision: 1.1 $
###############################################################################
## wave_mti.do
###############################################################################
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {FRAME CHECK MODULE tile0_frame_check0 }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile0_frame_check0/begin_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile0_frame_check0/track_data_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile0_frame_check0/data_error_detected_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile0_frame_check0/start_of_packet_detected_r
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile0_frame_check0/RX_DATA
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile0_frame_check0/ERROR_COUNT
add wave -noupdate -divider {FRAME CHECK MODULE tile0_frame_check1 }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile0_frame_check1/begin_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile0_frame_check1/track_data_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile0_frame_check1/data_error_detected_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile0_frame_check1/start_of_packet_detected_r
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile0_frame_check1/RX_DATA
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile0_frame_check1/ERROR_COUNT
add wave -noupdate -divider {FRAME CHECK MODULE tile1_frame_check0 }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile1_frame_check0/begin_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile1_frame_check0/track_data_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile1_frame_check0/data_error_detected_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile1_frame_check0/start_of_packet_detected_r
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile1_frame_check0/RX_DATA
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile1_frame_check0/ERROR_COUNT
add wave -noupdate -divider {FRAME CHECK MODULE tile1_frame_check1 }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile1_frame_check1/begin_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile1_frame_check1/track_data_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile1_frame_check1/data_error_detected_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile1_frame_check1/start_of_packet_detected_r
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile1_frame_check1/RX_DATA
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile1_frame_check1/ERROR_COUNT
add wave -noupdate -divider {FRAME CHECK MODULE tile2_frame_check0 }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile2_frame_check0/begin_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile2_frame_check0/track_data_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile2_frame_check0/data_error_detected_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile2_frame_check0/start_of_packet_detected_r
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile2_frame_check0/RX_DATA
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile2_frame_check0/ERROR_COUNT
add wave -noupdate -divider {FRAME CHECK MODULE tile2_frame_check1 }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile2_frame_check1/begin_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile2_frame_check1/track_data_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile2_frame_check1/data_error_detected_r
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/tile2_frame_check1/start_of_packet_detected_r
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile2_frame_check1/RX_DATA
add wave -noupdate -format Logic -radix hexadecimal /DEMO_TB/gtx_top_i/tile2_frame_check1/ERROR_COUNT
add wave -noupdate -divider {TILE0_GTX }
add wave -noupdate -divider {Receive Ports - 8b10b Decoder }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXCHARISCOMMA0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXCHARISCOMMA1_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXDISPERR0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXDISPERR1_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXNOTINTABLE0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXNOTINTABLE1_OUT
add wave -noupdate -divider {Receive Ports - Comma Detection and Alignment }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXBYTEISALIGNED0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXBYTEISALIGNED1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXENMCOMMAALIGN0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXENMCOMMAALIGN1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXENPCOMMAALIGN0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXENPCOMMAALIGN1_IN
add wave -noupdate -divider {Receive Ports - RX Data Path interface }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXDATA0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXDATA1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXRECCLK0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXRECCLK1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXUSRCLK0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXUSRCLK1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXUSRCLK20_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXUSRCLK21_IN
add wave -noupdate -divider {Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXEQMIX0_IN
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXEQMIX1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXN0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXN1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXP0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXP1_IN
add wave -noupdate -divider {Receive Ports - RX Polarity Control Ports }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXPOLARITY0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RXPOLARITY1_IN
add wave -noupdate -divider {Shared Ports - Tile and PLL Ports }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/CLKIN_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/GTXRESET_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/PLLLKDET_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/REFCLKOUT_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RESETDONE0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/RESETDONE1_OUT
add wave -noupdate -divider {Transmit Ports - TX Data Path interface }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/TXDATA0_IN
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/TXDATA1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/TXUSRCLK0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/TXUSRCLK1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/TXUSRCLK20_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/TXUSRCLK21_IN
add wave -noupdate -divider {Transmit Ports - TX Driver and OOB signalling }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/TXN0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/TXN1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/TXP0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile0_gtx_i/TXP1_OUT

add wave -noupdate -divider {TILE1_GTX }
add wave -noupdate -divider {Receive Ports - 8b10b Decoder }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXCHARISCOMMA0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXCHARISCOMMA1_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXDISPERR0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXDISPERR1_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXNOTINTABLE0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXNOTINTABLE1_OUT
add wave -noupdate -divider {Receive Ports - Comma Detection and Alignment }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXBYTEISALIGNED0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXBYTEISALIGNED1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXENMCOMMAALIGN0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXENMCOMMAALIGN1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXENPCOMMAALIGN0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXENPCOMMAALIGN1_IN
add wave -noupdate -divider {Receive Ports - RX Data Path interface }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXDATA0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXDATA1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXRECCLK0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXRECCLK1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXUSRCLK0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXUSRCLK1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXUSRCLK20_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXUSRCLK21_IN
add wave -noupdate -divider {Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXEQMIX0_IN
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXEQMIX1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXN0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXN1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXP0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXP1_IN
add wave -noupdate -divider {Receive Ports - RX Polarity Control Ports }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXPOLARITY0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RXPOLARITY1_IN
add wave -noupdate -divider {Shared Ports - Tile and PLL Ports }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/CLKIN_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/GTXRESET_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/PLLLKDET_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/REFCLKOUT_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RESETDONE0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/RESETDONE1_OUT
add wave -noupdate -divider {Transmit Ports - TX Data Path interface }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/TXDATA0_IN
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/TXDATA1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/TXUSRCLK0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/TXUSRCLK1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/TXUSRCLK20_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/TXUSRCLK21_IN
add wave -noupdate -divider {Transmit Ports - TX Driver and OOB signalling }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/TXN0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/TXN1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/TXP0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile1_gtx_i/TXP1_OUT

add wave -noupdate -divider {TILE2_GTX }
add wave -noupdate -divider {Receive Ports - 8b10b Decoder }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXCHARISCOMMA0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXCHARISCOMMA1_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXDISPERR0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXDISPERR1_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXNOTINTABLE0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXNOTINTABLE1_OUT
add wave -noupdate -divider {Receive Ports - Comma Detection and Alignment }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXBYTEISALIGNED0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXBYTEISALIGNED1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXENMCOMMAALIGN0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXENMCOMMAALIGN1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXENPCOMMAALIGN0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXENPCOMMAALIGN1_IN
add wave -noupdate -divider {Receive Ports - RX Data Path interface }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXDATA0_OUT
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXDATA1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXRECCLK0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXRECCLK1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXUSRCLK0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXUSRCLK1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXUSRCLK20_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXUSRCLK21_IN
add wave -noupdate -divider {Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXEQMIX0_IN
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXEQMIX1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXN0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXN1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXP0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXP1_IN
add wave -noupdate -divider {Receive Ports - RX Polarity Control Ports }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXPOLARITY0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RXPOLARITY1_IN
add wave -noupdate -divider {Shared Ports - Tile and PLL Ports }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/CLKIN_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/GTXRESET_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/PLLLKDET_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/REFCLKOUT_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RESETDONE0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/RESETDONE1_OUT
add wave -noupdate -divider {Transmit Ports - TX Data Path interface }
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/TXDATA0_IN
add wave -noupdate -format Literal -radix hexadecimal /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/TXDATA1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/TXUSRCLK0_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/TXUSRCLK1_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/TXUSRCLK20_IN
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/TXUSRCLK21_IN
add wave -noupdate -divider {Transmit Ports - TX Driver and OOB signalling }
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/TXN0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/TXN1_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/TXP0_OUT
add wave -noupdate -format Logic /DEMO_TB/gtx_top_i/gtx_i/tile2_gtx_i/TXP1_OUT

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 282
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {5236 ps}

