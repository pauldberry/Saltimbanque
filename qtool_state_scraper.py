# Tony's QTool file grabber
from selenium import webdriver
import requests
import os
from glob import glob
from git import *

states = [
                'Alabama',
                'Alaska',
                'Arizona',
                'Arkansas',
                'California',
                'Colorado',
                'Connecticut',
                'Delaware',
                'Florida',
                'Georgia',
                'Hawaii',
                'Idaho',
                'Illinois',
                'Indiana',
                'Iowa',
                'Kansas',
                'Kentucky',
                'Louisiana',
                'Maine',
                'Maryland',
                'Massachusetts',
                'Michigan',
                'Minnesota',
                'Mississippi',
                'Missouri',
                'Montana',
                'Nebraska',
                'Nevada',
                'New Hampshire',
                'New Jersey',
                'New Mexico',
                'New York',
                'North Carolina',
                'North Dakota',
                'Ohio',
                'Oklahoma',
                'Oregon',
                'Pennsylvania',
                'Rhode Island',
                'South Carolina',
                'South Dakota',
                'Tennessee',
                'Texas',
                'Utah',
                'Vermont',
                'Virginia',
                'Washington',
                'West Virginia',
                'Wisconsin',
                'Wyoming'
        ]

driver = webdriver.PhantomJS()
driver.get("https://qtool.catalist.us/login")

assert "Login" in driver.title

# There are three fields to enter for QTool - Username, Password, and Organization, respectively
driver.find_element_by_id("j_username").clear()
driver.find_element_by_id("j_username").send_keys("pberry")

# elem.send_keys(Keys.RETURN)

driver.find_element_by_id("j_password").clear()
driver.find_element_by_id("j_password").send_keys("pbAf@org")
# elem.send_keys(Keys.RETURN)

driver.find_element_by_id("organization").clear()
driver.find_element_by_id("organization").send_keys("afscme")
# elem.send_keys(Keys.RETURN)

driver.find_element_by_css_selector("input.btn").click()


# lets get some cookies
cookies = driver.get_cookies()
rs = requests.Session()
for cookie in cookies:
    rs.cookies.set(cookie['name'], cookie['value'])

for i in glob('release_notes/*.pdf'):
    os.remove(i)

for state in states:
    link = driver.find_element_by_partial_link_text(state).get_attribute('href')
    text = driver.find_element_by_partial_link_text(state).get_attribute('text')
    file = rs.get(link, stream=True)
    with open('release_notes/{}.pdf'.format(text), 'wb') as outfile:
        outfile.write(file.raw.read())

driver.close()