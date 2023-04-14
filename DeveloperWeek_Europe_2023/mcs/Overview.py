# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import datetime
import os, os.path
import warnings
from utils import * 

warnings.simplefilter(action='ignore', category=FutureWarning)
st.set_page_config( 
    page_title=APP_NAME,
)
st.title(APP_NAME)

st.header("Overview")

# Load data
@st.cache_data
def load_data(DATA_URL):
    data = pd.read_csv(DATA_URL)
    return data

DATA_URL = "Major_Crime_Indicators_Open_Data.csv"    
df = load_data(DATA_URL)


# Data munging
YEAR =  df['OCC_YEAR'].unique()
YEAR  = YEAR.astype('int')
YEAR.sort()

MONTH = df['OCC_MONTH'].unique()
MONTH = pd.DataFrame(MONTH,columns = ['Month'])
month_dict = {'January':1,'February':2,'March':3, 'April':4, 'May':5, 'June':6, 'July':7, 
'August':8, 'September':9, 'October':10, 'November':11, 'December':12}
MONTH = MONTH.sort_values('Month', key = lambda x : x.apply (lambda x : month_dict[x]))

DAY_OF_WEEK = df['OCC_DOW'].unique()
DAY_OF_WEEK = pd.DataFrame(DAY_OF_WEEK,columns = ['DOW'])
dow_dict = {'Monday':1,'Tuesday':2,'Wednesday':3, 'Thursday':4, 'Friday':5, 'Saturday':6, 'Sunday':7}
DAY_OF_WEEK = DAY_OF_WEEK.sort_values('DOW', key = lambda x : x.apply (lambda x : dow_dict[x]))

MCI_CATEGORY = df['MCI_CATEGORY'].unique()
MCI_CATEGORY  = MCI_CATEGORY.astype('str')
MCI_CATEGORY.sort()

NEIGHBORHOOD = df['NEIGHBOURHOOD_158'].unique()
NEIGHBORHOOD = NEIGHBORHOOD.astype('str')
NEIGHBORHOOD.sort()

PREMISES_TYPE = df['PREMISES_TYPE'].unique()
PREMISES_TYPE  = PREMISES_TYPE.astype('str')
PREMISES_TYPE.sort()


with st.container():
    col1, col2 = st.columns([1, 3])
    # with col1:
    #     year_options = st.multiselect('Year',YEAR)
    # with col2:
    #     month_options = st.multiselect('Month',MONTH)
    # with col3:
    #     dow_options = st.multiselect('Day of Week',DAY_OF_WEEK)
    # with col4:
    #     mci_options = st.multiselect('Crime Type',MCI_CATEGORY)
    # with col5:
    #     month_options = st.multiselect('Premises Type',PREMISES_TYPE)
    # with col6:
    #     month_options = st.multiselect('Neighborhood',NEIGHBORHOOD)



#TOTAL MCI BY YEAR
#Total MCI BY MONTH GRAPH
#Total MCI BY WEEK GRAPH
#Total MCI BY HOUR GRAPH
# Crime type heatmap
#Properties heatmap