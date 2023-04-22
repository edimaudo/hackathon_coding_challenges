# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import datetime
import os, os.path
import warnings
import random
import validators
import whois

# Text
APP_NAME = 'URL Classifier'
URL_TEXT = 'Enter a URL'


st.set_page_config( 
    page_title=APP_NAME,
)

