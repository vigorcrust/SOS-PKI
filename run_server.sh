#!/bin/sh
docker	run \
	-it \
	--rm \
	--name sos-pki-server \
	-p 4567:4567 \
	-v "$PWD"/app:/usr/src/app \
	-v "$PWD"/bundle:/usr/local/bundle \
	-w /usr/src/app \
	sos-pki-dev \
	rerun 'ruby server.rb'
