# Default grlc server for the FDP

This is optional, and can be run in-parallel with the FAIR in a box.  It will connect to the F-i-a-b GraphDB network, and attempt to query the 
CDE database using the username/password indicated in `config.ini`

http://localhost:8088/api-local/

You should see a Swagger interface for your queries.

## NOTA BENE

Unlike legacy Grlc, this version cannot use `api-git` and will ONLY RUN as `api-local`, and should only be used after initializing and manually checking the queries in the `grlc-queries` folder (see below) to ensure they are acceptable to run on your own FAIR data.

Unlike legacy Grlc, it is impossible to provide a GitHub token in the configuration file!  The only allowed repository is that provided by the World Duchenne Organization.

<br/>

# Configuration

It is **strongly recommended** that you login to GraphDB and create a readonly user for the `cde` database with a strong password.

Edit the `config.ini` file in this folder with the username and password for that readonly user.

Done!  (see "customization" below for more configuration you can do)

# How to initialize the grlc-queries folder

Note that grlc-queries is a Git submodule of https://github.com/World-Duchenne-Organization/grlc-queries.  This contains the default queries that will be used by the EJP Virtual Platform.

To initialize it and fill it with the queries, you need to
```
      $ cd grlc-queries
      $ git submodule init
      $ git submodule update
```

Subsequently, you can update the queries at any time using 

```
      $ cd grlc-queries
      $ git pull origin main
```

## Customizing the grlc server

In the `grlc-queries` folder that was created during the initialization (above) there is a file called `local-api-config.ini`.  You should edit that to provide metadata about the dataset being served by this grlc instance.


## Starting the server

Assuming you are running the default FAIR-in-a-box, it will expose a network called `xxx_graphdb`.  To discover what it is called on your instance issue the command:

```
   $ docker network ls | grep graphdb
```

Whatever it's name is (e.g. `abc_graphdb`), edit the docker-compose file in this folder and change the network name to `abc_graphdb`:

```
networks:
  default:
    name: abc_graphdb
    external: true
```

This will allow your grlc server to talk to graphdb over the docker internal network.

Now you're ready to go!

```
   $ docker-compose up -d
```

If you now surf to http://localhost:8088/api-local/ you will see your grlc server (you can also go to http://yourservername.org:8088/api-local/)

