# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import warnings
import numpy as np
from datetime import datetime
import random
warnings.simplefilter(action='ignore', category=FutureWarning)
import math 
import re, string

st.title('WebSocialytics Insights')

# Load data
@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "CustomerReviews2000.csv"
df = load_data()

nlp_retailer_list = df['RetailerName'].unique()
nlp_retailer_list  = nlp_retailer_list.astype('str')
nlp_retailer_list.sort()

nlp_manufacturer_list = df['ManufacturerName'].unique()
nlp_manufacturer_list = nlp_manufacturer_list.astype('str')
nlp_manufacturer_list.sort()

nlp_product_cat_list = df['ProductCategory'].unique()
nlp_product_cat_list  = nlp_product_cat_list.astype('str')
nlp_product_cat_list.sort()

nlp_retailer_city_list = df['RetailerCity'].unique()
nlp_retailer_city_list  = nlp_retailer_city_list.astype('str')
nlp_retailer_city_list.sort()

nlp_rating_list = df['ReviewRating'].unique()
nlp_rating_list  = nlp_rating_list.astype('int')
nlp_rating_list.sort()

st.header("Text Analysis of Reviews")
nlp_manufacturer_choice = st.multiselect("Manufacturer",nlp_manufacturer_list,['Samsung','Microsoft'])
nlp_retailer_choice = st.multiselect("RetailerName",nlp_retailer_list, ['Bestbuy','Walmart'])
nlp_city_choice = st.multiselect("City",nlp_retailer_city_list, ['Los Angeles','San Francisco'])
nlp_product_cat_choice = st.multiselect("Product Category",nlp_product_cat_list , ['Tablet'])
nlp_rating_choice = st.multiselect("Ratings",nlp_rating_list, [4,5])

# ProductModelName	ProductCategory	ProductPrice	RetailerName	RetailerZip	RetailerCity	RetailerState	ProductOnSale	ManufacturerName	ManufacturerRebate	UserID	UserAge	UserGender	UserOccupation	ReviewRating	ReviewDate	ReviewText	

nlp_analysis = df[(df.ManufacturerName.isin(nlp_manufacturer_choice)) & 
                (df.RetailerName.isin(nlp_retailer_choice)) & 
                (df.RetailerCity.isin(nlp_city_choice)) & 
                (df.ProductCategory.isin(nlp_product_cat_choice)) &
                (df.ReviewRating.isin(nlp_rating_choice))]

st.write("Reviews")
if nlp_analysis.empty:
    st.write("No data Available! Please try another combination from the dropdowns")
else:
    n = 30
    if nlp_analysis.shape[0] < 30:
        n = nlp_analysis.shape[0]
        st.dataframe(nlp_analysis['ReviewText'][:n])
    run_nlp = st.button("Run Text Analysis")
    if run_nlp and not nlp_analysis.empty:
        # Convert review into one large paragraph
        text = '. '.join(nlp_analysis['ReviewText'][:n])
        # Text cleanup
        text = text.lower() # Lower case
        text = text.strip() # rid of leading/trailing whitespace with the following
        text = re.compile('<.*?>').sub('', text) # Remove HTML tags/markups:
        text = re.compile('[%s]' % re.escape(string.punctuation)).sub(' ', text) # Replace punctuation with space
        text = re.sub('\s+', ' ', text) # Remove extra space and tabs
        # Remove stop words
        stop_words = ["a", "an", "the", "this", "that", "is", "it", "to", "and"]
        filtered_sentence = []
        words = text.split(" ")
        for w in words:
            if w not in stop_words:
                filtered_sentence.append(w)
                text = " ".join(filtered_sentence)
        # ExpertAI Credentials
        os.environ["EAI_USERNAME"] = 'edimaudo@gmail.com'
        os.environ["EAI_PASSWORD"] = '3XpeRtA!L0g1n'
        from expertai.nlapi.cloud.client import ExpertAiClient
        client = ExpertAiClient()
        language = 'en'
        try:
            # Document analysis 
            output_keyword = client.specific_resource_analysis(body={"document": {"text": text}}, 
            params={'language': language, 'resource': 'relevants'})
            output_named_entity = client.specific_resource_analysis(body={"document": {"text": text}},
            params={'language': language, 'resource': 'entities'})
            output_sentiment = client.specific_resource_analysis(body={"document": {"text": text}}, 
            params={'language': language, 'resource': 'sentiment'})
            output_emotional_trait = client.classification(body={"document": {"text": text}}, 
            params={'taxonomy': 'emotional-traits', 'language': language})
            output_behavior = client.classification(body={"document": {"text": text}}, 
            params={'taxonomy': 'behavioral-traits', 'language': language})
            st.subheader("Document Analysis")
            st.markdown("**Keyphrase extraction**")
            for lemma in output_keyword.main_lemmas:
                st.write("- " + lemma.value)
                st.write(" ")
            st.markdown("**Named Entity recognition**")
            for entity in output_named_entity.entities:
                st.write(f' - {entity.lemma:{50}} {entity.type_:{10}}')
                st.write(" ")
            st.markdown("**Sentiment analysis**")
            if (output_sentiment.sentiment.overall > 0):
                st.write("Positive Sentiment: " + str(output_sentiment.sentiment.overall))
                st.write("Negative sentiment: " + str(output_sentiment.sentiment.overall))
            # Document classification
            st.subheader("Document Classification")
            st.markdown("**Emotional Traits**")
            for category in output_emotional_trait.categories:
                st.write("- ", category.hierarchy[0], " -> ", category.hierarchy[1])
                st.write(" ")
            st.markdown("**Behavorial traits**")   
            for category in output_behavior.categories:
                st.write("- ", category.hierarchy[0], ": ", category.hierarchy[1]," -> ", category.hierarchy[2])
        except:
            st.write(" ")
            st.error("Issue retrieving data from the API", icon="🚨")