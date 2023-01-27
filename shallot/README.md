# Default Shallot server for the FDP

This is optional, and can be run in-parallel with the FAIR in a box.  It will connect to the F-i-a-b GraphDB network, and attempt to query the 
CDE database using the username/password indicated in `config.ini`

http://localhost:8088/api-local/

You should see a Swagger interface for your queries.

<br/>

# Configuration

It is **strongly recommended** that you login to GraphDB and create a readonly user for the `cde` database with a strong password.

Edit the `config.ini` file in this folder with the username and password for that readonly user.

Done!  (see "customization" below for more configuration you can do)

# How to initialize the shared-queries folder

Note that shared-queries is a Git submodule of https://github.com/World-Duchenne-Organization/grlc-queries.  This contains the default queries that will be used by the EJP Virtual Platform.

To initialize it and fill it with the queries, you need to
```
      $ cd shared-queries
      $ git submodule init
      $ git submodule update
```

Subsequently, you can update the queries at any time using 

```
      $ cd shared-queries
      $ git pull origin main
```

## Customizing the Shallot server

In the `shared-queries` folder that was created during the initialization (above) there is a file called `local-api-config.ini`.  You should edit that to provide metadata about the dataset being served by this grlc instance.


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

This will allow your Shallot server to talk to graphdb over the docker internal network.

Now you're ready to go!

```
   $ docker-compose up -d
```

If you now surf to http://localhost:8088/api-local/ you will see your Shallot server (you can also go to http://yourservername.org:8088/api-local/)

### Origins

Shallot is fork of the grlc project, that has been extensively edited to be
safe to run in protected environments.  It can only execute queries that
have been placed in the queries folder mounted into the docker image.
