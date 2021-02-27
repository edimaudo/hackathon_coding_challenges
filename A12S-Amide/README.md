# Introduction

Crypto art is a category of art related to blockchain technology.

While there isn't one agreed upon definition for the term, two common interpretations currently exist among crypto artists and their collectors. The first, regarding crypto-themed artworks, or those with subject matters focusing on the culture, politics, economics, or philosophy surrounding blockchain and cryptocurrency technology. The second, and more popularized definition, includes digital artwork that is published directly onto a blockchain in the form of a non-fungible token (NFT), which makes the ownership, transfer, and sale of an artwork possible in a cryptographically secure and verifiable manner. [[1]](https://en.wikipedia.org/wiki/Crypto_art)

Collectors of cryptoart is intunded with choices. Matching consumers with the most appropriate artworks is the key to enhancing user satisfaction. Therefore, cryptoart market is a excellent platform to analyze the pattern of the collectors and provide them a personalized recommendations.

# Data Description

Dataset contains three files:

* **train.csv and test.csv** contain information about the buyers and their affinity on the artwork
    * <font color='blue'>*buyer:*</font> the Ethereum address of the buyer of the artwork
    *  <font color='blue'>*tokenId:*</font> the identification number of the artwork
    *  <font color='blue'>*affinity:*</font> the target variable that we want you to predict. The variable represents the value of the artwork as well as interest of the collector to the related artwork.
    
* **tokens.csv:** contains information about artworks, including text metadata like title, description, tags and IPFS links addressing the artwork's media object.
    * <font color='blue'>*name:*</font> the name of the artwork (given by the creator)
    * <font color='blue'>*description:*</font> the description of the artwork (given by the creator)
    * <font color='blue'>*tags:*</font> the tags of the artwork (given by the creator)
    * <font color='blue'>*image:*</font> the IPFS link of the image of the artwork
    * <font color='blue'>*media:*</font> the IPFS link of the media of the artwork. Note: this is different from image when the artwork is not an image (for instance when it is a video)
    * <font color='blue'>*type:*</font> the media (MIME) type of the artwork
    * <font color='blue'>*size:*</font> the size in bytes of the artwork
    * <font color='blue'>*dimensions:*</font> the dimensions of the artwork
    * <font color='blue'>*creator:*</font> the Ethereum address of the creator (the artist) of the artwork
    * <font color='blue'>*tokenId:*</font> the identification number of the artwork

    * Note: attributes media, type, size, and dimensions are only available for relatively new artworks.

# Problem Description

Goal of this problem is predicting `affinity` of the `buyer` to related item (art piece). You can use different methods to solve this problem (e.g recommender systems). Adressing other problems are nice to have and encouraged (e.g cold start, diversity in recommender systems).

# Evaluation Criteria

Submissions are evaluated on [Root-Mean-Squared-Error (RMSE)](https://en.wikipedia.org/wiki/Root-mean-square_deviation) between the predicted value and the observed affinity. Top 10 will be found by using RMSE and the judges will choose the winner by evaluating their submission which includes the code, short report and predictions.

# CryptoArt Useful Sources

https://en.wikipedia.org/wiki/Crypto_art

https://cryptoart.io

https://cryptoart.com

https://www.superrare.co

https://en.wikipedia.org/wiki/Non-fungible_token
