import config
from utils import *

st.set_page_config(
    page_title=" 🌍Planet Heater",
    page_icon="🌍",
)

st.title(APP_NAME)
st.header(PLANET_HEATER_HEADER)

st.markdown(
    """
    As extreme weather intensifies, who contributes the most to the crisis? This story breaks down emissions across regions and industries to show where the heat is truly coming from.
    """
)

with st.sidebar:
    region_selection = st.multiselect('Region',continent,default=None,placeholder=None)
    gas_type_selection = st.multiselect('Gas Type',gas_type,default=None,placeholder=None)
    industry_selection = st.multiselect('Industry',industry,default=None,placeholder=None)