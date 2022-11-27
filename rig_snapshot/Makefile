.PHONY: venv, build, init, clean

build: init
	chalice package --pkg-format terraform --stage prod ./build

venv:
	[ -d ./venv ] || python3 -m venv venv
	. venv/bin/activate

init: venv
	python3 -m pip install -r ./requirements.txt
	
clean:
	rm ./venv/ -rf
	rm ./__pycache__/ -rf
	rm ./build/ -rf
