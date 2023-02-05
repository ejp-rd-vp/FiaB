#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color
CWD=$PWD


echo -e "${GREEN}Is this a production installation, or are you just trying the installer?"
read -p "Production? [y/n]:" production
echo -e "${NC}"


case $production in
  y ) production="true";;
  Y ) production="true";;
  n ) production="false";;
  N ) production="false";;
  * ) echo "invalid response... exiting"; 
      exit 1;;
esac


if [ $production = "false" ]; then
  echo -e "${GREEN}Just trying things out!  Great!  Continuing with some sensible defaults for you..."
  uri="http://localhost:7070"
  echo -e "${GREEN}URI: $uri"
  P="test"
  echo -e "${GREEN}Component-prefix: $P"
  FDP_PORT="7070"
  echo -e "${GREEN}FDP Port: $FDP_PORT"
  GDB_PORT="7200"
  echo -e "${GREEN}GraphDB Port: $GDB_PORT"
  BEACON_PORT="8000"
  echo -e "${GREEN}Beacon2 Port: $BEACON_PORT"
  RDF_TRIGGER="4567"
  echo -e "${GREEN}RDF Transformation trigger port: $RDF_TRIGGER"
  echo -e "${NC}"
fi

if [ $production = "true" ]; then
  echo "Production Installation"
  read -p "Your permanent GUID (e.g. https://w3id.org/my-organization): " uri
fi

if [ -z $P ]; then
  read -p "enter a prefix for your components (e.g. euronmd): " P
  if [ -z $P ]; then
    echo "invalid..."
    exit 1
  fi
fi

if [ -z $FDP_PORT ]; then
  read -p "Enter the port where your FAIR Data Point will serve (e.g. 7070): " FDP_PORT
  if [ -z $FDP_PORT ]; then
    echo "invalid..."
    exit 1
  fi
fi

if [ -z $GDB_PORT ]; then
  read -p "Enter the port where your GraphDB will serve (e.g. 7200): " GDB_PORT
  if [ -z $GDB_PORT ]; then
    echo "invalid..."
    exit 1
  fi
fi

if [ -z $BEACON_PORT ]; then
  read -p  "Enter the port where your Beacon2 will serve (e.g. 8000): " BEACON_PORT
  if [ -z $BEACON_PORT ]; then
    echo "invalid..."
    exit 1
  fi
fi

if [ -z $RDF_TRIGGER ]; then
  read -p "Enter the port that will trigger your RDF transformation (e.g. 4567): " RDF_TRIGGER
  if [ -z $RDF_TRIGGER ]; then
    echo "invalid..."
    exit 1
  fi
fi

mkdir $HOME/tmp
export TMPDIR=$HOME/tmp
# needed by the main.py script
export FDP_PREFIX=$P

docker network rm bootstrap_default
docker rm  bootstrap_graphdb_1 metadata_fdp_1 metadata_fdp_client_1
docker volume remove -f "${P}-graphdb ${P}-fdp-client-assets ${P}-fdp-client-css ${P}-fdp-client-scss ${P}-fdp-server ${P}-mongo-data ${P}-mongo-init"

docker volume create "${P}-graphdb"
docker volume create "${P}-fdp-server"
docker volume create "${P}-fdp-client-assets"
docker volume create "${P}-fdp-client-scss"
docker volume create "${P}-mongo-data"
docker volume create "${P}-mongo-init"


function ctrl_c() {
        docker-compose -f "$CWD/metadata/docker-compose-${P}.yml" down
        docker-compose -f "$CWD/bootstrap/docker-compose-${P}.yml" down
        docker network rm bootstrap_default
        docker rm  bootstrap_graphdb_1 metadata_fdp_1 metadata_fdp_client_1
        if [ $production = "false" ]; then
          echo ""
          echo -e "${GREEN}because this is NOT a production server, I will now delete all assets and volumes.  You must re-run this installation script as a production server to recover.$NC"
          echo ""
          docker volume remove -f $P-graphdb $P-fdp-client-assets $P-fdp-client-css $P-fdp-client-scss $P-fdp-server $P-mongo-data $P-mongo-init
          docker volume remove -f $P-graphdb
        fi
        exit 2
}

trap ctrl_c 2


echo ""
echo ""
echo -e "${GREEN}Creating GraphDB and bootstrapping it - this will take about a minute"
echo -e "Go make a nice cup of tea and then come back to check on progress"
echo -e "${NC}"
echo ""

cd bootstrap
cp docker-compose-template.yml "docker-compose-${P}.yml"
sed -i s/{PREFIX}/${P}/ "docker-compose-${P}.yml"

docker-compose -f "docker-compose-${P}.yml" up --build -d
sleep 13
echo ""
echo -e "${GREEN}Setting up FAIR Data Point client and server${NC}"
echo ""




cd ../metadata

