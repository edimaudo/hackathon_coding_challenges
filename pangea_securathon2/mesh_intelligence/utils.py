# Libraries
import streamlit as st
import whois
import validators
from validators import ValidationFailure
import requests
import json
import pangea.exceptions as pe
from pangea.config import PangeaConfig
from pangea.services import DomainIntel
import os
from urllib.parse import urlparse

# Text
APP_NAME = 'Mesh Intelligence'
URL_NAME = "URL & Domain Insights"
IP_NAME = "IP Inisghts"

st.set_page_config( 
    page_title=APP_NAME,
)

