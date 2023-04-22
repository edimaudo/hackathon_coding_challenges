from utils import * 

st.title(APP_NAME)

def is_string_an_url(url_string):
    url_string.strip()
    result = validators.url(url_string)
    if isinstance(result, ValidationFailure):
        return False
    return result

def check_api(URL):
    pass

def check_whois(URL):
    pass

def url_option():
    url_text = st.text_input(URL_TEXT, '') 
    url_option_button = st.button('Check URL')
    if url_option_button:
        # check if a URL is entered
        #if len(url_text) < 1:
        #    st.error('Please enter a URL', icon="🚨")
        # check for valid URL
        if is_string_an_url(url_text):
            check_api(url_text)
        else:
            st.error('Please enter a valid URL', icon="🚨")


def main():
    url_option()


if __name__ == main():
    main()
    




