# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path


@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data

# Load data
DATA_URL = "reviews.csv"
df = load_data()

st.title('Google Play Printer Apps Insights')

# About
st.header("About")
with st.expander("About"):
    st.write("Printers! We all have a love-hate relationship with them.  When things are going well it is perfect.  Just one glitch or driver issue and all hell breaks lose")
    st.write("There has been a proliferation of printer companion apps to make the printing process easier.  These apps are what someone might use to print remotely or scan on the go")
    st.write("The goal is perform text analysis on companion app reviews.  The data was scraped from the Google Play store.  The apps analyzed are Epson SmartPanel, Epson iPrint, HP Smart and Canon Print")

# Overview
st.header("Overview")
with st.expander("overview"):
    st.write("Here is a preview of the data")
    st.dataframe(df.head(100))

st.header("Summary")
with st.expander("Data summary"):
    metric_column1, metric_column2,metric_column3,metric_column4, metric_column5,metric_column6 = st.columns(6)
    metric_column1.metric("No. of apps",str( len(df['appId'].unique())))
    metric_column2.metric("No. of reviewers",str(len(df['userName'].unique())))
    metric_column3.metric("No. of reviews",str(len(df['reviewId'].unique())))
    metric_column4.metric("Average Score",str(float("{:.2f}".format(df['score'].mean()))))
    
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

# Analysis
st.header("Analysis")
with st.expander("analysis"):
    app_list = df_analysis['app'].unique()
    app_list.sort()
    app_choice = st.multiselect("App",app_list)
    st.subheader("")
    st.subheader("")
    st.subheader("")
    st.subheader("")
    st.subheader("")


# NLP
st.header("NLP")
with st.expander("NLP"):
    st.write("")
    st.write("")
    st.write("")
