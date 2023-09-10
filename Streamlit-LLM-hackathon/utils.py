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
import re, string


"""
# Application Text
"""
APP_NAME = 'Printer Companion Apps Insights'
APP_ABOUT = 'About'
APP_OVERVIEW = 'OVERVIEW'
APP_DATA_INSIGHTS = 'DATA INSIGHTS'
APP_QA = 'DATA QA'
APP_TEXT_ANALYSIS = 'REVIEW TEXT ANALYSIS'

"""
#Application Title
"""
st.set_page_config( 
    page_title=APP_NAME,
)

"""
# Review Data Load
"""
@st.cache_data
def load_data():
    data = pd.read_csv(DATA_URL)
    return data

DATA_URL = "reviews.csv"
df = load_data()

# Data munging
df_analysis = df

def companion_app_update (row):
    if row['appId'] == 'com.hp.printercontrol':
        return 'HP'
    elif row['appId'] == 'jp.co.canon.bsd.ad.pixmaprint':
        return 'Canon'
    elif row['appId'] == 'epson.print':
        return 'Epson'
    else:
        return 'Epson-Smart'

df_analysis['app'] = df_analysis.apply (lambda row: companion_app_update(row), axis=1)
df_analysis['Date'] = pd.to_datetime(df_analysis['at']).dt.date
df_analysis['Year'] = pd.to_datetime(df_analysis['Date']).dt.year
df_analysis['Month'] = pd.to_datetime(df_analysis['Date']).dt.month_name()

nlp_year_list = df_analysis['Year'].unique()
nlp_year_list  = nlp_year_list.astype('int')
nlp_year_list.sort()

nlp_app_list = df_analysis['app'].unique()
nlp_app_list.sort()

nlp_month_list = df_analysis['Month'].unique()
nlp_month_list = pd.DataFrame(nlp_month_list,columns = ['Month'])
month_dict = {'January':1,'February':2,'March':3, 'April':4, 'May':5, 'June':6, 'July':7, 
'August':8, 'September':9, 'October':10, 'November':11, 'December':12}
nlp_month_list = nlp_month_list.sort_values('Month', key = lambda x : x.apply (lambda x : month_dict[x]))

nlp_score_list = df_analysis['score'].unique()
nlp_score_list   = nlp_score_list .astype('int')
nlp_score_list.sort()