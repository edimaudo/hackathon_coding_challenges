from utils import * 
from config import *

st.title(APP_NAME)
st.header(APP_SENTIMENT_ANALYSIS)

with st.expander("Text analysis"):
    nlp_month_choice = st.selectbox("Month",nlp_month_list, index=5)
    nlp_year_choice = st.selectbox("Year",nlp_year_list,index=3)
    nlp_app_choice = st.selectbox("Companion App",nlp_app_list,key="nlp",index=3)
    nlp_score_choice = st.selectbox("Score",nlp_score_list, index=0)
    nlp_analysis = df_analysis[(df_analysis.app == nlp_app_choice) & (df_analysis.Year == nlp_year_choice) 
    & (df_analysis.Month == nlp_month_choice) & (df_analysis.score == nlp_score_choice)]
    st.write("Reviews")
    if nlp_analysis.empty:
        st.write("No data Available! Please try another combination from the dropdowns")
    else:
        n = 30
        if nlp_analysis.shape[0] < 30:
            n = nlp_analysis.shape[0]
        st.dataframe(nlp_analysis['Review'][:n])
    run_nlp = st.button("Run NLP Analysis")
    if run_nlp and not nlp_analysis.empty:
            # Convert review into one large paragraph
            text = '. '.join(nlp_analysis['Review'][:n])
            # Text cleanup
            text = text.lower() # Lower case
            text = text.strip() # rid of leading/trailing whitespace with the following
            text = re.compile('<.*?>').sub('', text) # Remove HTML tags/markups:
            text = re.compile('[%s]' % re.escape(string.punctuation)).sub(' ', text) # Replace punctuation with space
            text = re.sub('\s+', ' ', text) # Remove extra space and tabs
            # Remove stop words
            stop_words = ["a", "an", "the", "this", "that", "is", "it", "to", "and"]
            filtered_sentence = []
            words = text.split(" ")
            for w in words:
                if w not in stop_words:
                    filtered_sentence.append(w)
            text = " ".join(filtered_sentence)

            client = ExpertAiClient()
            language = 'en'
            try:
                # Document analysis 
                output_keyword = client.specific_resource_analysis(body={"document": {"text": text}}, 
                params={'language': language, 'resource': 'relevants'})
                output_named_entity = client.specific_resource_analysis(body={"document": {"text": text}},
                params={'language': language, 'resource': 'entities'})
                output_sentiment = client.specific_resource_analysis(body={"document": {"text": text}}, 
                params={'language': language, 'resource': 'sentiment'})
                output_emotional_trait = client.classification(body={"document": {"text": text}}, 
                params={'taxonomy': 'emotional-traits', 'language': language})
                output_behavior = client.classification(body={"document": {"text": text}}, 
                params={'taxonomy': 'behavioral-traits', 'language': language})
                st.subheader("Document Analysis")
                st.markdown("**Keyphrase extraction**")
                for lemma in output_keyword.main_lemmas:
                    st.write("- " + lemma.value)
                st.write(" ")
                st.markdown("**Named Entity recognition**")
                for entity in output_named_entity.entities:
                    st.write(f' - {entity.lemma:{50}} {entity.type_:{10}}')
                st.write(" ")
                st.markdown("**Sentiment analysis**")
                if (output_sentiment.sentiment.overall > 0):
                    st.write("Positive Sentiment: " + str(output_sentiment.sentiment.overall))
                st.write("Negative sentiment: " + str(output_sentiment.sentiment.overall))
                # Document classification
                st.subheader("Document Classification")
                st.markdown("**Emotional Traits**")
                for category in output_emotional_trait.categories:
                    st.write("- ", category.hierarchy[0], " -> ", category.hierarchy[1])
                st.write(" ")
                st.markdown("**Behavorial traits**")   
                for category in output_behavior.categories:
                    st.write("- ", category.hierarchy[0], ": ", category.hierarchy[1]," -> ", category.hierarchy[2])
            except:
                st.write(" ")
                st.error("Issue retrieving data from the API", icon="🚨")