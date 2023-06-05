"""
# Libraries
"""
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import warnings
import numpy as np
import random
from datetime import datetime
import math 
import numpy_financial as npf

"""
# Application Text
"""
APP_NAME = 'Kiva Loans Insight App'
APP_ABOUT = 'About'
APP_LOAN = 'Loan Insight'
APP_RISK = 'Kiva Loan Risk Management'
APP_LOAN = 'Kiva Loan Impact'

"""
#Application Title
"""
st.set_page_config( 
    page_title=APP_NAME,
)

"""
# Loan Data Load
"""
@st.cache_data
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "loans.csv"
df = load_data()
year = pd.DatetimeIndex(df['DISBURSE_TIME']).year
year  = year.astype('int')
df = df.assign(Year=year)


country_list = ['Costa Rica','Columbia','Bolivia','Chile',
'Dominican Republic','Ecuador','El Salvador','Guatemala',
'Honduras','Mexico','Nicaragua','Paraguay','Peru']

"""
# Dropdowns
"""
country_data = df[(df['COUNTRY_NAME'].isin(country_list))]  
country = country_data['COUNTRY_NAME'].unique()
country  = country.astype('str')
country.sort()

sector = df['SECTOR_NAME'].unique()
sector  = sector.astype('str')
sector.sort()





    
      


