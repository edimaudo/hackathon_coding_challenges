import streamlit as st
import pandas as pd
import plotly.express as px

st.title('OTF Charity Insights')
df = st.session_state['df']