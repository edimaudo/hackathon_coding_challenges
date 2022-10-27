# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import datetime
import re, string

st.set_page_config( 
    page_title="About"
)

st.title('OTF Charity Insights')
# About
st.subheader("About Application")
st.markdown("""
    Application analyzes OTF data from 1999 to 2021 and provides insights into different charities in Ontario, Canada.
""")
st.subheader("About OTF")
st.markdown("""
    The Ontario Trillium Foundation (OTF) is an agency of the Government of Ontario, and one of Canada's largest granting foundations. 
    Every year, more than 3000 applications are received, and over 
    \$ 136 million in grants are awarded to more than 1,000 community organizations. 
    This means OTF will invest more than $1 billion in Ontario’s public benefit sector over the next decade, 
    creating significant opportunities for positive community change.

""")