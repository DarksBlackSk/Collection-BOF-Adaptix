SUBDIRS := clipboard EdrEnum-BOF Keylogger-BOF wifi ghost_task
.PHONY: all $(SUBDIRS) clean
all: $(SUBDIRS)

$(SUBDIRS):
	@echo "=====>>  $@"
	@$(MAKE) --no-print-directory -C $@
	@echo ""

clean:
	@for dir in $(SUBDIRS); do \
		$(MAKE) --no-print-directory -C $$dir clean; \
	done
