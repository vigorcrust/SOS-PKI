#!/bin/sh
docker	run \
	-it \
	--rm \
	--name sos-pki-tools \
	-v "$PWD"/app:/usr/src/app \
	-v "$PWD"/bundle:/usr/local/bundle \
	-w /usr/src/app \
	sos-pki-dev \
	ruby admin.rb $@
