# FiaB: FAIR-in-a-box

FAIR in a box is an offshoot of the original [CDE-in-a-box](https://github.com/ejp-rd-vp/cde-in-box) created by [Rajaram Kaliyaperumal](https://github.com/rajaram5). It differs primarily in the installation process (now fully automated) and adds the ability to do YARRRML-based transformations from CSV into RDF.

## CONTENTS

- *NEW* [Update Alert Mailing List](https://groups.google.com/g/fair-in-a-box-alerts/)
- [Installation requirements](#requirements)
- [Downloading](#downloading)
- [Installing](#installing)
- [Testing your installation](#testing)
- [Fixing the "can't edit via the web page" problem](#repair_installation)
- [Using your FAIR-in-a-Box](#using)
- [Customizing your FAIR-in-a-Box](#customizing)
- [Connecting your FAIR-in-a-Box to the Virtual Platform](#connecting)

<a name="requirements"></a>

## Requirements

In order to use the FAIR-in-a-box solution you `have to` meet following requirements.

**User requirements (Person who is deploying this solution)**

- Basic knowledge about Docker​
- Basic GitHub knowledge​
- (optional) Awareness of the EJP RD's CDE semantic model if you plan to create FAIR data

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

<a name="installing"></a>

## Installing

Once you have done above downloads and configurations you can run "run-me-to-install.sh" in the ./FAIR-in-a-box/ folder

```sh
./run-me-to-install.sh
```

### How to answer the questions

You will then get prompted as to whether you are doing a production installation (i.e. you haves a GUID already created - for example, using [W3ID](https://github.com/perma-id/w3id)) and you have already selected ports for your FDP, GraphDB, and Beacon (optional)). In addition, you must have an available port for the "RDFization trigger" - this port must be available on the server, but SHOULD NOT be exposed through the firewall.

If you say "no", the installer will install your FDP onto localhost using defaults:


   - installation prefix 'test'
   - port 7070 for the FDP
   - port 7200 for the GraphDB
   - port 4567 for the RDFization trigger
   - port 8000 for Beacon2

If you say "yes", you will need to answer these questions yourself.   

The installation prefix is simply a short-name for your database.  NO SPACES, and better as lower-case letters.  For example:
   - crampdb
   - euronmd
   - dpp
   - htad
   - crag
   - ACME  <---- this will be used for the rest of the tutorial

This prefix is used to isolate one installation of FDP from another, if you are hosting multiple FDPs on the same server.

After about a minute, the installer will send a message to the screen asking you to check that the installation was successful. This message will last for 10 minutes, giving you enough time to explore the links in the message. After 10 minutes, the services will all automatically shut down. You can stop the installer by `CTRL-C` any time.

If installation is successful using "test", you may then restart the `run-me-to-install`, this time answering the questions using your production information.

### Find the folder with your final server config... Ready-To-Go!

The installer will create a folder containing all of your server configuration files.  You can copy this folder anywhere on your system, e.g. to keep your servers all in one folder outside of your GitHub copy of FiaB.

The folder will be called "prefix-ready-to-go"  (e.g. "ACME-ready-to-go").  Inside of that folder is a customized docker-compose file (docker-compose-prefix.yml) for your deployment.  So for example, you would issue the commands:

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

<a name="repair_installation"></a>

## Repair the "unable to edit" problem

For unknown reasons, the `run-me-to-install.sh` script SOMETIMES results in an FDP that has a duplicate created and modified date.  This is invalid, according to the validation SHACL, and renders the FDP uneditable (even if you remove that data via the Web interface!).  

The easiest way to fix it is to modify the SHACL (temporarily) to allow you to create/edit the record.  This process is described in [this slide deck](https://docs.google.com/presentation/d/1lR96U7nShJqx2wIytWKrNbmWLzr5EBEUE6OpuycZYqg/edit).  This works for me... your milage may vary!



---
<a name="testing"></a>

## Testing your installation

- If the **GraphDB** deployment is successful then you can access GraphDB by visiting the following URL.

**Note:** If you deploy the `FAIR in a box` solution in your laptop then check only for **local deployment** url.

| Service name | Local deployment                                | Production deployment |
| ------------ | ----------------------------------------------- | --------------------- |
| GraphDB      | [http://localhost:7200](http://localhost:7200/) | http://SERVER-IP:7200 |

By default GraphDB service is secured so you need credentials to login to the graphDB. Please find the default graphDB's credentials in the table below.

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

- The /data folder will contain your CSV, with each CSV file representing one category of data that should be transformed (e.g. CDE or DCDE)
- The /config folder will contain [YARRRML Templates](https://github.com/ejp-rd-vp/CDE-semantic-model-implementations/tree/master/YARRRML_Transform_Templates), one for each of the CSVs. You may add new YARRRML templates into this folder, and the associated CSV into the /data folder, so long as they follow the naming conventions that allow them to be automatically matched.
- The /config folder WILL BE AUTOMATICALLY POPULATED with EJP version 1 or 2 models when you initiate a transformation (Version 1 models use the docker image cde-box-daemon:0.3.0; the Version 2 models use cde-box-daemon:0.6.0).  Any identically-named template files will be over-written, but your own custom-designed templates will be left alone.
- *NOTA BENE*:  Please execute `chmod a+w ./data/triples` prior to executing a transformation.  The transformation tool in this container runs with very limited permissions, and cannot write to a folder that is mounted with default permissions.


#### Preparing input data

The transformation services take `CSV` as input files. We provide `CSVs` with example data and `YARRRML` templates for each of the European Rare Disease CDEs.
The `YARRRML` templates are always loaded from GitHub automatically, so they stay up-to-date as we change the models in EJP-RD, but the `CSV` files must be added by the user.

#### Configuring configuration and data folders

**Step 1:** Folder structure

Make sure the following folder structure, relative to where you plan to keep your pre and post-transformed data, is available:

```
        ./ACME-ready-to-go/data/
        ./ACME-ready-to-go/data/mydataX.csv  (input csv files, e.g. "CDE.csv")
        ./ACME-ready-to-go/data/mydataY.csv...
        ./ACME-ready-to-go/data/triples   (this is where the output data will be written, and loaded from here into Graphdb)
        ./ACME-ready-to-go/config/   (this is the folder where yarrrml templates will be automatically loaded from the EJP repository)
```

**Step 2:** Edit the .env file

the .env file will create the values for the environment variables in the docker compose file. The first of these `baseURI` is the base for all URLs that represent your transformed data. This should be set to something like:

`http://my.database.org/my_rd_data/`

this will result in Triple that look like this:

`<http://my.database.org/my_rd_data/person_123345_asdssaewe#ID> <sio:has-value> <"123345">`

optimally, these URLs will resolve...


**Step 3:** Input CSV files

_VERSION 1 CDEs_

Put an appropriately columned `XXXX.csv` into the `ACME-ready-to-go/data`. Please look into [this](https://github.com/ejp-rd-vp/CDE-semantic-model-implementations/tree/master/CDE_version_2.0.0/CSV_template_doc) github repository for examples of CDEs `CSV` files.

_VERSION 2 CDEs_

Please wait for further instructions for how to use Version 2 of the CDE models.


**Step 4:** Input YARRRML templates

The `YARRRML` templates are always loaded from GitHub automatically on step 5, so they stay up-to-date as we change the models in EJP-RD.

Make sure the `YARRRML` templates files are matching your `CSV` files names `XXXX_yarrrml_template.yaml` and are in the `ACME-ready-to-go/config` folder. Please look into [this](https://github.com/ejp-rd-vp/CDE-semantic-model-implementations/tree/master/CDE_version_2.0.0/YARRRML) github repository for CDEs `YARRRML` templates.

**Step 5:** Executing transformations

Call the url: http://localhost:4567 or http://SERVER-IP:4567 to trigger the transformation of each CSV file, and auto-load into graphDB (this will over-write what is currrently loaded! We will make this behaviour more flexible later)
**Note:** If you deploy `FAIR in a box` solution in your laptop then check only for **localhost** url.

**There is sample data (CDE.csv for Version 2 models, something else for Version 1 models) in the "ACME-ready-to-go/data" folder that can be used to test your installation.  Models will be automatically installed when you start the transformation**

### How to modify semantic model in data transformation service

YARRRML is one the core technology which has been used in our data transformation service. If you like to extend the exemplar CDE semantic models or add other semantic model to describe your data then, you have to provide custom YARRRML templates to the data transformation service. To learn more about building custom YARRRML templates please try [matey webapp](https://rml.io/yarrrml/matey/).

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
To store the `rdf` documents generated by the `FAIR in a box` solution we need to have a triplestore which stores these document. In the `FAIR in a box` solution we use graphDB as a triplestore. To know more about the graphDB triplestore please visit this [link](https://graphdb.ontotext.com)

**FAIR Data Point:**
To describe the content of your resource we need a `metadata provider` component. For the `FAIR in a box` solution we use `FAIR Data Point` software that provides description (metadata) of you resource. To learn more about the FAIR Data Point please visit this [link](https://fairdatapoint.readthedocs.io/en/latest/)

<a name="Alternatives"></a>

# Alternatives

## Related solutions

In this section we list other related solutions.

**MOLGENIS CDE in a box**  
MOLGENIS EDC provider also provides a complete set of `CDE in a box` with EDC system. To learn more about MOLGENIS implementation of the `CDE in a box` solution please visit this [link](https://github.com/fdlk/cde-in-box/tree/feat/molgenis)

<a name="customizing"></a>

# Customization of your installation

## Update username and password for the FDP

- Go to http://localhost:7200 and login with the default username and password ("admin"/"root").
- Enter the "settings" for the admin account, and update the password. Note that this account will have access to both the metadata and the data (!!) so make the password strong!
- at the terminal, shut down the system (docker-compose down)
- go to the ./metadata/fdp folder and edit the file "application.yml"
- in the repository settings, update the username and password to whatever you selected above
- now you need to edit the configuration file in the FDP docker image. To do this, shut-down your FAIR-ready-to-go (`docker-compose down`) then edit the `./metadata/fdp/application.yml` file to update the graphdb authentication username/password.

- now go back to the FAIR-ready-to-go folder and bring the system back up. Your FDP database is now protected with the new password.

## Create a "safe" user for the CDE database

- Go to http://localhost:7200 and login with the current username and password
- Enter the "settings" and "users".
- Create a new user and password, giving them read/write permission ONLY on the CDE database, and read-only permission on the FDP database.
- in the FAIR-ready-to-go folder, update the `.env` file with this new limited-permissions user
- docker-compose down and up to restart the server

## Update the colors and logo

- go to the `ACME-ready-to-go/fdp` folder
- add your preferred logo file into the ./assets subfolder
- edit the ./variables.scss to point to that new logo file, and select its display size (or keep the default)
- to change the default colors, edit the first two lines to select the primary and secondary colors (the horizontal bar on the default http://localhost:7070 homepage shows the primary color on the left and the secondary color on the right)
- if you have a preferred favicon, replace the one in that folder with your preferred one.
- now go back to the ACME-ready-to-go folder and bring the docker-compose back up. Your FDP client will now be customized with your preferred icons and colors


<a name="connecting"></a>

## Connect to the Virtual Platform

Full instructions for modifying your default FAIR-in-a-box to match the schema requirements for the Virtual Platform can be found here:  https://github.com/ejp-rd-vp/FDP-Configuration

To connect to the VP Index, you need to add the indexer "ping" function to your FAIR Data Point.  To do this:

- Login to your FDP via the Web page
- Go to "settings"
- About half-way down the settings there is a "Ping" section.  Add the following URL to the "Ping":
    - https://index.vp.ejprarediseases.org/

Once you have done this, your site will become registered in the VP Index on the next "ping" cycle (should be weekly, by default).

If you want to force the registration, you can shut-down (docker-compose down) and restart your FDP.  Alternatively, you can force a re-indexing by making the following `curl` command:

```
curl -X POST https://index.vp.ejprarediseases.org/ -H "Content-Type: application/json" -d
{"clientUrl": "https://my.fdp.address.here/}
```

*IF YOU HAVE SWITCHED-ON AND CONFIGURED Beacon2*, then in the Dataset descriptor, you need to add the "VPContentDiscovery" flag to the *vp Connection* property - go to your dataset record in the FDP web page, and add:

http://purl.org/ejp-rd/vocabulary/VPContentDiscovery
As an additional value of vpConnection



