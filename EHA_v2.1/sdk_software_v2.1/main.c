/*Ethernet hardware encapsulator demonstration software (ver2.1) Dec.2016
* Developer: V.Efimov
* https://www.linkedin.com/in/vladimir-efimov
* Shared FIFO buffer code obtained from:
* https://stratifylabs.co/embedded%20design%20tips/2013/10/02/Tips-A-FIFO-Buffer-Implementation/
*/
#include <xuartlite_l.h>
#include <xintc_l.h>
#include <xparameters.h>
#include <xil_io.h>

/* Shared FIFO buffer structure is defined.
* The FIFO buffer is used to exchange data between ISR and the main program.
*/
typedef struct {
	char *buf;
	int head;
	int tail;
	int size;
} fifo_t;


/* "fifo_init" initializes the shared FIFO buffer with the given
* size and head/tail counters.
*/
void fifo_init(fifo_t *f, char *buf, int size) {
	f->head = 0;
	f->tail = 0;
	f->size = size;
	f->buf = buf;
}


/* "fifo_write" to be used in the ISR that copyes nbytes of data
* from 'buf' to the shared FIFO buffer.
* If the head runs into the tail (FULL condition) then not all bytes will be written
* The number of bytes written is returned.
*/
int fifo_write(fifo_t *f, const void *buf, int nbytes) {
	int i;
	const char *p;
	p = buf;
	for (i=0; i < nbytes; i++){
		//first check to see if there is space in the buffer
		if ((f->head + 1 == f->tail) || ((f->head + 1 == f->size) && (f->tail == 0))) {
			return i;
		} else {
			f->buf[f->head] = *p++;
			f->head++;
			if (f->head == f->size) {	//check for wrap-around
				f->head = 0;
				}
			}
		}
		return nbytes;
}


/* "fifo_read" to be used in the main program that copyes nbytes of data
* from shared FIFO buffer to 'buf'.
* If the tail has reached the head (EMPTY condition), not all bytes are read.
* The number of bytes read is returned.
*/
int fifo_read(fifo_t *f, void *buf, int nbytes) {
	int i;
	char *p;
	p = buf;
	for (i=0; i < nbytes; i++){
		if (f->tail != f->head) {		//see if any data is available
			*p++ = f->buf[f->tail]; 	//grab a byte from the buffer
			f->tail++;					//increment the tail
			if (f->tail == f->size) {	//check for wrap-around
				f->tail = 0;
			}
		} else {
			return i;					//number of bytes read
		}
	}
	return nbytes;
}

extern fifo_t *uart_fifo;
void uart_int_handler(void *baseaddr_p) {
	char rdchar;
	/* till uart hardware FIFO is empty */
	while (!XUartLite_IsReceiveEmpty(XPAR_AXI_UARTLITE_0_BASEADDR)) {
		rdchar = XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);
		fifo_write(uart_fifo, &rdchar, 1);
	}
}

void print_banner() {
	print("\033[2J"); // Clear the screen
    print("\n\r******************************************************");
    print("\n\r*           Ethernet hardware encapsulator           *");
    print("\n\r*           demonstration software (ver2.1)          *");
    print("\n\r******************************************************\r\n");
    print("*\r\n");
    print("Choose Task:\r\n");
    print("1: Stall ReadFSM;\r\n");
    print("2: Program header memory with 'a0;a1;a2;a3' header;\r\n");
    print("3: Program header memory with 'ff;ee;dd;cc;bb;aa;99;88' header;\r\n");
    print("OtherKey: Return to this menu.\r\n");
    print("\r\n");
}

/* Allocating memory for the temporary characters storage and memory for shared FIFO buffer
* structure that uses that characters storage memory.
*/
char fifostring[10];
fifo_t *uart_fifo;

int main(void)
{
int cnt;
char displaychar;
u32 regvalue;
	/* Initialize shared FIFO buffer */
	fifo_init(uart_fifo, fifostring, 10);

	/* Enable MicroBlaze exception */
   microblaze_enable_interrupts();

	/* Connect uart interrupt handler that will be called when an interrupt
	* for the uart occurs*/
	XIntc_RegisterHandler(XPAR_INTC_0_BASEADDR,XPAR_AXI_INTC_0_AXI_UARTLITE_0_INTERRUPT_INTR,(XInterruptHandler)uart_int_handler,(void *)XPAR_AXI_UARTLITE_0_BASEADDR);

	/* Start the interrupt controller */
	XIntc_MasterEnable(XPAR_INTC_0_BASEADDR);

	/* Enable uart interrupt in the interrupt controller */
	XIntc_EnableIntr(XPAR_INTC_0_BASEADDR, XPAR_AXI_UARTLITE_0_INTERRUPT_MASK);

	/* Enable Uartlite interrupt */
	XUartLite_EnableIntr(XPAR_AXI_UARTLITE_0_BASEADDR);

	print_banner();
	/* Reading key inputs from shared FIFO buffer and processing them */
	while (1) {
		cnt = fifo_read(uart_fifo, &displaychar, 1);
		if ( cnt == 1 ) {
			switch(displaychar) {
						case '1':
							Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR, 0x0);
							xil_printf ("*Task 1*\r\nValue '0x0' has been written to control register (addr:0x%x) to stall ReadFSM \r\n", XPAR_AXI_GPIO_0_BASEADDR);
							regvalue = Xil_In32(XPAR_AXI_GPIO_0_BASEADDR);
							xil_printf ("Current value of status register (addr:0x%x) is '0x%x' (If LSB=1 then ReadFSM is in 'IDLE' state) \r\n", XPAR_AXI_GPIO_0_BASEADDR, regvalue);
							break;
						case '2':
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR, 0xa0);
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+0x4, 0xa1);
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+0x8, 0xa2);
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+0xc, 0xa3);
							xil_printf ("*Task 2*\r\nHeader content (a0;a1;a2;a3) has been written to header memory (base_addr:0x%x) \r\n", XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR);
							Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR, 0x7);
							xil_printf ("'HEADER_LENGTH' and 'RUN-bit' (LSB) is set in control register (addr:0x%x) \r\n", XPAR_AXI_GPIO_0_BASEADDR);
							break;
						case '3':
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR, 0xff);
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+0x4, 0xee);
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+0x8, 0xdd);
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+0xc, 0xcc);
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+0x10, 0xbb);
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+0x14, 0xaa);
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+0x18, 0x99);
							Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+0x1c, 0x88);
							xil_printf ("*Task 3*\r\nHeader content (ff;ee;dd;cc;bb;aa;99;88) has been written to header memory (base_addr:0x%x) \r\n", XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR);
							Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR, 0xF);
							xil_printf ("'HEADER_LENGTH' and 'RUN-bit' (LSB) is set in control register (addr:0x%x) \r\n", XPAR_AXI_GPIO_0_BASEADDR);
							break;
						default:
							print_banner();
							break;
								}
						}
				}
	return 0;
}
