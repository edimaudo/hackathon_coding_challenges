# Libraries
import streamlit as st
import pandas as pd
import plotly.express as px
import os, os.path
import sklearn

st.title('Kiva Insights')

# Load data
@st.cache
def load_data():
    data = pd.read_csv(DATA_URL)
    return data
DATA_URL = "loans.csv"
df = load_data()

st.header("About")
with st.expander(" "):
    st.write("""
    The application leverages Kiva's data snapshot to build financial tools that would help further poverty alleviation and financial inclusion.  The application focuses on two key areas:
    - Fund distribution: How might we optimize fund distribution to borrowers?
    - Loan impact: How might we show the impact of the loans?
    """)

st.header("Data Overview")
with st.expander(" "):
    st.subheader("Here is a preview of the data")
    st.dataframe(df.head(35))

st.header("Data Summary")




