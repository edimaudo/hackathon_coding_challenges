# Libraries
from utils import * 
st.title(APP_NAME)

with st.expander(APP_FILTERS): 
    month_options = st.multiselect('Month',MONTH,default=MONTH)
    dow_options = st.multiselect('Day of Week',DAY_OF_WEEK,default=DAY_OF_WEEK)
    hour_options = st.multiselect('Hour',HOUR,default=HOUR)
    premises_options = st.multiselect('Premises Type',PREMISES_TYPE,default =PREMISES_TYPE)
    neighbourhood_options = st.multiselect('Neighborhoods',NEIGHBORHOOD,default=NEIGHBORHOOD[0:10])

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

model_data = model_data[['OCC_MONTH_cat','OCC_DOW_cat','OCC_HOUR','PREMISES_TYPE_cat',
                         'NEIGHBOURHOOD_158_cat','MCI_CATEGORY_cat']]

model_info = model_data[(model_data.ProductCategory == nlp_category_choice)]
model_info.reset_index(drop=True, inplace=True)
product_category = model_info['ProductCategory_cat'][0]

    model_info = model_data[(model_data.RetailerName == nlp_retailer_choice)]
    model_info.reset_index(drop=True, inplace=True)
    retailer = model_info['RetailerName_cat'][0]

    model_info = model_data[(model_data.RetailerCity == nlp_city_choice)]
    model_info.reset_index(drop=True, inplace=True)
    city = model_info['RetailerCity_cat'][0]

    model_info = model_data[(model_data.ManufacturerName == nlp_manufacturer_choice)]
    model_info.reset_index(drop=True, inplace=True)
    manufacturer = model_info['ManufacturerName_cat'][0]

    model_info = model_data[(model_data.UserGender == nlp_gender_choice)]
    model_info.reset_index(drop=True, inplace=True)
    gender = model_info['UserGender_cat'][0]

    model_info = model_data[(model_data.UserOccupation == nlp_occupation_choice)]
    model_info.reset_index(drop=True, inplace=True)
    occupation = model_info['UserOccupation_cat'][0]

    model_info = model_data[(model_data.Month == nlp_month_choice)]
    model_info.reset_index(drop=True, inplace=True)
    month = model_info['Month_cat'][0]
    
    info_df = pd.DataFrame(columns = ['ProductCategory_cat','ProductPrice','RetailerName_cat','RetailerCity_cat',
    'ManufacturerName_cat','UserAge','UserGender_cat','UserOccupation_cat','Month_cat','Year'],index = ['a'])
    info_df.loc['a'] = [product_category,nlp_price_choice,retailer,city,
    manufacturer,nlp_age_choice,gender,occupation,month,nlp_year_choice]


clicked = st.button("Run Prediction")
if clicked:
    # Load model
    saved_final_lightgbm = load_model('Final lightgbm')
    # Prediction
    new_prediction = predict_model(saved_final_lightgbm, data=info_df)
    crime_category = new_prediction['Label'][0]
    #st.metric("Predicted Crime is : ",crime_category)
    #st.table(crime_category)