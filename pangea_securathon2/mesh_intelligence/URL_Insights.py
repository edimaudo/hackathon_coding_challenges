from utils import * 
from config import *

st.title(APP_NAME)
st.subheader(URL_NAME)

def is_string_a_url(url_string):
    url_string.strip()
    result = validators.url(url_string)
    if isinstance(result, ValidationFailure):
        return False
    return result

def generate_whois_result(URL):
    w = whois.whois(URL)
    return w

def url_analysis():
    url_text = st.text_input('Enter a URL , press enter and then click the Check URL button', '', 
    placeholder = 'Enter a url like this -> http://www.example.com') 
    url_button = st.button('Check URL')

    if url_button:
        if is_string_a_url(url_text):
            url_output = generate_api_result(url_text,'URL')
            url_output_data = url_output.json()
            whois_output = generate_whois_result(url_text)
            with st.container():
                col1, col2 = st.columns(2)
                with col1:
                    st.metric("Status",str(url_output_data['status']))
                with col2:
                    st.metric("URL Malicious Intent",str(url_output_data['result']['data']['verdict']))
            st.write(" ")
            col3, col4 = st.columns(2)
            with col3:
                st.metric("Creation Date",str(whois_output['creation_date']) )
                st.metric("Expiration Date",str(whois_output['expiration_date']))
            with col4:
                st.metric("Domain Name",str(whois_output['domain_name']))
                st.write("Server Names")
                if whois_output['name_servers'] is None:
                    st.write("None")
                elif len(whois_output['name_servers']) < 2:
                    st.write(str(server))
                else:
                    for server in whois_output['name_servers']:
                        st.write("- ", str(server))
        else:
            st.error('Please enter a valid URL', icon="🚨")


def main():
    url_analysis()

if __name__ == main():
    main()
    




