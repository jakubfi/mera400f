
# --- User configuration -------------------------------------------------

PROJECT = mera400f
TOPLEVEL = $(PROJECT)
SOURCES_DIR= src
SOURCES = mera400f.v regs.v
TESTS_DIR = tests
TESTS = regs_tb.v
ASSIGNMENTS = assignments.qsf
QSYS_SYNTH = VERILOG
ALTLOGFILTER = | tools/altlogfilter -c

FAMILY = Cyclone II
DEVICE = EP2C8Q208C8
CABLE = 1

# --- Internal variables -------------------------------------------------

OUT_DIR = output_files
PROJECT_FILE = $(PROJECT).qpf
SETTINGS_FILE = $(PROJECT).qsf
SOURCES_FILE = $(PROJECT)_sources.qsf

COMMON_ARGS = --no_banner --64bit
SETTINGS_ARGS = --write_settings_files=off --read_settings_files=on
MAP_ARGS = $(COMMON_ARGS) $(SETTINGS_ARGS) --family="$(FAMILY)"
FIT_ARGS = $(COMMON_ARGS) $(SETTINGS_ARGS) --part="$(DEVICE)"
ASM_ARGS = $(COMMON_ARGS) $(SETTINGS_ARGS)
STA_ARGS = $(COMMON_ARGS) $(SETTINGS_ARGS)
PGM_ARGS = $(COMMON_ARGS) -c "$(CABLE)"
QSYS_ARGS = --synthesis=$(QSYS_SYNTH)

STAMP = touch
STAMP_DIR = stamps
MAP_READY = $(STAMP_DIR)/map.stamp
FIT_READY = $(STAMP_DIR)/fit.stamp

.phony: all clean distclean init map fit asm install jtag as sta

all: asm
test: ivtest

# --- Prepare project configuration --------------------------------------

init: $(PROJECT_FILE)

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

$(PROJECT_FILE):
ifneq ("$(wildcard $(PROJECT_FILE))","")
	@echo "Project configuration file \"$(PROJECT_FILE)\" has already been generated, nothing to do."
else
	quartus_sh --prepare -f "$(FAMILY)" -d "$(DEVICE)" -t "$(TOPLEVEL)" $(PROJECT) $(ALTLOGFILTER)
	quartus_sh --set PROJECT_OUTPUT_DIRECTORY="$(OUT_DIR)" $(PROJECT) $(ALTLOGFILTER)
	echo "" >> $(SETTINGS_FILE)
	echo -e "source $(SOURCES_DIR)/$(ASSIGNMENTS)" >> $(SETTINGS_FILE)
	echo -e "source $(SOURCES_FILE)" >> $(SETTINGS_FILE)
	mkdir -p $(STAMP_DIR)
endif

$(SOURCES_FILE): $(SRCS)
	echo -e "\n# ! WARNING ! this file is automaticaly generated by make, do not edit!\n" > $(SOURCES_FILE)
	$(foreach var,$(SRCS_V),echo "set_global_assignment -name VERILOG_FILE $(var)" >> $(SOURCES_FILE);)
	$(foreach var,$(SRCS_SV),echo "set_global_assignment -name SYSTEMVERILOG_FILE $(var)" >> $(SOURCES_FILE);)
	$(foreach var,$(SRCS_QSYS),echo "set_global_assignment -name QSYS_FILE $(var)" >> $(SOURCES_FILE);)
	$(foreach var,$(SRCS_BDF),echo "set_global_assignment -name BDF_FILE $(var)" >> $(SOURCES_FILE);)
	$(foreach var,$(SRCS_TDF),echo "set_global_assignment -name AHDL_FILE $(var)" >> $(SOURCES_FILE);)
	$(foreach var,$(SRCS_VHD),echo "set_global_assignment -name VHDL_FILE $(var)" >> $(SOURCES_FILE);)
	$(foreach var,$(SRCS_SMF),echo "set_global_assignment -name SMF_FILE $(var)" >> $(SOURCES_FILE);)
	$(foreach var,$(SRCS_EDF),echo "set_global_assignment -name EDIF_FILE $(var)" >> $(SOURCES_FILE);)

# --- Actual targets -----------------------------------------------------

map: $(MAP_READY)
fit: $(FIT_READY)
asm: $(OUT_DIR)/$(PROJECT).sof
install: jtag
qsys: $(SOPCINFO)

$(MAP_READY): $(PROJECT_FILE) $(SETTINGS_FILE) $(SOURCES_FILE)
	quartus_map $(MAP_ARGS) $(PROJECT) $(ALTLOGFILTER) && $(STAMP) $(MAP_READY)

$(FIT_READY): $(MAP_READY) $(SOURCES_DIR)/$(ASSIGNMENTS)
	quartus_fit $(FIT_ARGS) $(PROJECT) $(ALTLOGFILTER) && $(STAMP) $(FIT_READY)

$(OUT_DIR)/$(PROJECT).sof: $(FIT_READY)
	quartus_asm $(ASM_ARGS) $(PROJECT) $(ALTLOGFILTER)

sta: $(FIT_READY)
	quartus_sta $(STA_ARGS) $(PROJECT)

jtag: $(OUT_DIR)/$(PROJECT).sof
	quartus_pgm $(PGM_ARGS) -m JTAG -o "p;$(OUT_DIR)/$(PROJECT).sof"

as: $(OUT_DIR)/$(PROJECT).sof
	quartus_pgm $(PGM_ARGS) -m AS -o "pv;$(OUT_DIR)/$(PROJECT).pof"

$(SOPCINFO): $(SRCS_QSYS)
	qsys-generate $(SRCS_QSYS) $(QSYS_ARGS)

# --- Icarus Verilog testing ---------------------------------------------

ivtest: $(OBJS)
	$(foreach var,$(OBJS),./$(var))

%.bin: %.v
	iverilog -y $(SOURCES_DIR) -y $(TESTS_DIR) -o $@ $<

# --- Cleanups -----------------------------------------------------------

clean:
	rm -rf *.rpt *.chg smart.log *.htm *.eqn *.pin *.sof *.pof db incremental_db $(OUT_DIR) *.map.summary $(STAMP_DIR)/* *.sopcinfo $(TESTS_DIR)/*.bin

distclean: clean
	rm -rf $(PROJECT_FILE) $(SETTINGS_FILE) $(SOURCES_FILE) $(STAMP_DIR)

