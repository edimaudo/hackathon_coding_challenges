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
warnings = pd.read_csv('warnings.csv')
SWITCH = pd.read_csv('SWITCH.csv')
SERVICE_MANAGER = pd.read_csv('SERVICE_MANAGER.csv')
SERVER_APP = pd.read_csv('SERVER_APP.csv')
LUN = pd.read_csv('LUN.csv')
APP_SERVICE = pd.read_csv('APP_SERVICE.csv')
APP_APP = pd.read_csv('APP_APP.csv')

#=====================
# Exploratory Analysis
#=====================




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
