# Copyright 2019 Bastian Kuolt
.PHONY = run install
.DEFAULT_GOAL = run

install:
	git clone https://github.com/rxi/json.lua.git
	git clone https://github.com/kikito/anim8.git
	sudo apt-get install love2d

clean:
	@rm -f -r *.git
run:
	@love .