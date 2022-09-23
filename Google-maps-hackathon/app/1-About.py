# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import datetime
import re, string



st.set_page_config( 
    page_title="OTF Charity Insights",
)

st.title('OTF Charity Insights')
# About
st.header("About")
st.subheader("Challenge Information")
st.markdown("""
    Google Maps Platform allows developers to create unique location-based experiences using our APIs & SDKs. Now is your chance to build or expand an existing app to incorporate rich location experiences using the latest APIs and push the boundaries of what is possible with our platform.
    **WHAT TO BUILD**
    Build an application that uses at least two Google Maps Platform APIs within at least one of the following categories:

    **Categories**
    - **Map Customization** - Customize your maps using cloud styling
    - **Data Visualization** - Visualize data on a map to tell a meaningful story
    - **Mobile App** - Mobile app that is built using any one of our mobile SDKs
    - **User Experience** - Most unique idea and map experience
""")
st.subheader("About OTF")
st.markdown("""
    The Ontario Trillium Foundation (OTF) is an agency of the Government of Ontario, and one of Canada's largest granting foundations. 
    Every year, more than 3000 applications are received, and over 
    \$ 136 million in grants are awarded to more than 1,000 community organizations. 
    This means OTF will invest more than $1 billion in Ontario’s public benefit sector over the next decade, 
    creating significant opportunities for positive community change.

""")