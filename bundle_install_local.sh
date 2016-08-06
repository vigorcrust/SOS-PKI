#!/bin/bash

docker 	run \
	-it \
	--rm \
	-v "$PWD"/app:/usr/src/app \
	-v "$PWD"/bundle:/usr/local/bundle \
	-w /usr/src/app \
	sos-pki-dev:latest \
	bundle install
