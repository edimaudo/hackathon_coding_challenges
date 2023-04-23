from utils import * 
from config import *

st.title(APP_NAME)

def is_string_a_url(url_string):
    url_string.strip()
    result = validators.url(url_string)
    if isinstance(result, ValidationFailure):
        return False
    return result

def generate_api_result(URL):
    headers = {
        'Authorization': AUTHORIZATION,
        'Content-Type': 'application/json',
    }

    json_data = {
        'provider': 'crowdstrike',
        'url': URL,
    }

    response = requests.post(
        'https://url-intel.' + os.getenv(DOMAIN, '') + '/v1/reputation',
        headers=headers,
        json=json_data,
    )
    output = response

def generate_whois_result(URL):
    w = whois.whois(URL)
    return w

def url_option():
    url_text = st.text_input('Enter a URL, press enter and then click the Check URL button', '', 
    placeholder = 'Enter a url like this -> http://www.example.com') 
    url_button = st.button('Check URL')
    if url_button:
        if is_string_a_url(url_text):
            api_output = generate_api_result(url_text)
            api_output = json.load(api_output)
            st.write(api_output)
            whois_output = generate_whois_result(url_text)
            st.write("URL Stats.")
            st.write(" ")
            col1, col2 = st.columns(2)
            with col1:
                st.metric("Creation Date",str(whois_output['creation_date']) )
                st.metric("Expiration Date",str(whois_output['expiration_date']))
            with col2:
                st.metric("Domain Name",str(whois_output['domain_name']))
                st.write("Name Servers")
                for server in whois_output['name_servers']:
                        st.write("- ", str(server))
        else:
            st.error('Please enter a valid URL', icon="🚨")


def main():
    url_option()


if __name__ == main():
    main()
    




