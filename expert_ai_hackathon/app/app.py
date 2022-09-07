# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import datetime
import re, string

# Load data
#@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data

DATA_URL = "reviews.csv"
df = load_data()

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
df_analysis['Date'] = pd.to_datetime(df_analysis['at']).dt.date
df_analysis['Year'] = pd.to_datetime(df_analysis['Date']).dt.year
df_analysis['Month'] = pd.to_datetime(df_analysis['Date']).dt.month_name()

nlp_year_list = df_analysis['Year'].unique()
nlp_year_list  = nlp_year_list.astype('int')
nlp_year_list.sort()
nlp_app_list = df_analysis['app'].unique()
nlp_app_list.sort()
nlp_month_list = df_analysis['Month'].unique()
nlp_month_list = pd.DataFrame(nlp_month_list,columns = ['Month'])
month_dict = {'January':1,'February':2,'March':3, 'April':4, 'May':5, 'June':6, 'July':7, 'August':8, 'September':9, 'October':10, 'November':11, 'December':12}
nlp_month_list = nlp_month_list.sort_values('Month', key = lambda x : x.apply (lambda x : month_dict[x]))
nlp_score_list = df_analysis['score'].unique()
nlp_score_list   = nlp_score_list .astype('int')
nlp_score_list.sort()

st.title('Google Play Printer Apps Insights')

# About
st.header("About")
with st.expander("About"):
    st.write("Printers! We all have a love-hate relationship with them.  When things are going well it is perfect.  Just one glitch or driver issue and all hell breaks lose.")
    st.write("There has been a proliferation of printer companion apps to make the printing process easier.  These apps are what someone might use to print remotely or scan on the go.")
    st.write("The goal is perform text analysis on companion app reviews.  The data was scraped from the Google Play store.  The apps analyzed are Epson SmartPanel, Epson iPrint, HP Smart and Canon Print.")

# Overview
st.header("Data Overview")
with st.expander("Overview"):
    st.write("Here is a preview of the data")
    st.dataframe(df.head(100))

# Summary
st.header("Data Summary")
with st.expander("Data summary"):
    metric_column1, metric_column2,metric_column3,metric_column4, metric_column5,metric_column6 = st.columns(6)
    metric_column1.metric("No. of apps",str( len(df['appId'].unique())))
    metric_column2.metric("No. of reviewers",str(len(df['userName'].unique())))
    metric_column3.metric("No. of reviews",str(len(df['reviewId'].unique())))
    metric_column4.metric("Average Score",str(float("{:.2f}".format(df['score'].mean()))))
    

# Analysis
st.header("Analysis")
with st.expander("Analysis"):
    app_list = df_analysis['app'].unique()
    app_list.sort()
    app_choice = st.multiselect("Companion App",app_list,app_list)
    analysis = df_analysis[df_analysis['app'].isin(app_choice)]
    
    # Average Printer Score
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

    # Printer Score over time
    st.subheader("Average Printer Score over time")
    printer_score_time = analysis[['app','score','Date']]
    printer_score_time_agg = printer_score_time.groupby(['app','Date']).agg(Total = ('score', 'mean')).reset_index()
    printer_score_time_agg.columns = ['Companion App', 'Date','Score']
    printer_score_time_agg = printer_score_time_agg.sort_values("Date")
    fig = px.line(printer_score_time_agg, x="Date", y="Score",color='Companion App')
    st.plotly_chart(fig)
    
    # Average thumbs up by selected printer
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
    nlp_month_choice = st.selectbox("Month",nlp_month_list, index=5)
    nlp_year_choice = st.selectbox("Year",nlp_year_list,index=3)
    nlp_app_choice = st.selectbox("Companion App",nlp_app_list,key="nlp",index=3)
    nlp_score_choice = st.selectbox("Score",nlp_score_list, index=0)
    nlp_analysis = df_analysis[(df_analysis.app == nlp_app_choice) & (df_analysis.Year == nlp_year_choice) 
    & (df_analysis.Month == nlp_month_choice) & (df_analysis.score == nlp_score_choice)]
    run_nlp = st.button("Run NLP Analysis")
    if run_nlp:
        if nlp_analysis.empty:
            st.write("No data Available! Please try another combination from the dropdowns")
        else:
            # Convert review into one large paragraph
            text = '. '.join(nlp_analysis['Review'])
            # text cleanup
            text = text.lower() # Lower case
            text = text.strip() # rid of leading/trailing whitespace with the following
            text = re.compile('<.*?>').sub('', text) # Remove HTML tags/markups:
            text = re.compile('[%s]' % re.escape(string.punctuation)).sub(' ', text) # Replace punctuation with space
            text = re.sub('\s+', ' ', text) # Remove extra space and tabs
            # remove stop words
            stop_words = ["a", "an", "the", "this", "that", "is", "it", "to", "and"]
            filtered_sentence = []
            words = text.split(" ")
            for w in words:
                if w not in stop_words:
                    filtered_sentence.append(w)
            text = " ".join(filtered_sentence)
            # Credentials & setup
            os.environ["EAI_USERNAME"] = 'edimaudo@gmail.com'
            os.environ["EAI_PASSWORD"] = '3XpeRtA!L0g1n'
            from expertai.nlapi.cloud.client import ExpertAiClient
            client = ExpertAiClient()
            language = 'en'
            try:
                output_keyword = client.specific_resource_analysis(body={"document": {"text": text}}, params={'language': language, 'resource': 'relevants'})
                output_named_entity = client.specific_resource_analysis(body={"document": {"text": text}}, params={'language': language, 'resource': 'entities'})
                output_sentiment = client.specific_resource_analysis(body={"document": {"text": text}}, params={'language': language, 'resource': 'sentiment'})
                output_emotional_trait = client.classification(body={"document": {"text": text}}, params={'taxonomy': taxonomy, 'language': language})
                output_behavior = client.classification(body={"document": {"text": text}}, params={'taxonomy': taxonomy, 'language': language})
                # Document analysis 
                st.subheader("Document Analysis")
                st.write("Keyphrase extraction")
                st.write("Named Entity recognition")
                st.write("Sentiment analysis")
                # Document classification
                st.subheader("Document Classification")
                st.write("Emotional Traits")
                st.write("Behavorial traits")   
            except:
                st.write("Issue with Retrieving data from the API")


    

    
