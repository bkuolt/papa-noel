
.DEFAULT_GOAL = install
.PHONE = install run clean

LOVE_PATH = $(PWD)"/src/"

install:
	@ $(shell ./install.sh)
	@echo "you can run the game with 'make run'"

run: install
	@love $(LOVE_PATH)

clean:
	zip src/Art.zip src/Art
	rm -f -r src/Art