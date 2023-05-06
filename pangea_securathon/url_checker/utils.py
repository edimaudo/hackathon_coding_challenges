# Libraries
import streamlit as st
import whois
import validators
from validators import ValidationFailure
import requests
import json

# Text
APP_NAME = 'URL Classifier'

st.set_page_config( 
    page_title=APP_NAME,
)

