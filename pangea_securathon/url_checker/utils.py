# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import datetime
import os, os.path
import warnings
import random

# Dashboard text
APP_NAME = 'URL Classifier'

warnings.simplefilter(action='ignore', category=FutureWarning)
st.set_page_config( 
    page_title=APP_NAME,
)

# Text
URL_TEXT = 'Enter a URL'