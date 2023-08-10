## CDE Version 2 Models FiaB Quick Start!

We will use "Diagnosis" as an example of how to create the preCDE.csv file required by the transformation pipeline.

First, look at the overall structure of the [preCDE.csv](https://github.com/ejp-rd-vp/CDE-semantic-model-implementations/blob/master/CDE_version_2.0.0/CSV_docs/exemplar_data/preCDE.csv).  The 18 required columns are:


* model - the name of the data type
* pid - the unique identifier of the patient
* context_id - a method for grouping observations together (explained elsewhere... one day!)
* value - the value of the datatype observation
* value_datatype - the datatype, as an xsd datatype (e.g. xsd:integer or xsd:date)
* valueIRI - if the value is an ontology term or other controlled term, use the URL here
* age - the age of the patient at time of observation
* process_type - if the process of measuring the observation has an ontological type, put it here
* unit_type - the unit of measure (as an ontology term)
* input_type - for processes that have inputs (e.g. a questionnaire) put the ontological type of input here
* target_type - for processes that have a target (e.g. a resection targets a tissue) put the tissue ontological type here
* frequency_type - TBD
* frequency_value - TBD
* agent_id - the unique identifier of the agent that is executing the process (e.g. a surgeon)
* route_type - TBD
* startdate - the start date of the observation process
* enddate - the end date of the observation process
* comments - free-text comments

Each data type requires a subset of these columns to be filled, and the rest are 'null'.

ALL COLUMNS MUST EXIST IN THE `preCDE.csv` FILE!  Just leave a column blank if there is no value.

The required columns are data-type dependent.  Using our Diagnosis example, we can check the [glossary](https://github.com/ejp-rd-vp/CDE-semantic-model-implementations/tree/master/CDE_version_2.0.0/CSV_docs/glossary.md) to see what fields are required for Diagnosis:

---
## Diagnosis:

- **pid**: Patient unique identifier
- **context_id**: *(OPTIONAL)* Contextual identifier in case you want to relate several data elements under a common context (ex: certain diagnosis/phenotype relationship or some elements under same visit occurrence)
- **valueIRI**: IRI that defines clinical condition as disease or disorder: Orphanet disease ontology (ORDO) represented with a full URL such as http://www.orpha.net/ORDO/Orphanet_199630
- **model**: Diagnosis
- **startdate**: *(OPTIONAL)* ISO 8601 formatted start date of observation
- **enddate**: *(OPTIONAL)* ISO 8601 formatted enddate of observation in case it is different from `startdate`. 
- **age**: *(OPTIONAL)* Patient age when this observation was taken, this age information can be both an addition or an alternative for start/end date information.
- **comments**: Human readable comments of any kind related to this procedure



---

So then we would generate a preCDE.csv file (filename is NOT flexible!  Do not change it!) with, for example, the following structure (*Header line IS required*):

```
model,pid,context_id,value,age,value_datatype,valueIRI,process_type,unit_type,input_type,target_type,frequency_type,frequency_value,agent_id,route_type,startdate,enddate,comments
Diagnosis,30056,,,,,http://www.orpha.net/ORDO/Orphanet_93552,,,,,,,,,2006-01-19,,
```

where `Diagnosis` is the model name, `30056` is the patient unique identifier, and `http://www.orpha.net/ORDO/Orphanet_93552` is the valueIRI for the diagnosis.  `2006-01-19` is the ISO-8601 formatted standard for the startdate (start and end dates MUST use this standard and be correctly formatted!)

---

put this `preCDE.csv` into the ./data folder.

Now trigger the transformation by calling  `http://localhost:4567/` 

After a few seconds, your output data will appear in the ./data/triples folder, and will have already been automatically uploaded into GraphDB's "cde" database.


