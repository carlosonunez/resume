OUT_DIR=output
IN_DIR=.
STYLES_DIR=styles
STYLE=chmduquesne
ENV_CREATE_COMMAND=docker-compose -f docker-compose.ci.yml run --rm decrypt-gpg
RESUME_TILE="Carlos's Resume | resume.carlosnunez.me"

all: clean html pdf

pdf: init
	FILE_NAME=`basename ${IN_DIR}/resume.md | sed 's/.md//g'`; \
	echo $$FILE_NAME.pdf; \
	pandoc --standalone --template $(STYLES_DIR)/$(STYLE).tex \
		--from markdown --to context \
		--variable papersize=A4 \
		--output $(OUT_DIR)/$$FILE_NAME.tex ${IN_DIR}/resume.md > /dev/null; \
	mtxrun --path=$(OUT_DIR) --result=$$FILE_NAME.pdf --script context $$FILE_NAME.tex > $(OUT_DIR)/context_$$FILE_NAME.log 2>&1; \

html: init
	FILE_NAME=`basename ${IN_DIR}/resume.md | sed 's/.md//g'`; \
	echo $$FILE_NAME.html; \
	pandoc --standalone --include-in-header include/header.html \
		--lua-filter=pdc-links-target-blank.lua \
		--from markdown --to html \
		--metadata pagetitle=$(RESUME_TILE) \
		--output $(OUT_DIR)/$$FILE_NAME.html ${IN_DIR}/resume.md \

docx: init
	FILE_NAME=`basename ${IN_DIR}/resume.md | sed 's/.md//g'`; \
	echo $$FILE_NAME.docx; \
	pandoc --standalone $$SMART ${IN_DIR}/resume.md --output $(OUT_DIR)/$$FILE_NAME.docx; \

rtf: init
	FILE_NAME=`basename ${IN_DIR}/resume.md | sed 's/.md//g'`; \
	echo $$FILE_NAME.rtf; \
	pandoc --standalone $$SMART ${IN_DIR}/resume.md --output $(OUT_DIR)/$$FILE_NAME.rtf; \

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
