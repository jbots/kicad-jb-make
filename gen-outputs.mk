# Delete targets and intermediate files if recipe doesn't complete, affects whole Makefile
.DELETE_ON_ERROR:

# Only if this is a git repository
ifneq ("$(wildcard .git)","")
git_name := $(shell git describe --dirty=-mod --always --tags)
git_date := $(shell date -d @`git log -1 --format=%ct` +"%Y%m%d%H%M")
else
git_name := UNVERSIONED
git_date := $(shell date +"%Y%m%d%H%M")
endif

# Strings
bold := $(shell tput bold)
normal := $(shell tput sgr0)
revision_standin := _BOARD_REVISION_STANDIN_
versioned_name := $(project)_$(git_date)_$(git_name)
versioned_short_name := $(project)_$(git_name)

# Tools
kibot := pipenv run tools/KiBot/src/kibot

# Directories
build_dir := output/built
gerb_dir := $(build_dir)/mfg/gerb
zip_dir := output/zip
versions_dir := output/versions

# Files
bom := output/$(project)-bom.xlsx
cpl := $(build_dir)/mfg/assembly/$(project)-both_pos.csv
tmp_brd := .temp_pcb_processed_
zip_path := $(zip_dir)/$(versioned_name).zip

$(bom): $(project).sch $(project).pro val_mpn.csv
	$(kibot) -c $(make_dir)/kibot-bom.yaml -d output -e $(project).sch -g output="$(project)-%i%v.%x"
	@echo "Update BoM with MPNs from list"
	cd tools/bom-val2mpn && pipenv sync 2> /dev/null
	pipenv-shebang tools/bom-val2mpn/process-bom.py $(bom) $(bom) val_mpn.csv

# Create a temp PCB file with revision standin replaced with git name
.INTERMEDIATE: $(tmp_brd).kicad_pcb $(tmp_brd).pro
$(tmp_brd).kicad_pcb: $(tmp_brd).pro
	@echo "Creating temporary pcb file at $(tmp_brd).kicad_pcb"
	sed 's/$(revision_standin)/$(git_name)/g' $(project).kicad_pcb > $(tmp_brd).kicad_pcb
$(tmp_brd).pro:
	cp $(project).pro $(tmp_brd).pro

# Only build outputs if inputs more recent than zip file
$(build_dir): *.sch *.kicad_pcb $(tmp_brd).kicad_pcb gen-outputs.yaml $(bom)

	rm -rf $(build_dir)/*
	$(kibot) -c gen-outputs.yaml -d $(build_dir) -e $(project).sch -b $(tmp_brd).kicad_pcb -g output="$(project)-%i%v.%x"
	$(make_dir)/cpl-process.py $(cpl) $(cpl)
	rm -f fp-info-cache?* # Delete extra cache file if it exists

	@echo "Gerbers: Eco layers => silkscreen, Fab and CrtYd => assembly, rm Margin"
	mv $(gerb_dir)/$(project)-Eco1_User.gbr $(gerb_dir)/$(project)-F_SilkS.gbr
	mv $(gerb_dir)/$(project)-Eco2_User.gbr $(gerb_dir)/$(project)-B_SilkS.gbr
	mv $(gerb_dir)/$(project)-*_CrtYd.gbr $(gerb_dir)/$(project)-*_Fab.gbr $(build_dir)/mfg/assembly/
	rm $(gerb_dir)/$(project)-Margin.gbr

	@echo "Copy BoM into assembly dir"
	cp $(bom) $(build_dir)/mfg/assembly/

	@# Ensure that output dir (target) has the latest timestamp so doesn't rebuild unnecessarily
	@touch $(build_dir)

$(zip_path): $(build_dir)
	@echo "Creating $(zip_path)"
	@mkdir -p $(zip_dir)
	cd $(build_dir); zip -r -FS $(shell realpath --relative-to=$(build_dir) $(zip_path)) *

	@printf "\nOutputs built for $(bold)$(versioned_short_name)$(normal)\n\n"
	@printf "zip archive at $(bold)$(zip_path)$(normal)\n\n"

# Unzip a specific archive to zip directory
$(versions_dir)/%: $(zip_dir)/%.zip
	@mkdir -p $(versions_dir)
	unzip $< -d $@

bom: $(bom)
build: $(build_dir)
zip: $(zip_path)

.PHONY: bom build zip
