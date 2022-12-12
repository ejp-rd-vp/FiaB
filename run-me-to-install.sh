#!/bin/bash
mkdir $HOME/tmp
export TMPDIR=$HOME/tmp

docker volume remove -f fair-data-point fdp-client-assets fdp-client-css fdp-client-scss fdp-server mongo-data mongo-init 

docker volume create fair-data-point

docker volume create fdp-server

#docker volume create fdp-client
docker volume create fdp-client-assets
docker volume create fdp-client-scss

#docker volume create mongo
docker volume create mongo-data
docker volume create mongo-init

GREEN='\033[0;32m'
NC='\033[0m' # No Color
CWD=$(pwd)


function ctrl_c() {
        docker-compose -f $CWD/metadata/docker-compose.yml down
        docker-compose -f $CWD/bootstrap/docker-compose.yml down
        exit 2
}

trap ctrl_c 2


cd bootstrap
echo ""
echo ""
echo -e "${GREEN}Creating GraphDB and bootstrapping it - this will take several minutes"
echo -e "Go make a nice cup of tea and then come back to check on progress"
echo -e "${NC}"
echo ""

docker-compose up --build -d
sleep 200

echo ""
echo -e "${GREEN}Setting up FAIR Data Point client and server${NC}"
echo ""
cd ../metadata

docker-compose up --build -d
sleep 200
docker-compose down


docker run -v mongo-data:/data/db --name helper busybox true
docker cp ./mongo/data helper:/data/db
docker rm helper


docker run -v mongo-init:/docker-entrypoint-initdb.d/ --name helper busybox true
docker cp ./mongo/init-mongo.js helper:/docker-entrypoint-initdb.d/init-mongo.js
docker rm helper 


echo ""
echo ""
docker-compose up -d
sleep 20
docker-compose down
docker volume remove -f mongo-data
docker volume create mongo-data
docker-compose up -d
sleep 20

echo ""
echo ""
echo -e "${GREEN}Installation Complete!"
echo -e  "${GREEN}you now have 10 minutes to test things."  
echo -e  "${GREEN}If GraphDB is working, you should be able to access it at: http://localhost:7200"
echo -e  "${GREEN}If Your FAIR Data Point is working, you should be able to access it at: http://localhost:7070"
echo ""
echo -e  "${GREEN}For further instructions and tests, read the documentation on the FAIR-in-a-box GitHub page${NC}"
echo ""
echo -e  "${GREEN}You can stop this test phase at any time with CTRL-C, then wait for the docker images to shut down cleanly before continuing${NC}"
sleep 600
docker-compose -f $CWD/metadata/docker-compose.yml down
docker-compose -f $CWD/bootstrap/docker-compose.yml down
cd ../FAIR-ready-to-go
echo ""
echo -e  "${GREEN}Shutdown Complete.  You have been moved into the 'FAIR-ready-to-go' folder where the production version of the docker-compose file lives.  Just docker-compose up to get started!${NC}"

