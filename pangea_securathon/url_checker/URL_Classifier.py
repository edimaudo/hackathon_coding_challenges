import streamlit as st
from utils import * 

st.title(APP_NAME)

st.header("")

def url_option():
    url_text = st.text_input(URL_TEXT, '') 

    url_option_button = st.button('Check URL')
    if url_option_button:
        # check if a URL is entered
        if len(url_text) < 1:
            st.error('Please enter a URL', icon="🚨")
        # check 


def main():
    url_option()


if __name__ == main():
    main()
    




