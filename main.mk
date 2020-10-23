add-git-tools:
	git submodule add https://github.com/jbots/kicad-git-lib.git tools/kicad-git-lib

add-build-tools:
	git submodule add https://github.com/jbots/bom-val2mpn.git tools/bom-val2mpn
	git submodule add https://github.com/INTI-CMNB/KiBot.git tools/KiBot

add-project-libs:
	@echo "Adding library submodules to repository"
	$(subst lib:,./tools/kicad-git-lib/add-submodule,$(libs))

sync:
	git submodule update --init --recursive

create-sub-lib-config:
	@echo "Creating sub-lib-config file"
	$(file >sub-lib-config,$(sub_lib_config_contents))

create-gitignore:
	@echo "Creating gitignore"
	$(file >.gitignore,$(gitignore_contents))

sub-lib-update:
	./tools/kicad-git-lib/sub-lib-manage -c sub-lib-config

new: add-git-tools add-project-libs create-sub-lib-config create-gitignore sub-lib-update

.PHONY: add-git-tools add-build-tools add-project-ilbs sync create-sub-lib-config create-gitignore sub-lib-update new
