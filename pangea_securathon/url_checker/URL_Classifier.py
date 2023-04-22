from utils import * 

st.title(APP_NAME)

def is_string_a_url(url_string):
    url_string.strip()
    result = validators.url(url_string)
    if isinstance(result, ValidationFailure):
        return False
    return result

def generate_api_result(URL):
    pass

def generate_whois_result(URL):
    w = whois.whois(URL)
    return w

def url_option():
    url_text = st.text_input(URL_TEXT, '', placeholder = 'Enter a url like this -> http://www.example.com') 
    url_option_button = st.button('Check URL')
    if url_option_button:
        if is_string_a_url(url_text):
            check_api(url_text)
            output = generate_whois_result(url_text)
            st.write("URL Stats.")
            st.write(" ")
            col1, col2 = st.columns(2)
            with col1:
                st.metric("Creation Date",str(output['creation_date']) )
                st.metric("Expiration Date",str(output['expiration_date']))
            with col2:
                st.metric("Domain Name",str(output['domain_name']))
                st.write("Name Servers")
                for server in output['name_servers']:
                        st.write("- ", str(server))
        else:
            st.error('Please enter a valid URL', icon="🚨")


def main():
    url_option()


if __name__ == main():
    main()
    




