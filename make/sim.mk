MACRO += SIM

include make/sim/vcs.mk

$(SIM_DIR)/$(SIM_EXE): $(SIM_SRC)
	$(SIM) $(SIM_FLAGS) $^ -o $@
