from utils import * 

st.title(APP_NAME)

def check_api(URL):
    pass

def check_url(URL):
    pass

def check_whois(URL):
    pass

def url_option():
    url_text = st.text_input(URL_TEXT, '') 

    url_option_button = st.button('Check URL')
    if url_option_button:
        # check if a URL is entered
        if len(url_text) < 1:
            st.error('Please enter a URL', icon="🚨")
        # check for valid URL


def main():
    url_option()


if __name__ == main():
    main()
    




