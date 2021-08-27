SHELL := /bin/bash
IMAGE=pigeosolutions/sendmail
REV=`git rev-parse --short HEAD`
DATE=`date +%Y%m%d-%H%M`

all: pull-deps docker-build docker-push

pull-deps:
	docker pull debian:buster

docker-build:
	docker build -f Dockerfile -t ${IMAGE}:latest . ;\
	docker tag  ${IMAGE}:latest ${IMAGE}:${DATE}-${REV} ;\
	echo built ${IMAGE}:${DATE}-${REV}

docker-push:
	docker push ${IMAGE}:latest ;\
	docker push ${IMAGE}:${DATE}-${REV} ;\
	echo pushed ${IMAGE}:${DATE}-${REV}
