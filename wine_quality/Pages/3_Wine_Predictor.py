from utils import * 
st.title(APP_NAME)

st.subheader(PREDICTION_NAME_HEADER)

columns_data = ['fixed acidity',	
'volatile acidity',	
'citric acid',	
'residual sugar',	
'chlorides',	
'free sulfur dioxide',	
'total sulfur dioxide',	
'density',	
'pH',	
'sulphates',	
'alcohol']

col1, col2 = st.columns([3, 1]) 
with col2:
	clicked = st.button("Run Prediction")
	with st.expander(APP_FILTERS):
		wine_type = st.radio("Wine Type",['White Wine','Red Wine'])
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

with col1:
    st.header(PREDICTION_NAME_HEADER)
    # Model information
    model_data = [fixed_acidity,volatile_acidity,citric_acid,residual_sugar,chlorides,free_sulfur_dioxide,total_sulfur_dioxide,density,pH,sulphates,alcohol]
    # scale data
    df_scale = model_data
    scaler = preprocessing.MinMaxScaler()
	df_scale = scaler.fit_transform(df_scale)
	df_scale = pd.DataFrame(df_scale)
	df_scale.reset_index(drop=True, inplace=True)

    if clicked:
    	# Load model
    	if wine_type == "White Wine":
        	saved_model = load_model('white_wine')
        else:
        	saved_model = load_model('red_wine')

        info_df = pd.DataFrame(columns = columns_data,index = ['a'])
    	info_df.loc['a'] = df_scale
        # Prediction
        new_prediction = predict_model(saved_model, data=info_df)
        wine_quality_output = new_prediction['Label'][0]
        st.write("Based on your selection")
        st.metric("The Predicted Wine Quality is: ",wine_quality_output)


