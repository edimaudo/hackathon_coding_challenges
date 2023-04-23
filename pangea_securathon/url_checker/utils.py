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
import pangea.exceptions as pe
from pangea.config import PangeaConfig
from pangea.services import Audit
import requests
import json

# Text
APP_NAME = 'URL Classifier'

st.set_page_config( 
    page_title=APP_NAME,
)

