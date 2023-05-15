# Libraries
import streamlit as st
import whois
import validators
from validators import ValidationFailure
import requests
import json
import pangea.exceptions as pe
from pangea.config import PangeaConfig
from pangea.services import DomainIntel
import os
from config import *
from ipaddress import ip_address, IPv4Address

APP_NAME = 'Mesh Intelligence'
URL_NAME = "URL Insights"
DOMAIN_NAME = "Domain Insights"
IP_NAME = "IP Inisghts"

st.set_page_config( 
    page_title=APP_NAME,
)

@st.cache_resource
def generate_api_result(link, link_type):
    headers = {'Authorization': AUTHORIZATION,'Content-Type': 'application/json',}
    if link_type == 'URL':
        json_data = {'provider': 'crowdstrike','url': link,}
        response = requests.post(URL_LINK, headers=headers,json=json_data,)
    elif link_type == 'Domain':
        json_data = {'provider': 'domaintools','domain': link,}
        response = requests.post(DOMAIN_LINK, headers=headers,json=json_data,)
    elif link_type == 'IP':
        json_data = {'provider': 'crowdstrike','ip': link,}
        response = requests.post(IP_LINK, headers=headers,json=json_data,)
    return response