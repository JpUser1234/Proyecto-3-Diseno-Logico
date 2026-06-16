#Makefile con todo el flujo de trabajo para GOWIN. Utilizando Yosys, nextpnr, iverilog, gtkwave y openFPGALoader

#FPGA a utilizar... Esto no se debe modificar para efectos del curso.
BOARD  = tangnano9k
FAMILY = GW1N-9C
DEVICE = GW1NR-LV9QN88PC6/I5

# Toolchain paths
OSS_CAD_BIN = C:\Users\gabri\Downloads\oss-cad-suite\bin
OSS_CAD_LIB = C:\Users\gabri\Downloads\oss-cad-suite\lib
OSS_CAD_PATH = $(OSS_CAD_LIB);%PATH%

#Nombre del proyecto... Acá ponen el nombre que deseen.
PROYECT = Seven_seg

#Fuentes de diseno
SOURCES := $(filter-out ../design/Testbench_decodif_Hamming.sv, $(wildcard ../design/*.v ../design/*.sv))

# Constraints para el proyecto
CONSTRAINTS = ../constr/Constraints.cst

#el top se indica sin la extension .v
TOP_DESIGN = top
TOP_TB     = diagnostic_tb
TOP_TB_DIV = divider_tb

#nombre del vcd que va a generar el tb
VCD_FILE     = top_tb.vcd
VCD_FILE_DIV = top_tb.vcd


all: synth pnr bitstream load

# Synthesis
synth: ${SOURCES}
	@echo "Ejecutando la sintesis..."
	@set PATH=$(OSS_CAD_PATH) && "$(OSS_CAD_BIN)\yosys.exe" -p "read_verilog -sv ${SOURCES}; synth_gowin -top ${TOP_DESIGN} -json ${PROYECT}.json" > synthesis_${BOARD}.log 2>&1
	@echo "COMPLETADO"

# Place and Route
pnr: ${PROYECT}.json
	@echo "Ejecutando el pnr..."
	@set PATH=$(OSS_CAD_PATH) && "$(OSS_CAD_BIN)\nextpnr-gowin.exe" --json ${PROYECT}.json --write ${PROYECT}_pnr.json --device ${DEVICE} --family ${FAMILY} --cst ${CONSTRAINTS} > pnr_${BOARD}.log 2>&1
	@echo "COMPLETADO"

# Generar el Bitstream
bitstream: ${PROYECT}_pnr.json
	@echo "Generando ${PROYECT}_${BOARD}.fs"
	@set PATH=$(OSS_CAD_PATH) && "$(OSS_CAD_BIN)\gowin_pack.exe" -d ${FAMILY} -o ${PROYECT}_${BOARD}.fs ${PROYECT}_pnr.json
	@echo "COMPLETADO"

#Generar vcd con icarus verilog - testbench original
test: ${SOURCES} ../sim/diagnostic_tb.sv
	@iverilog -o ${PROYECT}_test.o -s ${TOP_TB} -g2005-sv ../sim/diagnostic_tb.sv ${SOURCES}
	@vvp ${PROYECT}_test.o

#Generar vcd con icarus verilog - testbench del divisor
test_div: ${SOURCES} ../sim/divider_tb.sv
	@set PATH=$(OSS_CAD_PATH) && "$(OSS_CAD_BIN)\iverilog.exe" -o ${PROYECT}_div_test.o -s ${TOP_TB_DIV} -g2005-sv ../sim/divider_tb.sv ${SOURCES}
	@set PATH=$(OSS_CAD_PATH) && "$(OSS_CAD_BIN)\vvp.exe" ${PROYECT}_div_test.o

#Visualizar los diagramas de tiempo con GTKWave - simulacion original
wv: ${VCD_FILE}
	gtkwave ${VCD_FILE}

#Visualizar los diagramas de tiempo con GTKWave - simulacion divisor
wv_div: ${VCD_FILE_DIV}
	@set PATH=$(OSS_CAD_PATH) && "$(OSS_CAD_BIN)\gtkwave.exe" ${VCD_FILE_DIV}

# Cargar el bitstream en la FPGA
load: ${PROYECT}_${BOARD}.fs
	@set PATH=$(OSS_CAD_PATH) && "$(OSS_CAD_BIN)\openFPGALoader.exe" -b ${BOARD} ${PROYECT}_${BOARD}.fs

.PHONY: load wv wv_div
.INTERMEDIATE: ${PROYECT}_pnr.json ${PROYECT}.json