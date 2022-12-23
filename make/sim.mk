MACRO += SIM

include make/sim/vcs.mk

SIM_TGT = $(SIM_DIR)/$(SIM_EXE)
SIM_RUN = $(subst /,_,$(SIM_DIR)/$(SIM_EXE))
SIM_INT = $(SIM_DIR)/$(SIM_EXE).d

$(SIM_INT)/$(SIM_EXE): $(SIM_SRC) | $(SIM_INT)
	$(SIM) $(SIM_FLAGS) $^ -o $@

$(SIM_TGT): $(SIM_INT)/$(SIM_EXE)
	ln -sf $(shell realpath --relative-to $(dir $(abspath $@)) $(dir $(abspath $<)))/$(notdir $<) $@

$(SIM_INT):
	mkdir -p $@

$(SIM_RUN): $(SIM_INT)/$(SIM_EXE)
	cd $(dir $<) && ./$(notdir $<)
