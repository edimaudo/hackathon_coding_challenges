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
def load_data(filename):
	output = pd.read_csv(filename)
	return (output)

# Create a text element and let the reader know the data is loading.
load__data_state = st.text('Loading data...')


warnings = load_data('warnings.csv')
SWITCH = load_data('SWITCH.csv')
SERVICE_MANAGER = load_data('SERVICE_MANAGER.csv')
SERVER_APP = load_data('SERVER_APP.csv')
LUN = load_data('LUN.csv')
APP_SERVICE = load_data('APP_SERVICE.csv')
APP_APP = load_data('APP_APP.csv')

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
load__data_state.text('Loading data...done!')

#=====================
# Exploratory Analysis
#=====================
st.header("Exploratory Analysis")

st.subheader('Service Owners')

## Count of Services by Service manager - 
fig = px.bar(SERVICE_MANAGER, x='SERVICE_OWNER',hover_name='SERVICE_OWNER',title='Services by Service Manager')
st.plotly_chart(fig)

## Warning Breakdown
## Count of warnid by event type 
fig = px.bar(warnings, x='EVENT_TYPE',hover_name='EVENT_TYPE',title='Warning count by event type')
st.plotly_chart(fig)

## SERVER_APP - breakdown by hoZt_name	status	app_name
fig = px.bar(SERVER_APP, x='STATUS',hover_name='STATUS',title='Status count')
st.plotly_chart(fig)

## APP_SERVICE - count of tier #by SERVICE NAME
fig = px.bar(APP_SERVICE, x='TIER',hover_name='TIER',title='TIER Count')
st.plotly_chart(fig)


## combine service manager and app service using service name
## service owner by tier - FOR INTERACTIVITY IN STREAMLIT

SERVICE_MANAGER_APP = pd.merge(left=SERVICE_MANAGER, right=APP_SERVICE, left_on='SERVICE_NAME', 
                               right_on='SERVICE_NAME')

fig = px.bar(SERVICE_MANAGER_APP, x='SERVICE_OWNER',hover_name='TIER',title='Service Owner by Tier')
st.plotly_chart(fig)



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
