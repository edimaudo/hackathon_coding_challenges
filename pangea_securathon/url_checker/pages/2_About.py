# Libraries
import streamlit as st
from utils import * 
st.title(APP_NAME)

st.markdown("Built this app to check for fraudulent URLS.  I once clicked a fraudulent link that took over one of my devices. I would like to prevent this from happening to anyone. ")
st.markdown("""
The app uses Pangea file and domain APIs.  The APIs review the URL and gives it a verdict.
There are two options checking only a URL or uploading a file and checking the URLs in the file.
It also gives some stats about the urls.
""")