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

@st.cache_resource
def generate_api_result(link_type, input_type):
    headers = {'Authorization': AUTHORIZATION,'Content-Type': 'application/json',}

    if input_type == 'URL':
        json_data = {'provider': 'crowdstrike','url': link_type,}
        response = requests.post(URL_LINK, headers=headers,json=json_data,)
    else:
        json_data = {'provider': 'domaintools','domain': link_type,}
        response = requests.post(DOMAIN_LINK, headers=headers,json=json_data,)

    return response

@st.cache_resource
def generate_whois_result(URL):
    w = whois.whois(URL)
    return w

def url_analysis():
    url_text = st.text_input('Enter a URL, press enter and then click the Check URL button', '', 
    placeholder = 'Enter a url like this -> http://www.example.com') 
    url_button = st.button('Check URL')
    if url_button:
        if is_string_a_url(url_text):
            url_output = generate_api_result(url_text,'URL')
            with st.container():
                col1, col2 = st.columns(2)
                url_output_data = url_output.json()
                with col1:
                    st.metric("Status",str(output_data['status']))
                with col2:
                    st.metric("URL Malicious Intent",str(url_output_data['result']['data']['verdict']))
            st.write(" ")
            whois_output = generate_whois_result(url_text)
            domain_output = generate_api_result(str(whois_output['domain_name']),'Domain')
            col3, col4 = st.columns(2)
            with col3:
                st.metric("URL Creation Date",str(whois_output['creation_date']) )
                st.metric("URL Expiration Date",str(whois_output['expiration_date']))
            with col4:
                st.metric("Domain Name",str(whois_output['domain_name']))
                st.metric("Domain Malicious Intent", )
                st.write("Name Servers")
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
    




