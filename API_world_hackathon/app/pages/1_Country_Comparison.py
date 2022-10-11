# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
import requests

# Load data
@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data
DATA_URL = "country_list.xlsx"
df = load_data()

st.title('CountryXM')
st.header("Country Comparison")
country = df['Country'].unique()
country  = country.astype('str')
country.sort()

country_choice_1 = st.selectbox("Select the first country",country, index=31)
country_choice_2 = st.selectbox("Select the second Country",country,key=2,index=8)
clicked = st.button("Compare Countries")

def return_country_data(url_link, country_name):
    url = url_link + country_name
    payload = {}
    headers= {
    "apikey": "WldHgmdK715yGyFZ5vW4BBztbstAyPEA"
    }
    try:
        response = requests.request("GET", url, headers=headers, data = payload)
        status_code = response.status_code
        result = response.text
    except:
        result = []
    return result

if clicked:
    first_country_result = ""
    secong_country_result = ""
    