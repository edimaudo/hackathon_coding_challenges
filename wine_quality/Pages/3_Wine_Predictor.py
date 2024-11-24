# Libraries
from utils import * 
st.title(APP_NAME)

col1, col2 = st.columns([3, 1]) 
with col2:
	clicked = st.button("Run Wine Quality Prediction")
	with st.expander(APP_FILTERS):
		fixed_acidity = st.slider("Fixed Acidity", 1, 15, 0.5)
		volatile_acidity = st.slider("Volatile Acidity", 0.05, 1.5, 0.01)	
		citric_acid	= st.slider("Citric Acid", 0.5, 2, 0.05)
		residual_sugar = st.slider("Residual Sugar", 0.5, 70, 0.05)
		chlorides = st.slider("Chlorides", 0.005, 0.4, 0.05)
		free_sulfur_dioxide	= st.slider("Free Sulfur Dioxide", 2, 300, 5)
		total_sulfur_dioxide = st.slider("Total Sulfur Dioxide", 5, 500, 5)	
		density	= st.slider("Density", 0.95, 1.5, 0.001)
		pH	= st.slider("pH", 2.5, 5, 0.05)
		sulphates = st.slider("Sulphates", 0.2, 1.5, 0.05)
		alcohol = st.slider("Alcohol", 7, 14, 0.05)

