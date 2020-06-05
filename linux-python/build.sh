#!/bin/bash
docker build -f Dockerfile.ubuntu  -t ubuntu-python:latest .
docker build -f Dockerfile.centos  -t centos-python:latest .
