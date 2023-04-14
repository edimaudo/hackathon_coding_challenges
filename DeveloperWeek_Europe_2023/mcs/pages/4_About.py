# Libraries
import streamlit as st

st.title("Toronto Crime Analysis App")
st.markdown('This app provides insights into crime trends occuring in Toronto, Canada.  Data is from [Toronto Police Service](https://data.torontopolice.on.ca/pages/major-crime-indicators) and [Toronto Open Data](https://www.toronto.ca/city-government/data-research-maps/open-data/)')
st.markdown("""
The application has 4 sections:
- **Crime Overview**
- **Crime Exploration**
- **Neighborhood Crime Exploration**
- **Neighborhood Crime Comparison** 
""")
st.markdown('It was inspired by this application [TPS Crime Statistics - Major Crime Indicators](https://data.torontopolice.on.ca/pages/major-crime-indicators)')