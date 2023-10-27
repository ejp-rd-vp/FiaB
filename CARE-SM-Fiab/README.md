# CARE-SM FiaB Quick Start!
---

FAIR-in-a-box (Fiab) is fully compatible with the Clinical And Registry Entries (CARE) Semantic Model. To do so, this software implements a workflow that utilizes CSV and YARRRML as templates to define the RDF shape and its transformation.

The only requirement you have to worry about is the CSV template that contains patient data based on CARE-SM inside Fiab. Check the documentation at this [link](https://github.com/CARE-SM/CARE-SM-Implementation/blob/main/CSV/README.md). You will find every detail you need for creating and populating your CSV template with your data.

Once you have created and populated your `preCARE.csv` template (filename is NOT flexible!), put this CSV file into the `FAIR-ready-to-go/data` folder. You will find an [exemplar data table](/CARE-SM-Fiab/FAIR-ready-to-go/data/preCARE.csv) in this folder in case you have any uncertainty with your own template. You can find more exemplar CSV data at [CARE-SM implementation repo](https://github.com/CARE-SM/CARE-SM-Implementation/blob/main/CSV/exemplar_data/) 

Replace the previous file with your own template. Once you have your data table and its located at `FAIR-ready-to-go/data` you can now trigger the transformation by calling  `http://localhost:4567/`. After a few seconds, your output data will appear in the `FAIR-ready-to-go/data/triples` folder, and will have already been automatically uploaded into GraphDB's `cde` database.
