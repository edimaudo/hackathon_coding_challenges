# Libraries
from utils import * 
st.title(APP_NAME)
st.header(PREDICTION_NAME)

col1, col2 = st.columns([3, 1]) 
with col2:
    clicked = st.button("Run Prediction")
    with st.expander(APP_FILTERS):
        month_options = st.selectbox('Month',MONTH)
        dow_options = st.selectbox('Day of Week',DAY_OF_WEEK)
        hour_options = st.selectbox('Hour',HOUR)
        premises_options = st.selectbox('Premises Type',PREMISES_TYPE)
        neighbourhood_options = st.selectbox('Neighborhoods',NEIGHBORHOOD)
    

with col1:
    # Model information
    model_data = df[['OCC_MONTH','OCC_DOW','OCC_HOUR','PREMISES_TYPE','NEIGHBOURHOOD_158','MCI_CATEGORY']]

    # Categorize data
    model_data["OCC_MONTH"] = model_data["OCC_MONTH"].astype('category')
    model_data["OCC_DOW"] = model_data["OCC_DOW"].astype('category')
    model_data["PREMISES_TYPE"] = model_data["PREMISES_TYPE"].astype('category')
    model_data["NEIGHBOURHOOD_158"] = model_data["NEIGHBOURHOOD_158"].astype('category')
    model_data["MCI_CATEGORY"] = model_data["MCI_CATEGORY"].astype('category')

    model_data["OCC_MONTH_cat"] = model_data["OCC_MONTH"].cat.codes
    model_data["OCC_DOW_cat"] = model_data["OCC_DOW"].cat.codes
    model_data["PREMISES_TYPE_cat"] = model_data["PREMISES_TYPE"].cat.codes
    model_data["NEIGHBOURHOOD_158_cat"] = model_data["NEIGHBOURHOOD_158"].cat.codes
    model_data["MCI_CATEGORY_cat"] = model_data["MCI_CATEGORY"].cat.codes

    model_info = model_data[(model_data.OCC_MONTH == month_options)]
    model_info.reset_index(drop=True, inplace=True)
    month = model_info['OCC_MONTH_cat'][0]

    model_info = model_data[(model_data.OCC_DOW == dow_options)]
    model_info.reset_index(drop=True, inplace=True)
    dow = model_info['OCC_DOW_cat'][0]

    model_info = model_data[(model_data.OCC_HOUR == hour_options)]
    model_info.reset_index(drop=True, inplace=True)
    hour = model_info['OCC_HOUR'][0]

    model_info = model_data[(model_data.PREMISES_TYPE == premises_options)]
    model_info.reset_index(drop=True, inplace=True)
    premise = model_info['PREMISES_TYPE_cat'][0]

    model_info = model_data[(model_data.NEIGHBOURHOOD_158 == neighbourhood_options)]
    model_info.reset_index(drop=True, inplace=True)
    neighbourhood = model_info['NEIGHBOURHOOD_158_cat'][0]



    if clicked:
        info_df = pd.DataFrame(columns = ['OCC_MONTH_cat','OCC_DOW_cat','OCC_HOUR','PREMISES_TYPE_cat','NEIGHBOURHOOD_158_cat'],index = ['a'])
        info_df.loc['a'] = [month,dow,hour, premise, neighbourhood]
        # Load model
        saved_final_lightgbm = load_model('Final lightgbm')
        # Prediction
        new_prediction = predict_model(saved_final_lightgbm, data=info_df)
        crime_category = new_prediction['Label'][0]
        if crime_category == 0:
            crime_output = 'Assault'
        elif crime_category == 1:
            crime_output = 'Auto Theft'
        elif crime_category == 2:
            crime_output = 'Break & Enter'
        elif crime_category == 3:
            crime_output = 'Robbery'
        else:
            crime_output = 'Theft Over'

        st.write("Based on the metrics selected")
        st.metric("The Predicted Crime is : ",crime_output)

