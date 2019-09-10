PATH=$(which love)

if [ PATH = "" ] 
then 
	sudo add-apt-repository ppa:bartbes/love-stable
	sudo apt-get update
	sudo apt-get install love2d
fi