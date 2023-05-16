from utils import * 
from config import *

st.title(APP_NAME)
st.subheader(DOMAIN_NAME)

def is_string_a_domain(domain_string):
    domain_string.strip()
    result = validators.domain(domain_string)
    if isinstance(result, ValidationFailure):
        return False
    return result

def domain_analysis():
    domain_text = st.text_input('Enter a Domain , press enter and then click the Check Domain button', '', 
    placeholder = 'Enter a domain like this -> example.com') 
    domain_button = st.button('Check Domain')

    if domain_button:
        if is_string_a_domain(domain_text):
            domain_output = generate_api_result(domain_text,'Domain')
            domain_output_data = domain_output.json()
            with st.container():
                col1, col2 = st.columns(2)
                with col1:
                    st.metric("Status",str(domain_output_data['status']))
                with col2:
                    st.metric("URL Malicious Intent",str(domain_output_data['result']['data']['verdict']))
            st.write(" ")
        else:
            st.error('Please enter a valid Domain', icon="🚨")
    


def main():
    domain_analysis()

if __name__ == main():
    main()
    




