COMMAND ?= `grep 'web' Procfile | cut -d ':' -f2`
REVISION ?= `git rev-parse HEAD`

.PHONY: build_docker_image run

build_docker_image:
	DOCKER_BUILDKIT=1 docker build \
	  --build-arg REVISION=$(REVISION) \
	  --progress=plain \
	  -t active_record_upsert .

run: build_docker_image
	docker run -it active_record_upsert bin/run_docker_test.sh
