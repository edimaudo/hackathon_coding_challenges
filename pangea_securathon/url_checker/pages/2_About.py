from utils import * 
st.title(APP_NAME)

st.markdown("Built this app to check for fraudulent URLS.  I once clicked a fraudulent link that took over one of my devices. I would like to prevent this from happening to anyone. ")
st.markdown("""
The app uses Pangea file and domain APIs.  The APIs review the URL and gives it a verdict.
It also gives some stats about the urls.
""")