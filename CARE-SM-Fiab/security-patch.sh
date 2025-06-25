timestamp=$(date +"%Y-%m-%d")
outputfile=("./security_scan_output/scanresults_${timestamp}.txt")
touch ${outputfile}


image="ontotext/graphdb:10.8.0"
name="gdb"
echo "GRAPHDB\n\n" > ${outputfile}
echo "FDP\n\n" >> ${outputfile}
docker run -d --name ${name} ${image}
# use the appropriate distribution upgrade tool for that container’s operating system
echo "update"
docker exec -it ${name} apt-get -y update 
echo "dist-upgrade"
docker exec -it ${name} apt-get -y dist-upgrade 
echo "autoclean"
docker start ${name}
docker exec -it ${name} apt-get -y autoclean
# Commit the patched container, with a new name, overwriting the previous version
echo "commit"
docker commit ${name} fairdatasystems/${name}:${timestamp}
# stop the temporary container
docker stop ${name}
# delete the temporary container
docker rm ${name}
echo "push"
docker push fairdatasystems/${name}:${timestamp}
echo "pushed"
GDB="fairdatasystems/${name}:${timestamp}"
# run a scan to determine success
echo "trivy"
trivy image --scanners vuln --severity CRITICAL,HIGH -f table  --timeout 1800s fairdatasystems/${name}:${timestamp}  >> ${outputfile}
echo "END\n\n"
echo "END OF GRAPHDB\n\n\n\n\n\n" >> ${outputfile}


# fairdata/fairdatapoint:1.16.2
image="fairdata/fairdatapoint:1.16.2"
name="fdp"
echo "FDP\n\n" >> ${outputfile}
docker run -d --name ${name} ${image}
# use the appropriate distribution upgrade tool for that container’s operating system
echo "update"
docker exec -it ${name} apt-get -y update 
echo "dist-upgrade"
docker exec -it ${name} apt-get -y dist-upgrade 
echo "autoclean"
docker start ${name}
docker exec -it ${name} apt-get -y autoclean
# Commit the patched container, with a new name, overwriting the previous version
echo "commit"
docker commit ${name} fairdatasystems/${name}:${timestamp}
# stop the temporary container
docker stop ${name}
# delete the temporary container
docker rm ${name}
echo "push"
docker push fairdatasystems/${name}:${timestamp}
echo "pushed"
FDP="fairdatasystems/${name}:${timestamp}"
# run a scan to determine success
echo "trivy"
trivy image --scanners vuln --severity CRITICAL,HIGH -f table  --timeout 1800s fairdatasystems/${name}:${timestamp}  >> ${outputfile}
echo "END\n\n"
echo "END OF FDP\n\n\n\n\n\n" >> ${outputfile}


# fairdata/fairdatapoint-client:1.16.3
image="fairdata/fairdatapoint-client:1.16.3"
name="fdpclient"
echo "FDPCLIENT\n\n" >> ${outputfile}
docker run -d --name ${name} ${image} tail -f /dev/null
# use the appropriate distribution upgrade tool for that container’s operating system
docker exec -it ${name} apk upgrade --no-cache
# Commit the patched container, with a new name, overwriting the previous version
docker commit ${name} fairdatasystems/${name}:${timestamp}
# stop the temporary container
docker stop ${name}
# delete the temporary container
docker rm ${name}
echo "push"
docker push fairdatasystems/${name}:${timestamp}
echo "pushed"
FDPC="fairdatasystems/${name}:${timestamp}"
# run a scan to determine success
trivy image --scanners vuln --severity CRITICAL,HIGH -f table  --timeout 1800s fairdatasystems/${name}:${timestamp} >> ${outputfile}
echo "END OF FDPCLKIENT\n\n\n\n\n\n" >> ${outputfile}




# mongo:7.0
image="mongo:7.0"
name="mdb"
echo "MDB\n\n" >> ${outputfile}
docker run -d --name ${name} ${image}
# use the appropriate distribution upgrade tool for that container’s operating system
echo "update"
docker exec -it ${name} apt-get -y update 
echo "dist-upgrade"
docker exec -it ${name} apt-get -y dist-upgrade 
echo "autoclean"
docker start ${name}
docker exec -it ${name} apt-get -y autoclean
# Commit the patched container, with a new name, overwriting the previous version
echo "commit"
docker commit ${name} fairdatasystems/${name}:${timestamp}
# stop the temporary container
docker stop ${name}
# delete the temporary container
docker rm ${name}
echo "push"
docker push fairdatasystems/${name}:${timestamp}
echo "pushed"
MDB="fairdatasystems/${name}:${timestamp}"
# run a scan to determine success
echo "trivy"
trivy image --scanners vuln --severity CRITICAL,HIGH -f table  --timeout 1800s fairdatasystems/${name}:${timestamp}  >> ${outputfile}
echo "END\n\n"
echo "END OF MDB\n\n\n\n\n\n" >> ${outputfile}



