# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)


st.set_page_config(
    page_title="CountryXM",
    page_icon="world_map3.jpeg"
)

st.title('CountryXM')
st.set_option('deprecation.showPyplotGlobalUse', False)

st.header("About")
with st.expander(" "):
    st.write(""" 
        Web application that provides insights about countries.
    """)