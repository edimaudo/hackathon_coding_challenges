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
    pass
    


def main():
    domain_analysis()

if __name__ == main():
    main()
    




