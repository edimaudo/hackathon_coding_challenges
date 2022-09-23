import streamlit as st
import pandas as pd
import plotly.express as px
import datetime
import re, string
import streamlit.components.v1 as components
import os, os.path


st.title('OTF Charity Insights')
st.header("Year Insights")

df = st.session_state['df']


with st.expander(" "):
    # Age breakdown 
    year_list = df['Fiscal Year'].unique()
    year_list  = year_list.astype('int')
    year_list.sort()
    year_choice = st.selectbox("year",year_list)
