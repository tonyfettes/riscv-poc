MACRO += SIM

include make/sim/vcs.mk

SIM_TGT := $(SIM_DIR)/$(SIM_EXE)
SIM_RUN := $(subst /,_,$(SIM_DIR)/$(SIM_EXE))
SIM_DIR := $(SIM_DIR)/$(SIM_EXE).d

$(SIM_DIR)/$(SIM_EXE): $(SIM_SRC) | $(SIM_DIR)
	$(SIM) $(SIM_FLAGS) $^ -o $@

$(SIM_TGT): $(SIM_DIR)/$(SIM_EXE)
	ln -sf $(SIM_EXE).d/$(SIM_EXE) $@

$(SIM_DIR):
	mkdir -p $@

$(SIM_RUN): $(SIM_DIR)/$(SIM_EXE)
	cd $(SIM_DIR) && ./$(SIM_EXE)
