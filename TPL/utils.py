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
Dashboard Information
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
def load_data(data_file):
    data = pd.read_csv(data_file)
    return data

# Wellbeing data
wellbeing_economics = load_data("data/wellbeing-toronto-economics.csv")
wellbeing_culture = load_data("data/wellbeing-toronto-culture.csv")
wellbeing_health = load_data("data/wellbeing-toronto-health.csv")
wellbeing_transportation = load_data("data/wellbeing-toronto-transportation.csv")
wellbeing_education = load_data("data/wellbeing-toronto-education.csv")

# library data
#Neighbourhoods.geojson
computer_learning_centre = load_data("data/Computer_Learning_Centres.csv")
digital_innovation_hub = load_data("data/Digital_Innovation_Hubs.csv")
kid_stop = load_data("data/KidsStop_Early_Literacy_Centres.csv")
neighorhood_improvement = load_data("data/Neighbourhood_Improvement_Area_Branches.csv")
general_info_branch = load_data("data/tpl-branch-general-information-2023.csv")
card_registration_branch = load_data("data/tpl-card-registrations-annual-by-branch-2012-2022.csv")
circulation_branch = load_data("data/tpl-circulation-annual-by-branch-2012-2022.csv")
visits_branch = load_data("data/tpl-visits-annual-by-branch-2012-2022.csv")
workstation_usage_branch = load_data("data/tpl-workstation-usage-annual-by-branch-2012-2022.csv")
youth_advisory = load_data("data/Youth_Advisory_Groups_Locations.csv")
youth_hubs = load_data("data/Youth_Hubs_Locations.csv")

#Data 

# List of Branches
branches = general_info_branch['BranchName'].unique()
branches  = branches.astype('str')
branches.sort()
