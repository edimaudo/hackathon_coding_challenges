# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import datetime
import os, os.path
import warnings
import random
import pickle
from pycaret.classification import *
import datetime

# Dashboard text
APP_NAME = 'Toronto Wellbeing and Crime Insights'
OVERVIEW_HEADER = 'Overview'
#PREDICTION_NAME_HEADER = 'Crime Type Prediction'
CRIME_NAME_HEADER = 'Crime Only Exploration'
NEIGHBOUR_NAME_HEADER = 'Neighbourhood Wellbeing & Crime Exploration'
APP_FILTERS = 'Filters'

warnings.simplefilter(action='ignore', category=FutureWarning)
st.set_page_config( 
    page_title=APP_NAME,
)

# Load data
@st.cache_data
def load_data(DATA_URL):
    data = pd.read_csv(DATA_URL)
    return data

# crime data
df = load_data("data/Major_Crime_Indicators_Open_Data.csv")

# wellbeing data
wellbeing_indicators = load_data("data/wellbeing-toronto-civics-equity-indicators.csv")
wellbeing_culture = load_data("data/wellbeing-toronto-culture.csv")
wellbeing_economics = load_data("data/wellbeing-toronto-economics.csv")
wellbeing_education = load_data("data/wellbeing-toronto-education.csv")
wellbeing_health = load_data("data/wellbeing-toronto-health.csv")
wellbeing_transportation = load_data("data/wellbeing-toronto-transportation.csv")

# Data munging
YEAR =  df['OCC_YEAR'].unique()
YEAR  = YEAR.astype('int')
YEAR.sort()

MONTH = df['OCC_MONTH'].unique()
MONTH  = MONTH.astype('str')
MONTH = pd.DataFrame(MONTH,columns = ['Month'])
month_dict = {'January':1,'February':2,'March':3, 'April':4, 'May':5, 'June':6, 'July':7, 
'August':8, 'September':9, 'October':10, 'November':11, 'December':12}
MONTH = MONTH.sort_values('Month', key = lambda x : x.apply (lambda x : month_dict[x]))
MONTH = MONTH['Month'].values.tolist()

DAY_OF_WEEK = df['OCC_DOW'].unique()
DAY_OF_WEEK   = DAY_OF_WEEK.astype('str')
DAY_OF_WEEK = pd.DataFrame(DAY_OF_WEEK,columns = ['DOW'])
dow_dict = {'Monday':1,'Tuesday':2,'Wednesday':3, 'Thursday':4, 'Friday':5, 'Saturday':6, 'Sunday':7}
DAY_OF_WEEK = DAY_OF_WEEK.sort_values('DOW', key = lambda x : x.apply (lambda x : dow_dict[x]))
DAY_OF_WEEK = DAY_OF_WEEK['DOW'].values.tolist()

HOUR=  df['OCC_HOUR'].unique()
HOUR  = HOUR.astype('int')
HOUR.sort()

DAY =  df['OCC_DAY'].unique()
DAY  = DAY.astype('int')
DAY.sort()

MCI_CATEGORY = df['MCI_CATEGORY'].unique()
MCI_CATEGORY  = MCI_CATEGORY.astype('str')
MCI_CATEGORY.sort()

NEIGHBORHOOD = df['NEIGHBOURHOOD_158'].unique()
NEIGHBORHOOD = NEIGHBORHOOD.astype('str')
NEIGHBORHOOD.sort()

PREMISES_TYPE = df['PREMISES_TYPE'].unique()
PREMISES_TYPE  = PREMISES_TYPE.astype('str')
PREMISES_TYPE.sort()

 