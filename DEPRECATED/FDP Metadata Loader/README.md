# Instructions

The FDP Metadata Loader will consume a filled-out MS Excel template, and create a FDP Catalog, Dataset, and Distribution from that.

* The template is in this folder (./template.xls)

* A working example is provided (./example.xls)

* In the template, the entries highlighted in BOLD are the required entries.  All other entries are allowed to be blank.

* Once you have filled out the template and named it (whatever you call it needs to be entered into the `EXCEL` environment variable in the docker-compose file) you simply `docker-compose up` and wait until it is done.

* THIS SOFTWARE ONLY SUPPORTS XLS, IT DOES NOT SUPPORT XLSX!!


This is intended to be used with the docker-compose FAIR Data Point in "FAIR-ready-to-go".  If you use another docker-compose, you will need to adjust the network name in this docker-compose, along with the server URLs/ports in the Environment variables.  This is your problem :-)

# Docker Compose explanation

```
version: "2.0"
services:
  
  filler: 
    image: markw/fdp_metadata_filler:latest
    container_name: fdp_filler
    environment:
      EXCEL: "./myrecord.xls"
      SERVER: "http://fdp:80"
      BASE_URI: "http://localhost:7070"
      FDPUSER: "albert.einstein@example.com"
      FDPPASS: "password"
    networks:
      - fairreadytogo_fdp

networks:
  fairreadytogo_fdp:
    external: true

```

* `EXCEL` is the name of the excel file, relative to where you started the docker-compose up.
* If you need to find your fdp network name, do a `docker network ls` and figure it out
* the `SERVER` environment variable is from the perspective of this docker image, and the hostname is the name of the network (in the other docker-compose) that the FAIR Data Point CLIENT is attached to, and the port is the INTERNAL port of that client (it will be 80 unless you have re-written the client software!)
* `BASE_URI` is the persistentURL that you set in the  FAIR-in-a-box/metadata/fdp/application.yml file.
* `FDPUSER` and `FDPPASS` are the admin username and password for the FDP Client (the ones provided are the defaults)
* `networks` points out to the external network created by the FAIR-ready-to-go docker-compose (`fairreadytogo_fdp` is the default, and will work out-of-the-box if you are using FAIR-ready-to-go)

# CAVEAT EMPTOR

This software has zero error-tolerance, and is completely undocumented at the moment.  If you want to debug your load, watch the logs from both the FDP docker image, as well as this one.  They will be helpful in identifying which fields in your Excel are troublesome.
