# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path


#@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data

# Load data
DATA_URL = "reviews.csv"
df = load_data()

st.title('Google Play Printer Apps Insights')

# About
st.header("About")
with st.expander("About"):
    st.write("Printers! We all have a love-hate relationship with them.  When things are going well it is perfect.  Just one glitch or driver issue and all hell breaks lose")
    st.write("There has been a proliferation of printer companion apps to make the printing process easier.  These apps are what someone might use to print remotely or scan on the go")
    st.write("The goal is perform text analysis on companion app reviews.  The data was scraped from the Google Play store.  The apps analyzed are Epson SmartPanel, Epson iPrint, HP Smart and Canon Print")

# Overview
st.header("Overview")
with st.expander("overview"):
    st.write("Here is a preview of the data")
    st.dataframe(df.head(100))

st.header("Summary")
with st.expander("Data summary"):
    metric_column1, metric_column2,metric_column3,metric_column4, metric_column5,metric_column6 = st.columns(6)
    metric_column1.metric("No. of apps",str( len(df['appId'].unique())))
    metric_column2.metric("No. of reviewers",str(len(df['userName'].unique())))
    metric_column3.metric("No. of reviews",str(len(df['reviewId'].unique())))
    metric_column4.metric("Average Score",str(float("{:.2f}".format(df['score'].mean()))))
    
df_analysis = df
def companion_app_update (row):
    if row['appId'] == 'com.hp.printercontrol':
        return 'HP'
    elif row['appId'] == 'jp.co.canon.bsd.ad.pixmaprint':
        return 'Canon'
    elif row['appId'] == 'epson.print':
        return 'Epson'
    else:
        return 'Epson-Smart'
df_analysis['app'] = df_analysis.apply (lambda row: companion_app_update(row), axis=1)

# Analysis
st.header("Analysis")
with st.expander("analysis"):
    app_list = df_analysis['app'].unique()
    app_list.sort()
    app_choice = st.multiselect("Companion App",app_list,app_list)
    analysis = df_analysis[df_analysis['app'].isin(app_choice)]
    
    #Average Printer Score
    st.subheader("Average Printer Score")
    printer_score = analysis[['app','score']]
    printer_score_agg = printer_score.groupby('app').agg(Total = ('score', 'mean')).reset_index()
    printer_score_agg.columns = ['Companion App', 'Score']
    printer_score_agg = printer_score_agg.sort_values("Score", ascending=True).reset_index()
    fig = px.bar(printer_score_agg, x="Score", y="Companion App", orientation='h')
    st.plotly_chart(fig)

    # Printer review count
    st.subheader("App review count")
    printer_count = analysis[['app', 'reviewId']]
    printer_count_agg = printer_count.groupby(['app'])['reviewId'].agg('count').reset_index()
    printer_count_agg.columns = ['Companion App', '# of Reviews']
    printer_count_agg = printer_count_agg.sort_values("# of Reviews", ascending=True).reset_index()
    fig = px.bar(printer_count_agg, x="# of Reviews", y="Companion App", orientation='h')
    st.plotly_chart(fig)

    #Printer Score over time
    st.subheader("Average Printer Score over time")
    analysis['Date'] = pd.to_datetime(analysis['at']).dt.date
    printer_score_time = analysis[['app','score','Date']]
    printer_score_time_agg = printer_score_time.groupby(['app','Date']).agg(Total = ('score', 'mean')).reset_index()
    printer_score_time_agg.columns = ['Companion App', 'Date','Score']
    printer_score_time_agg = printer_score_time_agg.sort_values("Date")
    fig = px.line(printer_score_time_agg, x="Date", y="Score",color='Companion App')
    st.plotly_chart(fig)
    
    #Average thumbs up by selected printer
    st.subheader("Average Thumbs Up Count")
    printer_thumbsup = analysis[['app','thumbsUpCount']]
    printer_thumbsup_agg = printer_thumbsup.groupby('app').agg(Total = ('thumbsUpCount', 'mean')).reset_index()
    printer_thumbsup_agg.columns = ['Companion App', 'Thumbs Up']
    printer_thumbsup_agg = printer_thumbsup_agg.sort_values("Thumbs Up", ascending=True).reset_index()
    fig = px.bar(printer_thumbsup_agg, x="Thumbs Up", y="Companion App", orientation='h')
    st.plotly_chart(fig)
    
    
    
# NLP
st.header("NLP")
with st.expander("NLP"):
    st.write("")
