#================
# GTAEhTweets
#================
# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import pandas as pd
import matplotlib.pyplot as plt

# Load Twitter data
cities = ['Ajax','Aurora','Bradford West Gwillimbury','Brampton','Brock','Burlington','Caledon','Clarington','East Gwillimbury','Georgina','Halton Hills','King','Markham','Milton','Mississauga','Mono','New Tecumseth','Newmarket','Oakville','Orangeville','Oshawa','Pickering','Richmond Hill','Scugog','Uxbridge','Vaughan','Whitby','Whitchurch-Stouffville']


st.title('Overview')

options = st.multiselect(
     'Cities',cities,cities)

 #filter data    



st.header("Twitter Metrics")
metric_column1, metric_column2= st.columns(2)
metric_column1("Tweets today","")
metric_column2("Tweeters today","")


    # Graphs 
    #Tweet volume (today, week)
    #tweets by hour of day (today,week)

    # Container
    #twitter grid design
    #Most liked tweets (past 12 hours)
    #Most retweet (past 12 hrs)