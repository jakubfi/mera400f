
# --- Project configuration -------------------------------------------------

PROJECT = mera400f
TOPLEVEL = p_d
SOURCES_DIR = src
SOURCES = mera400f.v \
	counter4.v \
	ffd.v ffjk.v \
	decoder16.v decoder_bcd.v \
	univib.v \
	alu181.v carry182.v \
	latch16.v \
	p_r.v regs.v r0.v rb.v nb.v \
	p_d.v \
	p_x.v \
	p_m.v \
	p_p.v rm.v rzp.v \
	p_a.v
TESTS_DIR = tests
TESTS = regs.v p_d.v \
	alu_add_16bit_182.v alu_add_16bit.v alu_fn.v \
	decoder_bcd.v decoder16.v
ASSIGNMENTS = $(SOURCES_DIR)/assignments.qsf
QSYS_SYNTH = VERILOG
# See: https://github.com/jakubfi/altlogfilter (or comment out the line below)
ALTLOGFILTER = alf -c --

FAMILY = CycloneII
DEVICE = EP2C8Q208C8
PGM_CABLE = 1

FPGA_ROOT = ~/fpga
LIBS32_DIR = $(FPGA_ROOT)/lib32

# --- Quartus environment and tools --------------------------------------

ALTERA_ROOT = $(FPGA_ROOT)/altera/13.0sp1
Q_BINDIR = $(ALTERA_ROOT)/quartus/bin
LIB_PATHS = $(LIBS32_DIR):$(ALTERA_ROOT)/quartus/linux64:$(ALTERA_ROOT)/quartus/linux
NIOSDEV = $(ALTERA_ROOT)/nios2eds

Q_LIB_PREFIX = LD_LIBRARY_PATH=$(LIB_PATHS)
Q_SH =  $(Q_LIB_PREFIX) $(Q_BINDIR)/quartus_sh
Q_MAP = $(Q_LIB_PREFIX) $(Q_BINDIR)/quartus_map
Q_FIT = $(Q_LIB_PREFIX) $(Q_BINDIR)/quartus_fit
Q_ASM = $(Q_LIB_PREFIX) $(Q_BINDIR)/quartus_asm
Q_STA = $(Q_LIB_PREFIX) $(Q_BINDIR)/quartus_sta
Q_PGM = $(Q_LIB_PREFIX) $(Q_BINDIR)/quartus_pgm
QSYS_GEN = $(Q_LIB_PREFIX) SOPC_KIT_NIOS2=$(NIOSDEV) $(ALTERA_ROOT)/quartus/sopc_builder/bin/qsys-generate

# --- Tool arguments -----------------------------------------------------

COMMON_ARGS = --no_banner --64bit
SETTINGS_ARGS = --write_settings_files=off --read_settings_files=on
MAP_ARGS = $(COMMON_ARGS) $(SETTINGS_ARGS) --family=$(FAMILY)
FIT_ARGS = $(COMMON_ARGS) $(SETTINGS_ARGS) --part=$(DEVICE)
ASM_ARGS = $(COMMON_ARGS) $(SETTINGS_ARGS)
STA_ARGS = $(COMMON_ARGS) $(SETTINGS_ARGS)
PGM_ARGS = $(COMMON_ARGS) -c $(PGM_CABLE)
QSYS_ARGS = --synthesis=$(QSYS_SYNTH)

# --- Files --------------------------------------------------------------

OUT_DIR = output_files
PROJECT_FILE = $(PROJECT).qpf
SETTINGS_FILE = $(PROJECT).qsf
SOURCES_FILE = $(PROJECT)_sources.qsf
MAP_OUTPUT = db/$(PROJECT).map.cdb
FIT_OUTPUT = db/$(PROJECT).cmp.cdb
SOF_OUTPUT = $(OUT_DIR)/$(PROJECT).sof
POF_OUTPUT = $(OUT_DIR)/$(PROJECT).pof

SRCS = $(addprefix $(SOURCES_DIR)/,$(SOURCES))
SRCS_V = $(filter %.v,$(SRCS))
SRCS_SV = $(filter %.sv,$(SRCS))
SRCS_QSYS = $(filter %.qsys,$(SRCS))
SRCS_BDF = $(filter %.bdf,$(SRCS))
SRCS_TDF = $(filter %.tdf,$(SRCS))
SRCS_VHD = $(filter %.vhd,$(SRCS))
SRCS_SMF = $(filter %.smf,$(SRCS))
SRCS_EDF = $(filter %.edf,$(SRCS))
SOPCINFO = $(subst .qsys,.sopcinfo,$(SRCS_QSYS))
TSTS = $(addprefix $(TESTS_DIR)/,$(TESTS))
OBJS = $(subst .v,.bin,$(TSTS))

