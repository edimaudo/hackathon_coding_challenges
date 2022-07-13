Tweet hall of fame
Top Tweeters
Top Hashtags
Top words
Top Emojis

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

st.header("Tweet Hall of Fame!")
fame_column1, fame_column2,fame_column3, fame_column4= st.columns(4)
fame_column1.header("Top Tweeter!")
fame_column2.header("Top Hashtags!")
fame_column3.header("Top words!")
fame_column4.header("Top Emojis!")