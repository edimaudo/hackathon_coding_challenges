from utils import * 
from config import *

st.title(APP_NAME)
st.subheader(IP_NAME)

def ip_analysis():
    ip_text = st.text_input('Enter an IP Address', '', placeholder = '') 
    ip_button = st.button('Check IP')

    if ip_button:
        pass

def main():
    ip_analysis()

if __name__ == main():
    main()