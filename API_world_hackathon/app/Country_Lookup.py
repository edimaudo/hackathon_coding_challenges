# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
import requests
import json

st.set_page_config(
    page_title="CountryXM",
    page_icon="WorldMap.png"
)

# Load data
@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data
DATA_URL = "country_list.xlsx"
df = load_data()

st.title('CountryXM')
st.image("world_map2.jpeg")
st.set_option('deprecation.showPyplotGlobalUse', False)

st.header("About")
with st.expander(" "):
    st.write(""" 
        Web application that provides insights about countries.
    """)
st.header("Country Lookup")
country = df['Country'].unique()
country  = country.astype('str')
country.sort()
country_choice = st.selectbox("Select a Country",country,index=31)
clicked = st.button("Get Country Information")
if clicked:
    url = "https://api.apilayer.com/geo/country/name/" + country_choice
    payload = {}
    headers= {
    "apikey": "WldHgmdK715yGyFZ5vW4BBztbstAyPEA"
    }
    try:
        response = requests.request("GET", url, headers=headers, data = payload)
        status_code = response.status_code
        result = response.text
        output = json.loads(result)
        # Output
        first_container = st.container()
        second_container = st.container()
        third_container = st.container()
        fourth_container = st.container()
        with first_container:
            metric_column1, metric_column2,metric_column3 = st.columns(3)
            metric_column1.st.image(output[0]['flag'])# flag
            metric_column1.st.write(output[0]['alpha2code'])#alpha2code
            metric_column1.st.image(output[0]['alpha3code'])#alpha3code
        with second_container:
            metric_column1, metric_column2,metric_column3,metric_column4 = st.columns(4)
            metric_column1.metric("Capital",output[0]['capital']) #capital - metric
            metric_column2.metric("Region",output[0]['region']) #region - metric
            metric_column3.metric("Sub Region",output[0]['subregion']) #region - metric
            metric_column4.metric("Population",output[0]['population']) #population - metric
        with third_container:
            metric_column1, metric_column2,metric_column3,metric_column4 = st.columns(4)
            metric_column1.metric("Currency",output[0]['currencies']['name']) #currency - metric
            metric_column2.metric("Calling Code",output[0]['calling_codes']) #calling code - metric
            metric_column3.metric("Latitude and Longitude",output[0]['latitude']  + " " + output[0]['longitude']) #longitude and latitude - metric
            metric_column2.metric("Area",output[0]['area']) #area
        with fourth_container:
            metric_column1, metric_column2,metric_column3, metric_column4 = st.columns(4)
            metric_column1.st.write(output[0]['languages'])#languages list - list
            metric_column2.st.write(output[0]['timezones'])#timezones - list
            metric_column3.st.write(output[0]['regional_blocs'])#regional block - list
            metric_column4.st.write(output[0]['borders'])# borders - list
    except:
        st.error('There is an error getting the country data')
