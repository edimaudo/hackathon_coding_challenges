# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import datetime
import os, os.path
import warnings
import random
import whois
import validators
from validators import ValidationFailure

# Text
APP_NAME = 'URL Classifier'
URL_TEXT = 'Enter a URL, press enter and then click the Check URL button'


st.set_page_config( 
    page_title=APP_NAME,
)

