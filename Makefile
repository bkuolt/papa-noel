.DEFAULT_GOAL = run
.PHONY = run install make

run:
    ./papa-noel

install:	
	# TODO: copy direcory to /opt/papa-noel
	# TODO: create symlink to /usr/bin

uninstall:
	# TODO: remove from /usr/bin
	# TODO: remove symlink from /usr/bin