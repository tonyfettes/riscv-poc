SIM = SW_VCS=2020.12-SP2-1 vcs
SIM_FLAGS_MACRO = $(foreach M,MACRO,+define+$(M))
SIM_FLAGS = +v2k \
						-V \
						-sverilog \
						+vc \
						-Mupdate \
						-line \
						-full64 \
						+vcs+vcdpluson \
						-kdb \
						-lca \
						-debug_access+all \
						+incdir+$(INC_DIR) \
						$(SIM_FLAGS_MACRO)
