# CARE-SM FiaB Quick Start!
---

**FAIR-in-a-Box (FiaB)** is fully compatible with the **Clinical And Registry Entries Semantic Model (CARE-SM)**. This software implements a workflow that uses **CSV** and **YARRRML** templates to define the RDF shape and perform the transformation.

The only requirement is a **CSV template** that contains patient data based on CARE-SM. Once you have created and populated your CSV template(s), place the file(s) into the `FAIR-ready-to-go/data` folder. 

---

## How to Populate the CSV?

An example CSV data file called **`Diagnosis.csv`** is included in `FAIR-ready-to-go/data`. This file can be used as a default test option if you are unsure how to prepare your own template.  

If you want to use your own data, remove the `Diagnosis.csv` file and follow one of the options below:

1. **Map your own data:**  
   Check to the [CARE-SM Glossary documentation](https://care-sm.readthedocs.io/en/latest/glossary.html), which contains all the details needed for creating and populating your CSV template.

2. **Use predefined synthetic data:**  
   CARE-SM provides a set of synthetic CSV data tables for testing FiaB. You can find them [here](https://github.com/CARE-SM/CARE-SM-Implementation/tree/main/CSV/).

> **Note:** CSV filenames are **not flexible**. They are controlled by a specific vocabulary described in the [CARE-SM Glossary documentation](https://care-sm.readthedocs.io/en/latest/glossary.html).  

---

## Running the Transformation

Once your CSV data table is located in `FAIR-ready-to-go/data`, you can trigger the transformation by opening  `http://localhost:4567/` in your web browser. 

After a few seconds, your output RDF data will appear in the `FAIR-ready-to-go/data/triples` folder and will also be automatically uploaded into GraphDB’s **`cde`** database.