OUT_DIR=output
IN_DIR=.
STYLE=chmduquesne
RESUME_TILE="Carlos's Resume | resume.carlosnunez.me"

all: clean apply_pre_transforms html pdf

apply_pre_transforms:
	sh /scripts/apply_pre_transforms.sh

pdf: init
	FILE_NAME=`basename ${IN_DIR}/resume.md | sed 's/.md//g'`; \
	weasyprint -v -p $(OUT_DIR)/$$FILE_NAME.html $(OUT_DIR)/$$FILE_NAME.pdf;

html: init
	FILE_NAME=`basename ${IN_DIR}/resume.md | sed 's/.md//g'`; \
	echo $$FILE_NAME.html; \
	pandoc --standalone --include-in-header include/header.html \
		--lua-filter=pdc-links-target-blank.lua \
		--from markdown --to html \
		--metadata pagetitle=$(RESUME_TILE) \
		--output $(OUT_DIR)/$$FILE_NAME.html ${IN_DIR}/resume_post.md &&  \
	sh /scripts/apply_transforms.sh

docx: init
	FILE_NAME=`basename ${IN_DIR}/resume.md | sed 's/.md//g'`; \
	echo $$FILE_NAME.docx; \
	pandoc --standalone $$SMART ${IN_DIR}/resume_post.md --output $(OUT_DIR)/$$FILE_NAME.docx; \

rtf: init
	FILE_NAME=`basename ${IN_DIR}/resume.md | sed 's/.md//g'`; \
	echo $$FILE_NAME.rtf; \
	pandoc --standalone $$SMART ${IN_DIR}/resume_post.md --output $(OUT_DIR)/$$FILE_NAME.rtf; \

init: dir version

dir:
	mkdir -p $(OUT_DIR)

version:
	PANDOC_VERSION=`pandoc --version | head -1 | cut -d' ' -f2 | cut -d'.' -f1`; \
	if [ "$$PANDOC_VERSION" -eq "2" ]; then \
		SMART=-smart; \
	else \
		SMART=--smart; \
	fi \

clean:
	rm -f $(OUT_DIR)/*
