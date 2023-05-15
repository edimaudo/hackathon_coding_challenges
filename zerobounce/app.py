# Libraries
import streamlit as st
import requests
import json
import os
import pandas as pd
from validate_email_address import validate_email


APP_NAME = 'Email Intelligence'

st.set_page_config( 
    page_title=APP_NAME,
)

from validate_email_address import validate_email
isExists = validate_email('alesiaconover@cox.net', verify=True)
st.write(isExists)


# alesiaconover@cox.net	valid
# magormley1@cox.net	invalid
# lwoodard@cox.net	invalid
# stondreau@cox.net	valid
# lhutfles@cox.net	valid
# bolivarfamily@cox.net	invalid
# ageecrew@cox.net	invalid
# 0cimei@cox.net	invalid
# 123aloop1@cox.net	invalid
# 1350tw@cox.net	invalid
# 1slgoodman62@cox.net	invalid
# 187thepigs@cox.net	invalid
# 2katz2meny@cox.net	invalid
# jkaine1994@cox.net	valid
# 3boyzmom@cox.net	valid