cp docker-compose-template.yml "docker-compose-${P}.yml"
cp ./fdp/application-template.yml "./fdp/application-${P}.yml"
sed -i s/{PREFIX}/$P/ "docker-compose-${P}.yml"
sed -i s/{FDP_PORT}/$FDP_PORT/ "docker-compose-${P}.yml"
sed -i s/{PREFIX}/$P/ "./fdp/application-${P}.yml"
sed -i s/{FDP_PORT}/$FDP_PORT/ "./fdp/application-${P}.yml"
sed -i s%{GUID}%$uri% "./fdp/application-${P}.yml"


docker-compose -f "docker-compose-${P}.yml" up --build -d
#sleep 30
#docker-compose down


# docker run -v mongo-data:/data/db --name helper busybox true
# docker cp ./mongo/data helper:/data/db
# docker rm helper


# docker run -v mongo-init:/docker-entrypoint-initdb.d/ --name helper busybox true
# docker cp ./mongo/init-mongo.js helper:/docker-entrypoint-initdb.d/init-mongo.js
# docker rm helper 


# echo ""
# echo ""
# docker-compose up -d
# sleep 30
# docker-compose down
# docker volume remove -f mongo-data
# docker volume create mongo-data
#docker-compose up -d
sleep 15

echo ""
echo -e "${GREEN}Creating a production server folder in ${NC} ./${P}-ready-to-go/"
echo ""

cd ..
cp -r ./FAIR-ready-to-go ./${P}-ready-to-go
cp ./${P}-ready-to-go/docker-compose-template.yml "./${P}-ready-to-go/docker-compose-${P}.yml"
cp ./${P}-ready-to-go/fdp/application-template.yml "./${P}-ready-to-go/fdp/application-${P}.yml"
cp ./${P}-ready-to-go/.env_template "./${P}-ready-to-go/.env"
sed -i s/{PREFIX}/${P}/ "./${P}-ready-to-go/docker-compose-${P}.yml"
sed -i s/{FDP_PORT}/${FDP_PORT}/ "./${P}-ready-to-go/docker-compose-${P}.yml"
sed -i s/{GDB_PORT}/${GDB_PORT}/ "./${P}-ready-to-go/docker-compose-${P}.yml"
sed -i s/{BEACON_PORT}/${BEACON_PORT}/ "./${P}-ready-to-go/docker-compose-${P}.yml"
sed -i s/{RDF_TRIGGER}/${RDF_TRIGGER}/ "./${P}-ready-to-go/docker-compose-${P}.yml"
sed -i s/{PREFIX}/${P}/ "./${P}-ready-to-go/fdp/application-${P}.yml"
sed -i s/{FDP_PORT}/${FDP_PORT}/ "./${P}-ready-to-go/fdp/application-${P}.yml"
sed -i s%{GUID}%${uri}% "./${P}-ready-to-go/fdp/application-${P}.yml"
sed -i s/{CDE_DB_NAME}/${P}-cde/ "./${P}-ready-to-go/.env"
sed -i s%{GUID}%$uri% "./${P}-ready-to-go/.env"

echo ""
echo ""
echo -e "${GREEN}Installation Complete!"
echo -e  "${GREEN}you now have 10 minutes to test things."  
echo -e  "${GREEN}If GraphDB is working, you should be able to access it at: http://localhost:7200  (NOTE: this is NOT the port that will serve GraphDB in your production service!  This is only used for the test phase you are currently doing..."
echo -e  "${GREEN}If Your FAIR Data Point is working, you should be able to access it at: $uri"
echo ""
echo -e  "${GREEN}For further instructions and tests, read the documentation on the FAIR-in-a-box GitHub page${NC}"
echo ""
echo -e  "${GREEN}You can stop this test phase at any time with CTRL-C, then wait for the docker images to shut down cleanly before continuing${NC}"
if [ $production = "true" ]; then
  echo -e  "${GREEN}If you stop this test phase because it was successful, please note that you must cd into the ${NC}'${P}-ready-to-go'${GREEN} folder to start the production server ${NC}"
fi

sleep 600
docker-compose -f "${CWD}/metadata/docker-compose-${P}.yml" down
docker-compose -f "${CWD}/bootstrap/docker-compose-${P}.yml" down
docker network rm bootstrap_default
docker rm  bootstrap_graphdb_1 metadata_fdp_1 metadata_fdp_client_1
if [ $production = "false" ]; then
  echo ""
  echo -e "${GREEN}because this is NOT a production server, I will now delete all assets and volumes.  You must re-run this installation script as a production server to recover.$NC"
  echo ""
  docker volume remove -f $P-graphdb $P-fdp-client-assets $P-fdp-client-css $P-fdp-client-scss $P-fdp-server $P-mongo-data $P-mongo-init
  docker volume remove -f $P-graphdb
fi


echo ""
echo -e "${GREEN}Shutdown Complete.  Please now move into the ${NC} ./${P}-ready-to-go/ ${GREEN} folder where the full version of the docker-compose-{P}.yml file lives."
echo ""
echo -e "${GREEN}To start your full FAIR-in-a-box server, cd to that folder (or move it elsewhere) and and type:  "
echo -e "docker-compose -f docker-compose-${P}.yml up -d ${NC}"
echo ""

