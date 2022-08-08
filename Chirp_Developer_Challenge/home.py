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
import tweepy

# Load Twitter data
cities = ['Ajax','Aurora','Bradford West Gwillimbury','Brampton','Brock','Burlington','Caledon',
'Clarington','East Gwillimbury','Georgina','Halton Hills','King','Markham','Milton','Mississauga',
'Mono','New Tecumseth','Newmarket','Oakville','Orangeville','Oshawa','Pickering','Richmond Hill',
'Scugog','Uxbridge','Vaughan','Whitby','Whitchurch-Stouffville']

# Twitter API information


st.title('Overview')
with st.expander("List of GTA Cities"):
    options = st.multiselect(
     'Cities',cities,cities)

# Metrics
st.header("Top of the Tweets!")
metric_column1, metric_column2,metric_column3, metric_column4= st.columns(4)
metric_column1.metric("Tweets today","")
metric_column2.metric("Tweeters today","")
metric_column3.metric("Most liked tweet","")
metric_column4.metric("Most retweets","")

# Graphs 
#Tweet volume (today, week)
st.header("Tweet Timeline!")
timeline_column1, timeline_column2= st.columns(2)
timeline_option = ('Today','Week')
tweet_volume_option = st.selectbox('Time option',timeline_option)



