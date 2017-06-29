### This project will be a program that crawls websites you are specifically interested in applying to jobs to, and ### looks for new posted positions that match a list of keywords

### Structure: list of keywords, list of websites, code that searches for either i) changes made from the day before (might require a lot of memory), or ii) matches to the list of words, 
### output will be a message that indicates which websites, the title of the new position, and a link to it

### Nice to haves: 
###					use the invisible browser "" (sic) that Tony showed you
###					it should run automatically at some time, or ideally when you log in every morning
###					the message could be a text message to your phone
###					if it's running automatically, might as well run multiple times a day

# Steps: go to website. crawl entire site. copy site contents into list. compare this list to previous day. if no changes, make today;s list yesterday's list.
# if changes, send email or text message with link of site where chnages happened.

import os
import requests
from collections import defaultdict
from bs4 import BeautifulSoup
from lxml import html

# Need to create an empty list for each website, then crawl each, scrape all words, insert these words into it's respective list
# and then compare those words to the previous day for any changes - can also iterate over all words and see if certain words pop


original_political_listy0 = ["https://www.democrats.org/about/work-with-us",
"http://dccc.org/jobs/",
"http://www.dscc.org/about-us/jobs/",
"http://www.dlcc.org/careers",
"http://americavotes.org/jobs/",
"https://targetsmart.com/careers/",
"https://www.catalist.us/about/careers/",
"https://boards.greenhouse.io/forourfuture",
"https://gqrr.bamboohr.com/jobs/"]

original_political_listy = ["http://www.statsdad.com/2011/02/youth-sports-refs-and-umps-have-tough.html"
#, "http://www.statsdad.com/2011/02/youth-baseball-cutting-players.html", 
#"http://www.statsdad.com/2011/02/university-of-minnesota-conducted.html"
]
"""n = len(original_political_listy)

o = []

while n > 0:
	m=str(n)
	o.append(m)
	n = n - 1

listers = []

for i in o:
	i = int(i)
	listers.append(i)

zero_list = []

for f in o:
	zero_list.append("page" + f)

zero_list = sorted(zero_list)

masterlist = []

"""

#for i in zero_list:
#	masterlist[i].append('chasse')
#
#for chasseur in masterdict:
#	masterlist[chasseur] = []


### Everything works above this works

#pager = requests.get("http://www.statsdad.com/2011/02/youth-sports-refs-and-umps-have-tough.html")
#pageini = html.fromstring(pager.content)
#soup = BeautifulSoup(pageini.text, 'lxml')
#souper = soup.prettify()

#for pg in original_political_listy:
#		pager = requests.get(pg)
#		pageini = html.fromstring(pager.content)
#		for m in masterlist:
#			masterlist.append(pageini)

#print(souper)
################### Unclear if you will need what is below #########################
#
#allowed_domains = ['democrats.org', 'dccc.org', 'dlcc.org', 'americavotes.org', 'targetsmart.com', 'catalist.us', 'boards.greenhouse.io', 'gqrr.bamboohr.com']
#
#start_urls = ["https://www.democrats.org/about/work-with-us",
#			  "http://dccc.org/jobs/",
#			  "http://www.dscc.org/about-us/jobs/",
#			  "http://www.dlcc.org/careers",
#			  "http://americavotes.org/jobs/",
#			  "https://targetsmart.com/careers/",
#			  "https://www.catalist.us/about/careers/",
#			  "https://boards.greenhouse.io/forourfuture",
#			  "https://gqrr.bamboohr.com/jobs/",
#			  "http://aristotle.com/careers"]


#leg = len(original_political_listy)
#while leg != 0:
#	for site in original_political_listy:
#
#		leg = leg + 1



import os
import requests
from collections import defaultdict
from bs4 import BeautifulSoup
from lxml import html
import nltk
import urllib

page = "http://www.statsdad.com/2011/02/youth-sports-refs-and-umps-have-tough.html"
pager = urllib.urlopen(page).read()
soup = BeautifulSoup(pager)

text = soup.get_text()
lines = (line.strip() for line in text.splitlines())
chunks = (phrase.strip() for line in lines for phrase in line.split (" "))
#text = "\".join(chunk for chunk in chunks if chunk)
