#=====================
# About
#=====================
# The application analyzes IT Data using data visualization and graphs

#=====================
# Libraries
#=====================
import streamlit as st
import numpy as np
import pandas as pd
import matplotlib
import plotly
import plotly.offline as py
import plotly.graph_objs as go
import plotly.express as px

st.title("IT Data Insights")
#=====================
# Load data
#=====================
@st.cache #for caching

# Create a text element and let the reader know the data is loading.
data_load_state = st.text('Loading data...')

warnings = pd.read_csv('warnings.csv')
SWITCH = pd.read_csv('SWITCH.csv')
SERVICE_MANAGER = pd.read_csv('SERVICE_MANAGER.csv')
SERVER_APP = pd.read_csv('SERVER_APP.csv')
LUN = pd.read_csv('LUN.csv')
APP_SERVICE = pd.read_csv('APP_SERVICE.csv')
APP_APP = pd.read_csv('APP_APP.csv')

#add column name to APP_APP
#Apps can call on each other
APP_APP.columns =['APP_ID','TOAPP_ID'] 
#update name so that they are consistent across the boarding
warnings.columns = ['WARN_ID','EVENT_TYPE','APP_ID']
SWITCH.columns = ['HOST','HOST_NAME','SWITCH_ID','SWITCH_NAME','STORAGE_ARRAY_ID']
SERVICE_MANAGER.columns = ['SERVICE_MANAGER_ID','SERVICE_NAME','SERVICE_OWNER']
SERVER_APP.columns = ['HOZT_NAME','STATUS','APP_ID','APP_NAME']
APP_SERVICE.columns = ['APP_ID','SHORT_NAME','TIER','APP_SERVICE_ID','SERVICE_NAME']
LUN.columns = ['LUN_ID','LUN_NAME','LUN_TOTAL_CAPACITY','LUN_ESTIMATED_USED',
 'POOL_ID','POOL_NAME','POOL_RAW_CAPACITY','POOL_USED_CAPACITY','POOL_USER_CAPACITY','POOL_SUBSCRIBED_CAPACITY',
 'HOZT','HOST_NAME','STORAGE_ARRAY_ID','ARRAY_NAME',  
 'STORAGE_ARRAY_Capcity','STORAGE_ARRAY_ALLOCATED','STORAGE_ARRAY_AVAILABLE','STORAGE_ARRAY_RAW_CAPACITY',
 'STORAGE_ARRAY_RAW_ALLOCATED','STORAGE_ARRAY_RAW_AVAILABLE']

# Notify the reader that the data was successfully loaded.
data_load_state.text('Loading data...done!')

#=====================
# Exploratory Analysis
#=====================
st.subheader('Number of pickups by hour')
hist_values = np.histogram(data[DATE_COLUMN].dt.hour, bins=24, range=(0,24))[0]
st.bar_chart(hist_values)



#=====================
# Graph models
#=====================


# Impact analysis
# E.g. What team's production servers are over provisioned and how big is the impact
# appImpact, WarningImpact, StorageImpact


# App Analysis
# What is the peak workload for an application and where is the bottleneck



# System interaction
# How do the different systems and people interact and what are their patterns



# Recommendation
# What is the recommendation action based on server status by team
# IT staffing and resource consumption + looking at cost