# --- Quartus targets ----------------------------------------------------

.phony: all clean distclean map mapsum fit fitsum asm install jtag as sta ivtest test sum

all: map
test: ivtest
sum: mapsum
map: $(MAP_OUTPUT)
mapsum: $(MAP_OUTPUT)
	cat $(OUT_DIR)/$(PROJECT).map.summary
fit: $(FIT_OUTPUT)
fitsum: $(FIT_OUTPUT)
	cat $(OUT_DIR)/$(PROJECT).fit.summary
asm: $(SOF_OUTPUT)
install: jtag
qsys: $(SOPCINFO)

$(SETTINGS_FILE): Makefile
	$(ALTLOGFILTER) $(Q_SH) --prepare -f $(FAMILY) -d $(DEVICE) -t $(TOPLEVEL) $(PROJECT)
	$(ALTLOGFILTER) $(Q_SH) --set PROJECT_OUTPUT_DIRECTORY=$(OUT_DIR) $(PROJECT)
	@echo "" >> $(SETTINGS_FILE)
	@echo -e "source $(ASSIGNMENTS)" >> $(SETTINGS_FILE)
	@echo -e "source $(SOURCES_FILE)" >> $(SETTINGS_FILE)

$(SOURCES_FILE): $(SETTINGS_FILE)
	@echo -e "\n# ! WARNING ! this file is automaticaly generated by make, do not edit!\n" > $(SOURCES_FILE)
	@$(foreach var,$(SRCS_V),echo "set_global_assignment -name VERILOG_FILE $(var)" >> $(SOURCES_FILE);)
	@$(foreach var,$(SRCS_SV),echo "set_global_assignment -name SYSTEMVERILOG_FILE $(var)" >> $(SOURCES_FILE);)
	@$(foreach var,$(SRCS_QSYS),echo "set_global_assignment -name QSYS_FILE $(var)" >> $(SOURCES_FILE);)
	@$(foreach var,$(SRCS_BDF),echo "set_global_assignment -name BDF_FILE $(var)" >> $(SOURCES_FILE);)
	@$(foreach var,$(SRCS_TDF),echo "set_global_assignment -name AHDL_FILE $(var)" >> $(SOURCES_FILE);)
	@$(foreach var,$(SRCS_VHD),echo "set_global_assignment -name VHDL_FILE $(var)" >> $(SOURCES_FILE);)
	@$(foreach var,$(SRCS_SMF),echo "set_global_assignment -name SMF_FILE $(var)" >> $(SOURCES_FILE);)
	@$(foreach var,$(SRCS_EDF),echo "set_global_assignment -name EDIF_FILE $(var)" >> $(SOURCES_FILE);)

$(MAP_OUTPUT): $(SRCS) $(SOURCES_FILE)
	$(ALTLOGFILTER) $(Q_MAP) $(MAP_ARGS) $(PROJECT)

$(FIT_OUTPUT): $(MAP_OUTPUT) $(ASSIGNMENTS)
	$(ALTLOGFILTER) $(Q_FIT) $(FIT_ARGS) $(PROJECT)

$(SOF_OUTPUT): $(FIT_OUTPUT)
	$(ALTLOGFILTER) $(Q_ASM) $(ASM_ARGS) $(PROJECT)

$(POF_OUTPUT): $(FIT_OUTPUT)
	$(ALTLOGFILTER) $(Q_ASM) $(ASM_ARGS) $(PROJECT)

sta: $(FIT_OUTPUT)
	$(Q_STA) $(STA_ARGS) $(PROJECT)

jtag: $(SOF_OUTPUT)
	$(Q_PGM) $(PGM_ARGS) -m JTAG -o "p;$(SOF_OUTPUT)"

as: $(POF_OUTPUT)
	$(Q_PGM) $(PGM_ARGS) -m AS -o "pv;$(POF_OUTPUT)"

$(SOPCINFO): $(SRCS_QSYS)
	$(QSYS_GEN) $(SRCS_QSYS) $(QSYS_ARGS)

# --- Icarus Verilog testing ---------------------------------------------

ivtest: $(OBJS)

%.bin: %.v $(SRCS)
	iverilog -y $(SOURCES_DIR) -y $(TESTS_DIR) -o $@ $<
	./$@

# --- Cleanups -----------------------------------------------------------

clean:
	rm -rf *.rpt *.chg smart.log *.htm *.eqn *.pin *.sof *.pof db incremental_db $(OUT_DIR) *.map.summary *.sopcinfo $(TESTS_DIR)/*.bin

distclean: clean
	rm -rf $(PROJECT_FILE) $(SETTINGS_FILE) $(SOURCES_FILE)

