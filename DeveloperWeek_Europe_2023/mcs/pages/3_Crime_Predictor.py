# Libraries
from utils import * 
st.title(APP_NAME)

# ML model for predicting type of crime 3 days
#MONTH
#DAY OF WEEK
#Hour of day
#NEIGHBORHOOD
#PREMISE TYPE

model_data = df[['OCC_MONTH','OCC_DOW','OCC_HOUR',
               'PREMISES_TYPE','NEIGHBOURHOOD_158','MCI_CATEGORY']]

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
    # load model
    saved_final_ridge = load_model('Final ridge')
    # Prediction
    new_prediction = predict_model(saved_final_ridge, data=info_df)
    rating = new_prediction['Label'][0]
    st.metric("Predicted Rating is : ",rating)

with st.sidebar:
    nlp_product_choice = st.selectbox("Product",nlp_product_list)
    nlp_month_choice = st.selectbox("Month",nlp_month_list)
    nlp_year_choice = st.selectbox('Year', [2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022])
    nlp_price_choice = st.slider('Price', 100, 2500, 50)
    nlp_category_choice = st.selectbox("Category",nlp_product_cat_list)
    nlp_retailer_choice = st.selectbox("Retailer",nlp_retailer_list)
    nlp_manufacturer_choice = st.selectbox("Manufacturer",nlp_manufacturer_list)
    nlp_city_choice = st.selectbox("City",nlp_retailer_city_list)
    nlp_occupation_choice = st.selectbox("Occupation",nlp_occupation_list)
    nlp_gender_choice = st.selectbox("Gender",nlp_gender_list)
    nlp_age_choice = st.slider('Age', 18,70 , 18)

clicked = st.button("Predict Rating")
if clicked:
    model_data = model_df[['ProductCategory','ProductPrice',
               'RetailerName','RetailerCity','RetailerState',
               'ManufacturerName','UserAge','UserGender','UserOccupation',
               'Month','Year','ReviewRating']]
    # Recode
    model_data["ProductCategory"] = model_data["ProductCategory"].astype('category')
    model_data["RetailerName"] = model_data["RetailerName"].astype('category')
    model_data["RetailerCity"] = model_data["RetailerCity"].astype('category')
    model_data["ManufacturerName"] = model_data["ManufacturerName"].astype('category')
    model_data["UserGender"] = model_data["UserGender"].astype('category')
    model_data["UserOccupation"] = model_data["UserOccupation"].astype('category')
    model_data["Month"] = model_data["Month"].astype('category')

    model_data["ProductCategory_cat"] = model_data["ProductCategory"].cat.codes
    model_data["RetailerName_cat"] = model_data["RetailerName"].cat.codes
    model_data["RetailerCity_cat"] = model_data["RetailerCity"].cat.codes
    model_data["ManufacturerName_cat"] = model_data["ManufacturerName"].cat.codes
    model_data["UserGender_cat"] = model_data["UserGender"].cat.codes
    model_data["UserOccupation_cat"] = model_data["UserOccupation"].cat.codes
    model_data["Month_cat"] = model_data["Month"].cat.codes