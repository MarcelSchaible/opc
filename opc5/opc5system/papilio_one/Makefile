# Paths that will need changing

PAPILIO_LOADER=/opt/GadgetFactory/papilio-loader/programmer
XILINX=/opt/Xilinx/14.7

# Shouldn't need to make changes below this point

BIT_FILE=working/opc5system.bit
BMM_FILE=opc5system_bd.bmm

# Papilio dev environment
PROG=${PAPILIO_LOADER}/linux32/papilio-prog
BSCAN=${PAPILIO_LOADER}/bscan_spi_xc3s500e.bit
DATA2MEM=${XILINX}/ISE_DS/ISE/bin/lin/data2mem


build: opc5system.bit

deploy: opc5system.bit
	$(PROG) -v -f opc5system.bit

program: opc5system.bit
	$(PROG) -v -b $(BSCAN) -f opc5system.bit -sa -r
	$(PROG) -c

opc5system.bit: monitor.mem $(BIT_FILE)
	$(DATA2MEM) -log data2mem.log -bm $(BMM_FILE) -bd monitor.mem -bt $(BIT_FILE) -o b opc5system.bit

monitor.mem : ../../monitor.s
	python ../../opc5asm.py ../../monitor.s monitor.hex
	tr " " "\n" <monitor.hex | head -2048 > monitor.mem

.phony: clean

clean:
	rm -f opc5system.bit monitor.mem monitor.hex
