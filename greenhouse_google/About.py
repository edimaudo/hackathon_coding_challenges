import streamlit as st
from utils import *

st.set_page_config(
    page_title="👋 About",
    page_icon="👋",
)

st.title(APP_NAME)
st.header(ABOUT_HEADER)

st.markdown(
    """
    Focusing on the theme - *Nature's Fury*, this project provides the opporunity to analyze annual greenhouse gas air emissions by activity and by region. 
    It is built using [streamlit](https://streamlit.io/cloud) and [Google Gemini](https://aistudio.google.com/).  The data is from [Annual Greenhouse Gas (GHG) Air Emissions Accounts](https://climatedata.imf.org/datasets/c8579761f19740dfbe4418b205654ddf/explore?showTable=true).
    """
)