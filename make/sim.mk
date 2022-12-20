MACRO += SIM

include make/sim/vcs.mk

$(SIM_DIR)/$(SIM_EXE): $(SIM_SRC) | $(SIM_DIR)
	$(SIM) $(SIM_FLAGS) $^ -o $@

$(SIM_DIR):
	mkdir -p $@
