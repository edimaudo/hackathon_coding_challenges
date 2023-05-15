from utils import * 
from config import *

st.title(APP_NAME)
st.subheader(IP_NAME)

def validIPAddress(IP) :
    try:
        return "IPv4" if type(ip_address(IP)) is IPv4Address else "IPv6"
    except ValueError:
        return "Invalid"

def ip_analysis():
    ip_text = st.text_input('Enter an IP Address', '', placeholder = 'Enter your IP like this --> 123.0.0.7 or abcd:ef::42:1') 
    ip_button = st.button('Check IP')

    if ip_button:
        ip_type = validIPAddress(ip_text)
        if ip_type != "Invalid":
            ip_output = generate_api_result(ip_text,'IP')
            ip_output_data = ip_output.json()
            with st.container():
                col1, col2 = st.columns(2)
                with col1:
                    st.metric("Status",str(ip_output_data['status']))
                with col2:
                    st.metric("IP Malicious Intent",str(ip_output_data['result']['data']['verdict']))
        else:
            st.error('Please enter a valid IP', icon="🚨")

        

def main():
    ip_analysis()

if __name__ == main():
    main()