
.DEFAULT_GOAL = install
.PHONE = install run

LOVE_PATH = $(PWD)"/src/"

install:
	@ $(shell ./install.sh)
	@echo "you can run the game with 'make run'"

run: install
	@love $(LOVE_PATH)