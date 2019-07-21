# EHA_project (LEGACY PROJECT)
“EHA – Ethernet Hardware Encapsulator”:

You might also be interested to see the predecessor of “Etherblade.net Ver1”  – a project named “EHA – Ethernet Hardware Encapsulator”.

This is a simple encapsulator device which receives frames on L2 ethernet interface, performs wire-speed encapsulation with predefined 
static header stored in the memory prior sending frames out via L3 interface. Because it is a basic device without any sophisticated 
features like VLAN and fragmentation support, the “Ethernet Hardware Encapsulator” may become a good academical project covering full 
hardware design cycle of a communication system and developing an embedded software for it. It demonstrates how to implement both 
“control” and “data” planes that communicate with each other within a single SoC (system-on-chip) system.

“EHA – Ethernet Hardware Encapsulator” provides a base for further project development – the fully functional verified 
“store-and-forward” buffer as well as SoC environment that is used as a testbed for “Etherblade.net”.

Please watch this video demonstrating working hardware developed during the course of the project:

[![Ethernet hardware encapsulator (xilinx 7 series fpga project)](https://img.youtube.com/vi/F9DtJwAsErg/0.jpg)](https://www.youtube.com/watch?v=F9DtJwAsErg "Ethernet hardware encapsulator (xilinx 7 series fpga project)")
