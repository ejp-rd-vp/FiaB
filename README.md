# FiaB: FAIR-in-a-box

FAIR in a box is an offshoot of the original [CDE-in-a-box](https://github.com/ejp-rd-vp/cde-in-box) created by [Rajaram Kaliyaperumal](https://github.com/rajaram5). It differs primarily in the installation process (now fully automated) and adds the ability to do YARRRML-based transformations from CSV into RDF.

## CONTENTS

- *NEW* [Update Alert Mailing List](https://groups.google.com/g/fair-in-a-box-alerts/)
- [Installation requirements](#requirements)
- [Downloading](#downloading)
- [Installing](#installing)
- [Testing your installation](#testing)
- [Using your FAIR-in-a-Box](#using)
- [Customizing your FAIR-in-a-Box](#customizing)
- [Connecting your FAIR-in-a-Box to the Virtual Platform](#connecting)
- [Implementing Beacon2 and other services](#services)

<a name="requirements"></a>

## Requirements

To use the FAIR-in-a-box solution you `must` meet the following requirements.

**User requirements (Person who is deploying this solution)**

- Basic knowledge about Docker​
- Basic GitHub knowledge​
- (optional) Awareness of the EJP RD's CDE/CARE-SM semantic model if you plan to create FAIR data

**System requirements​ (Machine where this solution is being deployed)**

- Docker engine ​
- Docker-compose application​

---

<a name="downloading"></a>

## Downloading

#### FAIR-in-a-box

To get the FAIR in a box code clone this repository to your machine.

```sh
git clone https://github.com/ejp-rd-vp/FiaB
```

---



## Installing


<a name="installing"></a>

## Installing from scratch

If you have never installed FiaB before, you `must` use the CARE-SM models - OLD CDE MODELS **are deprecated**!!!

Once you have completed the "Downloading" section of this tutorial, you can run `run-me-to-install.sh` in the `./CARE-SM-Fiab/` folder

```
bash ./run-me-to-install.sh
```

This script will bootstrap your FAIR Data Point and its associated GraphDB.  It writes two databases into GraphDB.  One database holds your metadata, the other will hold your FAIRified data (assuming you execute an automated transformation).  Only the metadata database is required.  The data database is optional.

### How to answer the installation questions

You will be prompted for details about your installation (i.e. you have a GUID already created - for example, using [W3ID](https://github.com/perma-id/w3id)) and you have already selected ports for your FDP, GraphDB, and Beacon (optional)). In addition, you must have an available port for the "RDFization trigger" - this port must be available on the server, but SHOULD NOT be exposed through the firewall.   *If you are only trying-out the FiaB, you should use a http://localhost:port (e.g. http://localhost:10000) URL as the answer to the first question - this will configure everything to run locally while you explore the functionality.  You will need to re-run the installer using your production URL to reconfigure everything from-scratch.  NOTE:  Local installations are http, NOT https!  Note:  the port number you put in the URL has to be the same as the port number you select in question 3 "what port is your FDP running on".

The installation prefix is simply a short-name for your database.  NO SPACES, and better as lower-case letters.  For example:
   - crampdb
   - euronmd
   - dpp
   - htad
   - crag
   - ACME  <---- this will be used for the rest of the tutorial

This prefix is used to isolate one installation of FDP from another, if you are hosting multiple FDPs on the same server.

You will then select ports for the other components when prompted.  Any port is fine - for easy organization, you might select ports 10000, 10001, 10002, 10003 for the FDP, GraphDB, Beacon, and "trigger" ports.

After about a minute, the installer will send a message to the screen asking you to check that the installation was successful. This message will last for 10 minutes, giving you enough time to explore the links in the message. After 10 minutes, the services will all automatically shut down. You can stop the installer by `CTRL-C` at any time.  **PRES IT ONLY ONCE!!!!**  to allow the installer to shut down cleanly and delete extraneous images.


### Find the folder with your final server config... Ready-To-Go!

The installer will create a sub-folder underneath the folder with `run-me-to-install` containing all of your server configuration files.  You can copy this folder anywhere on your system, e.g. to keep your servers all in one folder outside of your GitHub copy of FiaB.

The folder will be called "prefix-ready-to-go"  (e.g. "ACME-ready-to-go").  Inside that folder is a customized docker-compose file (docker-compose-ACME.yml) for your deployment.  So for example, you would issue the commands:

```

cp -r ACME-ready-to-go ~/SERVERS/
cd ~/SERVERS/ACME-ready-to-go
docker-compose -f docker-compose-ACME.yml up

```

Your FDP is now running at whatever port you selected for the FDP (default 7070)

### Production Installation (using your domain or purl)

When you are happy with your (production) installation, and you have created the metadata records (following the instructions below for creating a read/write user for the FDP and closing the default root account "albert.einstein@example.com"), you are then ready to register yourself with the central index of FAIR Data Points.  

To do this, you need to edit one file"

```
~/SERVERS/ACME-ready-to-go/fdp/application.yml

```

The line you need to edit is:

```
    clientUrl: http://localhost:7070

```

Replace the `http://localhost:7070` URL with your own production URL (note that you should NOT include a trailing slash!).  The next time you docker-compose up, the system will register itself using the URL that you put as the value of clientUrl


#### With SSL Certificate and HTTPS Proxy

NOTE:  If you already have a reverse proxy on your server, then you should ignore this and use your own.  This is ONLY for those who have not set-up a proxy.

NOTE:  You can ONLY do this with a production installation!  Your FDP URL must match your certificate!

1.  Uncomment the "hitch" service in the docker-compose file.  **NOTE: Hitch and Varnish are often used together... I found that Varnish has a frustrating habit of caching things you don't want to be cached... I no longer recommend that you use Varnish for this application.   MDW**
2.  If you need to (Hint: YOU PROBABLY DON'T!), you can edit the "frontend" line in the `ACME-ready-to-go/proxy.conf` file. If you leave it as-is, your FDP will run on https port 8443, which will generally be OK for all installations.
3.  Edit the `ACME-ready-to-go/docker-compose-ACME.yml` "hitch" service configuration so that `./combined.pem:/etc/hitch/cert.pem` is mapping YOUR certificate+key .pem file to the /etc/hitch/cert.pem inside the docker image (do not edit this filename!!)
4.  You SHOULD now remove the exposed non-SSL port from the fdp_client service in the docker-compose file, as it is no longer needed
5. *NOTE* There are situations where Hitch will cache an old copy of your certificate, casuing "expired certificate" errors in people's browsers.  To fix this, docker-compose down and docker-compose up again.  (This is incredibly frustrating... sorry!  Not my fault! MDW)

Additional customization options are described below.



---
<a name="testing"></a>

## Testing your installation

- If the **GraphDB** deployment is successful then you can access GraphDB by visiting the following URL.

**Note:** If you deploy the `FAIR in a box` solution in your laptop then check only for **local deployment** url.

| Service name | Local deployment                                | Production deployment |
| ------------ | ----------------------------------------------- | --------------------- |
| GraphDB      | [http://localhost:7200](http://localhost:7200/) | http://SERVER-IP:7200 |

By default the GraphDB service is secured so you need credentials to login to the graphDB. Please find the default graphDB's credentials in the table below.

| Username | Password |
| -------- | -------- |
| `admin`  | `root`   |

- If the **FAIR Data Point** deployment is successful then you can access the FAIR Data Point by visiting the following URL.

| Service name    | Local deployment                               | Production deployment |
| --------------- | ---------------------------------------------- | --------------------- |
| FAIR Data Point | [http://localhost:7070](http://localhost:7070) | http://SERVER-IP:7070 |

**Note:** If you deploy the `FAIR in a box` solution in your laptop then check only for **local deployment** url.

In order to add content to the FAIR Data Point you need credentials with write access. Please find the default FAIR Data Point's credentials in the table below.

| Username                      | Password   |
| ----------------------------- | ---------- |
| `albert.einstein@example.com` | `password` |

---

<a name="using"></a>

# Using FAIR-in-a-box for data transformation

NOTE: The folders "metadata" and "bootstrap" are no longer needed. ALL ACTIVITIES FROM NOW ON HAPPEN INSIDE OF THE ACME-ready-to-go FOLDER, and this folder can be moved anywhere on your system.

In the folder ./ACME-ready-to-go there is a docker-compose-ACME.yml file, and two directories.

the folder structure is:

```
.--
  | docker-compose-ACME.yml
  | /data
  ---
    | /triples
  | /config

```

- The /data folder is where you will place your preCARE.csv file, according to the instructions provided above [instructions on how to generate the (single!) 'preCARE.csv' file](https://github.com/ejp-rd-vp/CARE-SM-Implementation/tree/main/CSV).
- The /data folder will contain the [YARRRML Template](https://github.com/ejp-rd-vp/FiaB/blob/main/CARE-SM-Fiab/FAIR-ready-to-go/data/CARE_yarrrml_template.yaml) that will be applied to the final CSV.
- *NOTA BENE*:  Please execute `chmod a+w ./data/triples` prior to executing a transformation.  The transformation tool in this container runs with very limited permissions, and cannot write to a folder that is mounted with default permissions.
- *NOTA BENE*:  the CARE_yarrrml_template.yaml contains a placeholder for your installation's base URI.  This is passed as an environment variable `baseURI`, which appears in the cde-box-daemon clause of your docker-compose-ACME.yml file:

```
  cde-box-daemon: 
    image: markw/cde-box-daemon:0.5.2    # to use the version 2 CDE models with Hefesto
    container_name: cde-box-daemon
    environment:
      GraphDB_User: ${GraphDB_User}
      GraphDB_Pass: ${GraphDB_Pass}
 -->  baseURI: ${baseURI}
      GRAPHDB_REPONAME: ${GRAPHDB_REPONAME}
```

If you set baseURI to be "http://my.domain.org/"   then all 'local' URLs in your resulting transformed data will use that as their prefix.

#### Preparing input data

The EJP-RD CARE-SM Transformation process has three steps:

1) A simple "preCARE" CSV file is created by the data owner (`you must do this!`)
2) The preCARE.csv is transformed into the final CARE.csv (`this is automated`) by the caresm toolkit (part of the docker-compose)
3) The final CARE.csv is processed by the YARRRML transformer, and RDF is output into the `./data/triples` folder
  

An exemplar [preCARE CSV](https://github.com/ejp-rd-vp/CARE-SM-Implementation/blob/main/CSV/exemplar_data/preCARE.csv), and the [standard YARRRML template](https://github.com/ejp-rd-vp/FiaB/blob/main/CARE-SM-Fiab/FAIR-ready-to-go/data/CARE_yarrrml_template.yaml), are provided for you to test your installation.  Copy/paste these into the appropriate folder (`./data`)

You are responsible for generating your own `preCARE.csv`.  *NOTA BENE* the filenames MUST NOT BE CHANGED!  The files are called `preCARE.csv`, and `CARE_yarrrml_template.yaml`!!  YOU CANNOT CHANGE THIS!

#### Configuring configuration and data folders

**Step 1:** Folder structure

Make sure the following folder structure, relative to where you plan to keep your pre and post-transformed data, is available:

```
        ./ACME-ready-to-go/data/
        ./ACME-ready-to-go/data/preCARE.csv
        ./ACME-ready-to-go/data/triples   (this is where the output data will be written, and loaded from here into Graphdb)
        ./ACME-ready-to-go/data/CARE_yarrrml_template.yaml
```

**Step 2:** Edit the .env file

the .env file will create the values for the environment variables in the docker-compose file. The first of these `baseURI` is the base for all URLs that represent your transformed data. This should be set to something like:

`http://my.database.org/my_rd_data/`

this will result in a Triple that looks like this:

`<http://my.database.org/my_rd_data/person_123345_asdssaewe#ID> <sio:has-value> <"123345">`

optimally, these URLs will resolve... but this is your responsibility - we cannot automate this.


**Step 3:** Input CSV files

Put an appropriately generated `preCARE.csv` into the `ACME-ready-to-go/data`. 

If you are unsure which columns to fill for each data type, see the [glossary](https://github.com/ejp-rd-vp/CARE-SM-Implementation/tree/main/CSV)


**Step 4:** Input YARRRML templates

The `YARRRML` template is standardized


**Step 5:** Executing transformations

Call the url: http://localhost:4567 or http://SERVER-IP:4567 (or whatever 'trigger' port number you selected when you answered the installation questions) to trigger the transformation of each CSV file, and auto-load into graphDB (*NOTA BENE* this will over-write what is currrently loaded!  i.e. the EJP pipeline can only be used to take snapshots, NOT incremental updates!)
**Note:** If you deploy `FAIR in a box` solution in your laptop then check only for **localhost** url.


<a name="Understanding"></a>

# Understanding your FAIR in a box installation

## Software used in FAIR in a box

The image below gives an overview of software used in the `FAIR in a box` solutions.

<p align="center"> 
    <a href="docs/images/components_overview.jpg" target="_blank">
        <img src="docs/images/components_overview.jpg"> 
    </a>
</p>

**Triple store:**
To store the `rdf` documents generated by the `FAIR in a box` solution we need to have a triplestore that stores these documents. In the `FAIR in a box` solution we use graphDB as a triplestore. To know more about the graphDB triplestore please visit this [link](https://graphdb.ontotext.com)

**FAIR Data Point:**
To describe the content of your resource we need a `metadata provider` component. For the `FAIR in a box` solution we use `FAIR Data Point` software that provides a description (metadata) of your resource. To learn more about the FAIR Data Point please visit this [link](https://fairdatapoint.readthedocs.io/en/latest/)

<a name="Alternatives"></a>

# Alternatives

## Related solutions

In this section, we list other related solutions.

**MOLGENIS CDE in a box**  
MOLGENIS EDC provider also provides a complete set of `CDE in a box` with EDC system. To learn more about MOLGENIS implementation of the `CDE in a box` solution please visit this [link](https://github.com/fdlk/cde-in-box/tree/feat/molgenis)

<a name="customizing"></a>

# Customization of your installation

## Update username and password for the GraphDB

- Go to http://localhost:7200 (or wherever you set the GraphDB port) and login with the default username and password ("admin"/"root").
- Enter the "settings" for the admin account, and update the password. Note that this account will have access to both the metadata and the data (!!) so make the password strong!
- at the terminal, shut down the system (docker-compose down)
- go to the ./ACME-ready-to-go/fdp folder and edit the file "application-ACME.yml"
- in the repository settings, update the username and password to whatever you selected above

- now go back to the FAIR-ready-to-go folder and bring the system back up. Your FDP database is now protected with the new password.

## Create a "safe" user for the CDE database

- Go to http://localhost:7200 and login with the current username and password
- Enter the "settings" and "users".
- Create a new user and password, giving them read/write permission ONLY on the FDP database, and read-only permission on the CDE database.
- in the FAIR-ready-to-go folder, update the `.env` file with this new limited-permissions user
- docker-compose down and up to restart the server
- Consider closing the GraphDB external port in the docker-compose, or limiting it to localhost... there's no need for GraphDB to be exposed!

## Update the colors and logo

- go to the `ACME-ready-to-go/fdp` folder
- add your preferred logo file into the ./assets subfolder
- edit the ./variables.scss to point to that new logo file, and select its display size (or keep the default)
- to change the default colors, edit the first two lines to select the primary and secondary colors (the horizontal bar on the default http://localhost:7070 homepage shows the primary color on the left and the secondary color on the right)
- if you have a preferred favicon, replace the one in that folder with your preferred one.
- now go back to the ACME-ready-to-go folder and bring the docker-compose back up. Your FDP client will now be customized with your preferred icons and colors


<a name="connecting"></a>

## Connect to the Virtual Platform

__Full instructions for modifying your default FAIR-in-a-box to match the schema requirements for the Virtual Platform can be found here:  https://github.com/ejp-rd-vp/FDP-Configuration__

To connect to the VP Index, you need to add the indexer "ping" function to your FAIR Data Point.  To do this:

- Login to your FDP via the Web page
- Go to "settings"
- About halfway down the settings there is a "Ping" section.  Add the following URL to the "Ping":
    - https://index.vp.ejprarediseases.org/

Once you have done this, your site will be indexed in the VP Index on the next "ping" cycle (should be weekly, by default).  THE INDEX WILL LOOK FOR THE "VPDiscoverable" tag in the vpConnection property of whatever resource(s) you want to be indexed by the platform.  e.g. if you have 5 datasets, but you only want 3 of them to be indexed by the VP, then you set the vpConnection property to "VPDiscoverable" for ONLY those three datasets (the others have no value for that property). In the metadata editor of the FDP web page, this is done via a dropdown menu.

If you want to force re-indexing, you can shut-down (docker-compose down) and restart your FDP.  Alternatively, you can force a re-indexing by making the following `curl` command:

```
curl -X POST https://index.vp.ejprarediseases.org/ -H "Content-Type: application/json" -d
{"clientUrl": "https://my.fdp.address.here/}
```



<a name="services"></a>

## Implementing Beacon2 and other services


The process for advertising content-discovery services (i.e. "Level 2", "Level 3", etc.) has changed since Release 1.0 of the VP.  In release 1.5, all access services are individually annotated for their functionality - the "VPContentDiscovery" flag has been deprecated.  _Note that the "VPDiscoverable" flag is still used, and should be set on any component of your FDP that you want the VP to pay attention to._

The mechanism for publishing a data service is to create a dcat:DataService in your FAIR Data Point, and then annotate it according to its function.

There are two "kinds" of DataService.  

   1. "standalone" - the service does not serve a specific dataset in your FDP.  A plotting library or a statistical calculation service would be examples of this.
   2. "dataset-dependent" - the service serves a dataset

In the FIAB installation, there are separate DataService classes for each of these cases.  "standalone" is a child of dcat:Catalog. "dependent" is a child of dcat:distribution.

They are annotated as follows:

  1. "standalone" must have, at least, a dcat:landingPage.  This is the URL to the website that describes the service.  It may also have a dcat:endpointURL and dcat:endpointDescription, if it is an API.
  2. "dataset-dependent" must haves, at least, a dcat:endpointURL and dcat:endpointDescription, and may have a dcat:landingPage
  3. In all cases, there SHOULD be a dct:type property, with a value of one or more ontology terms that describe the functionality of that DataService.  We recommend "rooting" these ontology terms into EDAM:opereation.

### ONLY IF YOU HAVE SWITCHED-ON AND CONFIGURED Beacon2

In the case of Beacon2 services, we have added two new ontology terms to the EJP VP ontology:

`https://w3id.org/ejp-rd/vocabulary#VPBeacon2_individuals`

This will be used to annotate a dcatDataService that implements the Beacon2 "individuals" endpoint.

`https://w3id.org/ejp-rd/vocabulary#VPBeacon2_catalog`

This will be used to annotate a dcatDataService that implements the Beacon2 "catalog" endpoint, and become the value(s) of dct:type for those DataServices




