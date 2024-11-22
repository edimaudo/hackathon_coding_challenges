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
from pycaret.regression import *
import datetime


# Dashboard text
APP_NAME = 'WINE QUALITY INSIGHTS'
ABOUT_HEADER = 'ABOUT'
OVERVIEW_HEADER = 'OVERIEW'
PREDICTION_NAME_HEADER = 'WINE QUALITY PREDICTION'
WINE_EXPLORATION_HEADER = 'WINE QUALITY EXPLORATION'
APP_FILTERS = 'FILTERS'