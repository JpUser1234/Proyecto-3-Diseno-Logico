#Makefile con todo el flujo de trabajo para GOWIN. Utilizando Yosys, nextpnr, iverilog, gtkwave y openFPGALoader
# Linux-compatible version

#FPGA a utilizar... Esto no se debe modificar para efectos del curso.
BOARD  = tangnano9k
FAMILY = GW1N-9C
DEVICE = GW1NR-LV9QN88PC6/I5

# Toolchain paths for Linux
OSS_CAD_BIN = /usr/bin
OSS_CAD_LIB = /usr/lib

#Nombre del proyecto... Acá ponen el nombre que deseen.
PROYECT = Seven_seg

#Fuentes de diseno
SOURCES := $(filter-out ../design/Testbench_decodif_Hamming.sv, $(wildcard ../design/*.v ../design/*.sv)) #Todas las fuentes .v o .sv que estan en design (excluye testbench)
#Si quieren indicarlas una a una, pueden hacerlo como en este ejemplo:
#SOURCES = ../design/module_top_deco_gray.v ../design/module_input_deco_gray.v 

#Fuente de simulacion
#aca va el testbench que quieran simular
TESTBENCH = ../sim/diagnostic_tb.sv

# Constraints para el proyecto
#aca va el archivo de constraints del proyecto
CONSTRAINTS = ../constr/Constraints.cst

#el top se indica sin la extension .v, esto hace referencia al nombre que le pusieron al módulo y no al archivo en si.
TOP_DESIGN = top
TOP_TB     = diagnostic_tb

#nombre del vcd que va a generar el tb
VCD_FILE = ${TOP_TB}.vcd

# Entorno limpio para evitar que el Snap de VS Code inyecte módulos GTK incompatibles
GTKWAVE_CMD = env -i HOME="$(HOME)" DISPLAY="$(DISPLAY)" XAUTHORITY="$(XAUTHORITY)" PATH=/usr/bin:/bin XDG_DATA_DIRS=/usr/local/share/:/usr/share/ /usr/bin/gtkwave


all: synth pnr bitstream load

# Synthesis
synth: ${SOURCES}
	@echo "Ejecutando la sintesis..."
	@yosys -p "read_verilog -sv ${SOURCES}; synth_gowin -top ${TOP_DESIGN} -json ${PROYECT}.json" > synthesis_${BOARD}.log 2>&1 
	@echo "COMPLETADO"

# Place and Route
pnr: ${PROYECT}.json
	@echo "Ejecutando el pnr..."
	@nextpnr-gowin --json ${PROYECT}.json --write ${PROYECT}_pnr.json --device ${DEVICE} --family ${FAMILY} --cst ${CONSTRAINTS} > pnr_${BOARD}.log 2>&1 
	@echo "COMPLETADO"

# Generar el Bitstream
bitstream: ${PROYECT}_pnr.json
	@echo "Generando ${PROYECT}_${BOARD}.fs"
	@gowin_pack -d ${FAMILY} -o ${PROYECT}_${BOARD}.fs ${PROYECT}_pnr.json
	@echo "COMPLETADO"
		
#Generar vcd con icarus verilog
test: ${SOURCES} ${TESTBENCH}
	@iverilog -o ${PROYECT}_test.o -s ${TOP_TB} -g2005-sv ${TESTBENCH} ${SOURCES}
	@vvp ${PROYECT}_test.o 
	
#Visualizar los diagramas de tiempo con GTKWave
wv: ${VCD_FILE}
	@$(GTKWAVE_CMD) ${VCD_FILE}
        
# Cargar el bitstream en la FPGA
load: ${PROYECT}_${BOARD}.fs
	@openFPGALoader -b ${BOARD} ${PROYECT}_${BOARD}.fs 

.PHONY: load  wv
.INTERMEDIATE: ${PROYECT}_pnr.json ${PROYECT}.json