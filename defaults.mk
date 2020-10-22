define sub_lib_config_contents
(sub-lib-config
  (sublib (type sym) (path lib/local/sym) (table AUTO))
  (sublib (type sym) (path lib/official/kicad-symbols/) (pathvar KICAD_SYMBOL_DIR))
  (sublib (type sym) (path lib/kicad-jb-public/sym/) (table AUTO))

  (sublib (type fp) (path lib/local/)))
  (sublib (type fp) (path lib/official/kicad-footprints/) (pathvar KISYSMOD))
  (sublib (type fp) (path lib/kicad-jb-public/) (table AUTO))
)
endef

define gitignore_contents
*.bck
*-bak
fp-info-cache
output/*
endef

define libs
lib: https://github.com/KiCad/kicad-symbols.git lib/official/kicad-symbols
lib: https://github.com/KiCad/kicad-footprints.git lib/official/kicad-footprints
lib: https://github.com/jbots/kicad-jb-public lib/kicad-jb-public
endef
