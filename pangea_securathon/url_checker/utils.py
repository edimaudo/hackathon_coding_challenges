# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import datetime
import os, os.path
import warnings
import random
import pickle
from pycaret.classification import *
import datetime

# Dashboard text
APP_NAME = 'Check the URL!'


warnings.simplefilter(action='ignore', category=FutureWarning)
st.set_page_config( 
    page_title=APP_NAME,
)

