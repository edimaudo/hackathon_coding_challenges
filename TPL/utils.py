"""
Libraries
"""
import streamlit as st
import pandas as pd
import plotly.express as px
import datetime
import os, os.path
import warnings
import random
#import pickle
#from pycaret.classification import *

"""
Dashboard Text
"""
APP_NAME = 'Toronto Public Library Insights'
OVERVIEW_HEADER = 'Overview'
ABOUT_HEADER = 'About'
LIBRARY_OVERVIEW_HEADER = 'Library Overview'
LIBRARY_PROFILE_HEADER = 'Library Profile'
LIBRARY_EXPLORATION_HEADER = 'Library Exploration'
LIBRARY_COMPARISON_HEADER = 'Library Comparison'
APP_FILTERS = 'Filters'

warnings.simplefilter(action='ignore', category=FutureWarning)
st.set_page_config( 
    page_title=APP_NAME,
)

#image for TPL
img = "img/tpl_image.png"

# Load data
@st.cache_data
def load_data(filetype,data_file):
    if filetype == "csv":
        data = pd.read_csv(data_file)
    else:
        data = pd.read_excel(data_file)
    return data

# Wellbeing data
wellbeing_economics = load_data("csv","data/wellbeing-toronto-economics.csv")
wellbeing_culture = load_data("csv","data/wellbeing-toronto-culture.csv")
wellbeing_health = load_data("csv","data/wellbeing-toronto-health.csv")
wellbeing_transportation = load_data("csv","data/wellbeing-toronto-transportation.csv")
wellbeing_education = load_data("csv","data/wellbeing-toronto-education.csv")

#library data


# Data munging