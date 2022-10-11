# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
import requests


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

country_choice = st.selectbox("Select a Country",country)
clicked = st.button("Get Country Information")
if clicked:
    url = "https://api.apilayer.com/geo/country/name/" + country_choice
    payload = {}
    headers= {
    "apikey": "WldHgmdK715yGyFZ5vW4BBztbstAyPEA"
    }
    try:
        #response = requests.request("GET", url, headers=headers, data = payload)
        #status_code = response.status_code
        #result = response.text
        # Output
        first_container = st.container()
        second_container = st.container()
        third_container = st.container()
        fourth_container = st.container()
        
        with first_container:
            metric_column1, metric_column2,metric_column3 = st.columns(3)
            #metric_column1.#st.image("") result["flag"]

        with second_container:
            #capital - metric
            #region - metric
            #population - metric
            metric_column1, metric_column2,metric_column3 = st.columns(3)
            metric_column1.metric("","")
        with third_container:
            #currency - metric
            #calling code - metric
            #longitude and latitude - metric
            st.write("")
        with fourth_container:
                        #languages list - list
            #timezones - list
            #regional block - list
            # borders - list
            st.write("")        

    except:
        st.error('There is an error getting the country data')
