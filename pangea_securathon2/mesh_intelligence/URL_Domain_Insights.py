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

def is_string_a_domain(domain_string):
    domain_string.strip()
    result = validators.domain(domain_string)
    if isinstance(result, ValidationFailure):
        return False
    return result

@st.cache_resource
def generate_api_result(link, link_type):
    headers = {'Authorization': AUTHORIZATION,'Content-Type': 'application/json',}
    if link_type == 'URL':
        json_data = {'provider': 'crowdstrike','url': link,}
        response = requests.post(URL_LINK, headers=headers,json=json_data,)
    else:
        json_data = {'provider': 'domaintools','domain': link,}
        response = requests.post(DOMAIN_LINK, headers=headers,json=json_data,)
    return response

def generate_whois_result(URL):
    w = whois.whois(URL)
    return w

def url_analysis():
    pass

def domain_analysis():
    pass
    


def main():
    choice = st.radio("Select the analysis",('URL', 'Domain'))
    if choice == 'URL':
        pass
    else:
        pass

    

if __name__ == main():
    main()
    