# markw/cde-box-daemon:0.5.4
#image="markw/cde-box-daemon:0.5.4"
image="markw/cde-box-daemon:0.7.0"
name="cdeb"
echo "CDEB\n\n" >> ${outputfile}
docker run -d --name ${name} ${image}
# use the appropriate distribution upgrade tool for that container’s operating system
echo "update"
docker exec -it ${name} apt-get -y update 
echo "dist-upgrade"
docker exec -it ${name} apt-get -y dist-upgrade 
echo "autoclean"
docker start ${name}
docker exec -it ${name} apt-get -y autoclean
# Commit the patched container, with a new name, overwriting the previous version
echo "commit"
docker commit ${name} fairdatasystems/${name}:${timestamp}
# stop the temporary container
docker stop ${name}
# delete the temporary container
docker rm ${name}
echo "push"
docker push fairdatasystems/${name}:${timestamp}
echo "pushed"
CDEB="fairdatasystems/${name}:${timestamp}"
# run a scan to determine success
echo "trivy"
trivy image --scanners vuln --severity CRITICAL,HIGH -f table  --timeout 1800s fairdatasystems/${name}:${timestamp}  >> ${outputfile}
echo "END\n\n"
echo "END OF CDEB\n\n\n\n\n\n" >> ${outputfile}


# pabloalarconm/care-sm-toolkit:0.0.19
image="pabloalarconm/care-sm-toolkit:0.1.6"
name="care"
echo "CARE\n\n" >> ${outputfile}
docker run -d --name ${name} ${image}
# use the appropriate distribution upgrade tool for that container’s operating system
docker exec -it ${name} apk upgrade --no-cache
# Commit the patched container, with a new name, overwriting the previous version
docker commit ${name} fairdatasystems/${name}:${timestamp}
# stop the temporary container
docker stop ${name}
# delete the temporary container
docker rm ${name}
echo "push"
docker push fairdatasystems/${name}:${timestamp}
echo "pushed"
CARE="fairdatasystems/${name}:${timestamp}"
# run a scan to determine success
echo "trivy"
trivy image --scanners vuln --severity CRITICAL,HIGH -f table  --timeout 1800s fairdatasystems/${name}:${timestamp}  >> ${outputfile}
echo "END\n\n"
echo "END OF CARE\n\n\n\n\n\n" >> ${outputfile}




# markw/yarrrml-rml-ejp:0.1.1
image="markw/yarrrml-rml-ejp:0.1.2"
name="yrml"
echo "YRML\n\n" >> ${outputfile}
docker run -d --name ${name} ${image}  tail -f /dev/null
# use the appropriate distribution upgrade tool for that container’s operating system
docker exec -it ${name} apk upgrade --no-cache
# Commit the patched container, with a new name, overwriting the previous version
docker commit ${name} fairdatasystems/${name}:${timestamp}
# stop the temporary container
docker stop ${name}
# delete the temporary container
docker rm ${name}
echo "push"
docker push fairdatasystems/${name}:${timestamp}
echo "pushed"
YRDF="fairdatasystems/${name}:${timestamp}"
# run a scan to determine success
trivy image --scanners vuln --severity CRITICAL,HIGH -f table  --timeout 1800s fairdatasystems/${name}:${timestamp} >> ${outputfile}
echo "END OF YRML\n\n\n\n\n\n" >> ${outputfile}


# pabloalarconm/beacon-api4care-sm:4.1.0 
image="pabloalarconm/beacon-api4care-sm:4.1.0"
name="beacon"
echo "BEACON\n\n" >> ${outputfile}
docker run -d --name ${name} ${image}
# use the appropriate distribution upgrade tool for that container’s operating system
docker exec -it ${name} apk upgrade --no-cache
# Commit the patched container, with a new name, overwriting the previous version
docker commit ${name} fairdatasystems/${name}:${timestamp}
# stop the temporary container
docker stop ${name}
# delete the temporary container
docker rm ${name}
echo "push"
docker push fairdatasystems/${name}:${timestamp}
echo "pushed"
BEACON="fairdatasystems/${name}:${timestamp}"
# run a scan to determine success
trivy image --scanners vuln --severity CRITICAL,HIGH -f table  --timeout 1800s fairdatasystems/${name}:${timestamp} >> ${outputfile}
echo "END OF BEACON\n\n\n\n\n\n" >> ${outputfile}

cp docker-compose-template-template.yml docker-compose-template-tmp.yml
sed -i'' -e "s!{FDP}!${FDP}!" "docker-compose-template-tmp.yml"
sed -i'' -e "s!{FDPC}!${FDPC}!" "docker-compose-template-tmp.yml"
sed -i'' -e "s!{GDB}!${GDB}!" "docker-compose-template-tmp.yml"
sed -i'' -e "s!{MDB}!${MDB}!" "docker-compose-template-tmp.yml"
sed -i'' -e "s!{YRDF}!${YRDF}!" "docker-compose-template-tmp.yml"
sed -i'' -e "s!{BEACON}!${BEACON}!" "docker-compose-template-tmp.yml"
sed -i'' -e "s!{CDEB}!${CDEB}!" "docker-compose-template-tmp.yml"
sed -i'' -e "s!{CARE}!${CARE}!" "docker-compose-template-tmp.yml"

mv docker-compose-template-tmp.yml ./FAIR-ready-to-go/docker-compose-template.yml

