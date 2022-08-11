# Load libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import pandas as pd

st.title('OTF Charity Insights')
st.write("The goal is to use open data from Ontario Trillium Foundation to analyze charity information")
st.write("The Ontario Trillium Foundation (OTF) is an agency of the Government of Ontario and one of Canada’s leading granting foundations. Our investments in communities across the province help build healthy and vibrant communities. Our key funder, the Ministry of Heritage, Sport, Tourism and Culture Industries enables us to provide grants that can make the greatest impact. OTF also administers grants on behalf of the Ministry of Children, Community and Social Services. Last year, $115 million was invested into more than 644 projects in communities across the province")
st.write("https://otf.ca/who-we-are/about-us/our-story")


@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    data.dropna(inplace=True)
    return data

# Load data
DATA_URL = "otf.xlsx"
df = load_data()