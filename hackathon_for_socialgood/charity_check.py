from selenium import webdriver
import sys
import time

path_to_chromedriver = '/Users/edima/Documents/Coding/python_projects/web_scraping_crawling/chromedriver'


driver = webdriver.Chrome(path_to_chromedriver)
BASE_URL = "https://www.charitydata.ca"
driver.get(BASE_URL)

try:
	print("1")

except:
	e = sys.exc_info()
	print(e)
	sys.exit(1)