import os
import datetime as dt
import numpy as np
import pandas as pd
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, inspect
from sqlalchemy import func

from flask import (
    Flask,
    render_template,
    jsonify,
    request,
    redirect)

#################################################
# Flask Setup
#################################################
app = Flask(__name__)

#################################################
# Database Setup
#################################################

# The database URI
db = os.path.join("belly_button_biodiversity.sqlite")
engine = create_engine (f"sqlite:///{db}")

Base = automap_base()
Base.prepare(engine, reflect=True)
# Base.classes.keys()
# print(Base.classes.keys())
#  ['otu', 'samples', 'samples_metadata']

otu_tab = Base.classes.otu
samples_tab= Base.classes.samples
samples_metadata_tab=Base.classes.samples_metadata

session = Session(engine)
inspecter = inspect(engine)

#################################################
# Flask Routes
#################################################

@app.route("/")
def home():
    """Return the dashboard homepage."""
    return render_template("index.html")
 

    """List of sample names."""
# Do a sql query for returning list of column names. 
# there's over 100 sample names.   These are the column headings.  
# sqlalchemy.inspection.inspect(subject, raiseerr=True)
# Needs to bring in the inspect engine above.  
@app.route("/names/")
def sample_names(): 
# start with a blank list
    columns = inspecter.get_columns('samples')
    names = []
    for column in columns: 
        names.append(column['name'])
# get rid of "otu_id"
    del names[0]    
    return jsonify(names)

"""List of OTU descriptions."""
# extract the tuples into OTU descriptions
# column names identified through DB Browser
# Harshil's tip:use np.ravel I don't thhink I need it though.  
@app.route("/otu/")
def otu_descriptions():
    results = session.query(otu_tab.otu_id, otu_tab.lowest_taxonomic_unit_found).all()
    otu_df = pd.DataFrame(results)
# use the dataframe's index to establish the number of rows.  
    otu_count = len(otu_df.index)
    otu_info = {}
    for x in range(otu_count):
        otu_info[str(otu_df['otu_id'][x])] = otu_df['lowest_taxonomic_unit_found'][x]

    return jsonify(otu_info)
 
"""MetaData for a given sample"""
    # you'll want to strip away the BB from the sample heading.  
    # $match up with metadata sampleID, which appears to be the last digits of the name minus the "BB_"
    # create a dictionary for every metadata info (e.g. enthicity, gender.  )
    # return the jsonified dictionary@app.route("/metadata/<sample>")
    # column names identified through DB Browser
    # Define metadata to be a data dictionary of name/value pairs
@app.route('/metadata/<sample>/')
def metadata_sample(sample):
    sample_id = sample.replace('BB_','')
    result = session.query(samples_metadata_tab).filter(samples_metadata_tab.SAMPLEID == sample_id).first()
    metadata = {
        'AGE': result.AGE,
        'BBTYPE':result.BBTYPE,
        'ETHNICITY':result.ETHNICITY,
        'GENDER':result.GENDER,
        'LOCATION':result.LOCATION,
        'SAMPLEID':result.SAMPLEID
    }
    return jsonify(metadata)


    
"""MetaData for a given sample"""
 # strip BB from the sample
 # filter by sample ID and ravel the results.  SAMPLEID == sample_id
 # return jsonified wFREQ column from the samples_metadata_tab table
@app.route("/wfreq/<sample>/")
def wfreq(sample):
    sample_id = sample.replace('BB_','')
    result = session.query(samples_metadata_tab).filter(samples_metadata_tab.SAMPLEID == sample_id).first()
    return jsonify(result.WFREQ)


"""OTU IDs and Sample Values for a given sample"""
# joining OTU to sample data on OTU ID
# Return Jsonified object for rendering
# return sample  values > 1 sorted descending order , formatted as json
@app.route("/samples/<sample>/")
def samples(sample):
    results = session.query(samples_tab.otu_id, getattr(samples_tab, sample)).all()
    samples_df = pd.DataFrame(results)
    samples_df = samples_df.set_index('otu_id').sort_values(by=[sample], ascending=False).head(10).reset_index() 
    otu_ids = tuple(samples_df['otu_id'].values.tolist())
    values = tuple(samples_df[sample].values.tolist())
    sample_counts = {'otu_ids':otu_ids,'sample_values':values}
    return jsonify(sample_counts)
   
     
if __name__ == '__main__':
    app.run(debug=True)
