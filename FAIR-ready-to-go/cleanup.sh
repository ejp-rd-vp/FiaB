#!/bin/bash
docker volume rm -f mongo-data mongo-init
docker volume create mongo-data
docker volume create mongo-init
