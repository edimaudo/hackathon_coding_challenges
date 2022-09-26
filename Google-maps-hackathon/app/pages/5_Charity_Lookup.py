import streamlit as st
import pandas as pd
import plotly.express as px


@st.cache
def load_data():
    data = pd.read_excel(DATA_URL)
    return data

# Load data
DATA_URL = "OTF.xlsx"
df = load_data()