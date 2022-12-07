build:
	docker build --build-arg user=$$USER \
		--build-arg uid=$$(id -u) \
		--build-arg gid=$$(id -g) \
		-t nice_dcv_client .

run:
	xauth nlist $$DISPLAY | sed -e 's/^..../ffff/' | xauth -f /tmp/.docker.xauth nmerge - && \
	docker run --rm \
		--device /dev/snd \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v /tmp/.docker.xauth:/tmp/.docker.xauth:rw \
		-v $(shell pwd)/config.dcv:/tmp/config.dcv \
		-v /dev/dri/card0:/dev/dri/card0 \
		-e DISPLAY=unix$$DISPLAY \
		-e XAUTHORITY=/tmp/.docker.xauth \
		-t nice_dcv_client
