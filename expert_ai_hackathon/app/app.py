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

st.title('Google Play Printer Insights')

# About
st.header("About")
with st.expander("About"):
    st.write("Printers! We all have a love-hate relationship with them.  When things are going well it is perfect.  Just one glitch or driver issue and all hell breaks lose")
    st.write("There has been a proliferation of printer apps to make the printing process easier.")
    st.write("The goal is analyze printer app information scraped from the Google Play store")

# Overview
st.header("Overview")
with st.expander("overview"):
    st.write("Here is a preview of the data")
    st.dataframe(df.head(100))

st.header("Summary")
with st.expander("Data summary"):
    st.write("Overview of the data")
    

# Analysis
st.header("Analysis")
with st.expander("analysis"):
    st.write("")
    st.write("")
    st.write("")

# NLP
st.header("NLP")
with st.expander("NLP"):
    st.write("")
    st.write("")
    st.write("")
