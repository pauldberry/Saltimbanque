"""import os
import pandas as pd
import string
FDCs = set(['Amanda', 'Anna', 'Chelsea'])

def whofrom():

### Establish where the files originated from ###

	whofrom = input("Who did you receive these files from? Amanda, Anna, or Chelsea? (If not one of these enter 'none'): ")
	if whofrom =='none':
		print("You've entered a name that doesn't currently have a file.\n")
		pass
	elif whofrom =='NONE':
		print("You've entered a name that doesn't currently have a file.\n")
		pass
	else:
		whofrom = whofrom.title()
		whofrom = whofrom.strip()
		whofrom = whofrom.replace(" ","")
		pass
### Take this entry and match it with a corresponding folder (new folders must be created manually) ###

	if whofrom == str('Amanda'):
		whom = 'From A. Stys'
	elif whofrom == str('Anna'):
		whom = 'From A. Torres'
	elif whofrom == str('Chelsea'):
		whom = 'From C. Harris'

	pathstart = 'C:\\Users\\pberry\\Desktop\\My Docs\\Job Sector Data\\Reboot V2\\Data from outside sources\\'
	half_path = pathstart+whom

### This next step helps create a new directory and where to direct the eventual mass-file concatenation ###
### Need to add a Try/Except line here to account for bad entries

	print('\nWhat is the exact name of the folder that you put the files in? Here are the possible locations:')
	showfiles = os.listdir(half_path)
	for s in showfiles:
		print("\n",s,"\n")
	wherefrom = input( "\n")
	
	pathconct = pathstart+whom+'\\'+wherefrom
	path = os.chdir(pathconct)

	files = os.listdir(path)

	count = 0
	for c in files:
		count += 1

### This step shows what types of files you received ###

	print('\n                                       There are', count, 'files in the folder:\n\n', pathconct , '\n\n                                                  you selected.\n')

# Improvement to make here - should create an empty set, or list, and append new file types to the list, 
# then count them out, then use the % operator to print out the types of files in the print statement

	xlsx = set(['.xlsx'])
	xls = set([ '.xls'])
	text = set(['.txt'])
	pdfs = set(['.pdf'])
	xlsm = set(['.xlsm'])
	xlsb = set(['.xlsb'])
	
	countEXLS = 0
	countEXS = 0
	counTXT = 0
	countPDF = 0
	countM = 0
	countB = 0
	
	for file in files:
		extension = os.path.splitext(file)[1]
		if extension in xlsx: 
			countEXLS += 1
		elif extension in xls:
			countEXS += 1
		elif extension in text :
			counTXT += 1
		elif extension in pdfs: 
			countPDF += 1
		elif extension in xlsm:
			countM += 1
		elif extension in xlsb:
			countB += 1
	count_them = countEXLS + countEXS + counTXT + countPDF + countM + countB

	print('There are', countEXLS, 'Excel X files\n and', countEXS, 'Old Excel files\n and', counTXT, 'text files\n and', countPDF, 'PDF files\n for a total of\n', count_them, 'files\n and there are', count - count_them, 'other files of an unknown type.\n' )

### Here you can create a new directory or add to an existing one ###

	finalpath = input("What is the name of the final location you want your combined file in? Select a previous file or create a new name for one \n\n")
	das_finale = half_path+'\\'+finalpath
	if os.path.exists(das_finale):
		print("\nYour files will be placed here\n")
		pass
	elif not os.path.exists(das_finale):
		print("This folder didn't exist before, so I have created it for you.")
		os.makedirs(das_finale)
		pass

### NEXT STEPS ###
# smash the files together and put them in the new directory
# This step places all the Xlsx files in a list, and all the Xls files in another

	new_excel_names = []
	for file in files:
		if file.endswith('.xlsx'):
		       new_excel_names.append(file)
	print('There are', len(new_excel_names), 'files in the new_excel_names list waiting to smash together')

	old_excel_names = []
	for file in files:
		if file.endswith('.xls'):
			old_excel_names.append(file)
	print('There are', len(old_excel_names), 'files in the new_excel_names list waiting to smash together\n')

### Start smashing ###
	excels = [pd.ExcelFile(name) for name in old_excel_names]
	frames = [x.parse(x.sheet_names[0]) for x in excels]
	frames_new = [df[1:] for df in frames]
	combinedo = pd.concat(frames_new)
	os.chdir(das_finale)
	combinedo.to_excel("big.xlsx")

###Everything above this line works - files concatenate properly, but formatting is wonky if the files independently aren't properly formatted

whofrom()"""
#############################################################################################################################
#############################################################################################################################
#############################################################################################################################

### Everything below this line is a second generation version designed to be used by anyone ###

def whofrom1():
	import os
	import pandas as pd
	import string
	import re
	import sys
	import itertools
	from collections import defaultdict
	from collections import Counter

	cwd = os.getcwd()
	data_source = set([])
	showz = (['yes', 'Yes', 'Y', 'y'])
	noshowz = (['No', 'no', 'N', 'n'])

###	Show them where they are:
	print('\nThe current directory you are in is: \n\t', cwd, '\n')
	showme = input("Would you like to see the files in your current directory? Y or N\n")
	if showme in showz:
		showfiles = os.scandir(cwd)
		for s in showfiles:
			print("\t",s,"\n")
	else:
		pass
### Change the directory
	yesses = (['yes', 'Yes', 'Y', 'y', 'YES'])
	noways = (['No', 'no', 'N', 'n', 'NO'])

	print('Would you like to stay in your current working directory?\n\n', cwd, '\n')
	nexto = input('Yes or No:\t')
	try:
		if nexto in yesses:
			pass
		elif nexto in noways:
			changez = input('\nWhat directory would you like to go to? (Find the location of the file, not the file extension)  ')
			### Make sure the directory exists, and change it to there.
			assert os.path.exists(changez), "\nI didn't find the path directory you indicated, please try again\n"
			os.chdir(changez), print("\n\nYou have changed your directory successfully.  It is now:\n")
			cwd = os.getcwd()
			print('\n',cwd, '\n')
	
			### Now ask them to find the file name - you need the directory AND the file name because the combined files will end up in
			### the same place as the uncombined files
			find_files = input("What is the name of the folder where your raw files are? \t")
			finders = changez+'\\'+find_files
			assert os.path.exists(finders), "\n\t\tThis file doens't exist as you have specified, please try again\n"
			os.chdir(finders), print("\n\nYou have changed your directory successfully.  It is now:\n")
			cwd = os.getcwd()
			print('\n',cwd, '\n')
	
		else:
			print("\n\tThe character you entered (", nexto, ") is not valid. Please start over.\n\n")
			whofrom1()
	except:
		print("There is something wrong with how you are passing in file extensions.  Restarting program \n")
		whofrom1()
### Establish where the files originated from ###
	whofrom = input("\nWho did you receive these files from?\t")
	
	if re.match("[a-zA-Z]", whofrom):
		whofrom = whofrom.title()
		whofrom = whofrom.strip()
		whofrom = whofrom.replace(" ","_")
		data_source.add(whofrom)
	else:
		print('Please enter a correct name, without numbers or punctuation. Restarting.\n\n')
		whofrom1()

	print("\n Next we are going to list out the type of files in your folder, and count them.  Hit Enter to continue.")
	input("")

###	Count the number of files in the folder
	countemz = os.listdir(cwd)
	count = 0
	for c in countemz:
		count += 1
### Put all files in an empty list
	empty_setter0 = []
	for j in countemz:
		empty_setter0.append(j)

### Make an empty list to dump all exentions into (i.e w/ duplicates) to count how much of everything there is
	empty_setter1 = []
	for e in empty_setter0:
		k = os.path.splitext(e)[1]
		empty_setter1.append(k)
### Sometimes there are entire folders in the file you want to combine; this eliminates them from consideration
	empty_setter1.sort()
###	Remove any blanks:		
	for e1 in empty_setter1:
		if e1 =='':
			empty_setter1.remove(e1)
		else:
			pass
#	empty_setter1.remove('')
### remove the periods before each extension, I think this is screwing up counting later	
	empty_setter01 = []
	for e1 in empty_setter1:
		e1 = e1[1:]
		empty_setter01.append(e1)
	empty_setter1 = empty_setter01
### This last list empty_setter2 will be used to dump all the extensions from empty_setter1 without duplicates
	nodup_setter2 = []
### You can delete this next step eventually:

	for i in empty_setter1:
		if len(i) > 0:
			if i in nodup_setter2:
				pass
			else:
				nodup_setter2.append(i)
		else:
			pass
	
	nodup_len = len(nodup_setter2)
	print('\n\tCurrently there are', count, 'files in the folder:\t', cwd,'\n\n', "\tThere are", len(nodup_setter2), "unique file types:\n\t")
	print('\t', nodup_setter2, "\n")
	
	print("The count by file is as follows:\n")
	list_final = Counter(empty_setter1).most_common()
	for hub, dub in list_final:
		print(hub, dub)

	print("Hit Enter to continue.\n")
	input("")

### Now use empty_setter2 to count how many of each thing are in empty_setter1, and make this a key-value pair in a new dict
	
####################### Everything above this line works ######################################################################	
### Now trying to only count the files that will be smashed

#	goodset = set(['xlsx', 'xls'])
#
#	for a in list_final:
#		list_final.values()

	#print("Only Excel format files can be combined.", , "files will be combined." )

#################################################################################################################
#################################################################################################################
#		Everything in this double-fence is a stitched-together addition to smash the join model files
	#finalpath = input("What is the name of the final location you want your combined file in? Select a previous file or create a new name for one \n\n")
	half_path = os.getcwd()
	das_finale = half_path#+'\\'+finalpath
	if os.path.exists(das_finale):
		print("\nYour files will be placed here\n", cwd)
		pass
	elif not os.path.exists(das_finale):
		print("This folder didn't exist before, so I have created it for you.")
		os.makedirs(das_finale)
		pass

### NEXT STEPS ###
# smash the files together and put them in the new directory
# This step places all the Xlsx files in a list, and all the Xls files in another
	files = os.listdir(das_finale)


	new_excel_names = []
	for file in files:
		if file.endswith('.xlsx'):
		       new_excel_names.append(file)
	print('There are', len(new_excel_names), 'files in the new_excel_names list waiting to smash together')

	old_excel_names = []
	for file in files:
		if file.endswith('.xls'):
			old_excel_names.append(file)
	print('There are', len(old_excel_names), 'files in the new_excel_names list waiting to smash together\n')

	for file in new_excel_names:
		old_excel_names.append(file)

### Start smashing ###
	totalz = []

	excels = [pd.ExcelFile(name) for name in old_excel_names]
	frames = [x.parse(x.sheet_names[0]) for x in excels]
	frames_new = [df[1:] for df in frames]
	combinedo = pd.concat(frames_new)
	os.chdir(das_finale)
	combinedo.to_excel("combined1.xlsx")
	totalz.append("combined1.xlsx")

#	excels = [pd.ExcelFile(name) for name in new_excel_names]
#	frames = [x.parse(x.sheet_names[0]) for x in excels]
#	frames_new = [df[1:] for df in frames]
#	combinedo = pd.concat(frames_new)
#	os.chdir(das_finale)
#	combinedo.to_excel("combined2.xlsx")
#	totalz.append("combined2.xlsx")	


#	excels = [pd.ExcelFile(name) for name in totalz]
#	frames = [x.parse(x.sheet_names[0]) for x in excels]
#	frames_new = [df[1:] for df in frames]
#	combinedo = pd.concat(frames_new)
#	os.chdir(das_finale)
#	combinedo.to_excel("combinedv2.xlsx")

	print("The file is now ready to view in the folder you specified\n\n\t", cwd, "\n")
#
#################################################################################################################
#################################################################################################################

whofrom1()

"""


### Now count only those files that can be merged
	warn_list = ['pptx', 'pdf', 'doc', 'docx']
	print("\n\tOnly Excel and CSV files will be combined. Press any key to continue.\n")
	input("")
	my_dicty2 ={}

	for blah in empty_setter2:
		if blah in warn_list:
			pass
		else:
			my_dicty2.update({blah: ''})

### Make a list from the dictionary of values - not sure if this is necessary or not, might be able to iterate the dict
	

	#### Use the extensions 

	
	print(my_dicty)
	print(dicty_to_list)


	
###	iterate through empty_setter and count the number of files
### put this number as the key
### extract this number, use it to tell the user how many files of each type they have


### the next print statement is temp
	



#	NEXT - count the types of files in a compact way:
	file_types = set(['.xlsx', '.xls', '.txt', '.pdf', '.xlsm','.xlsb'])

	
	countEXLS = 0
	countEXS = 0
	counTXT = 0
	countPDF = 0
	countM = 0
	countB = 0
	
	for file in files:
		extension = os.path.splitext(file)[1]
		if extension in xlsx: 
			countEXLS += 1
		elif extension in xls:
			countEXS += 1
		elif extension in text :
			counTXT += 1
		elif extension in pdfs: 
			countPDF += 1
		elif extension in xlsm:
			countM += 1
		elif extension in xlsb:
			countB += 1
	count_them = countEXLS + countEXS + counTXT + countPDF + countM + countB

	print('There are', countEXLS, 'Excel X files\n and', countEXS, 'Old Excel files\n and', counTXT, 'text files\n and', countPDF, 'PDF files\n for a total of\n', count_them, 'files\n and there are', count - count_them, 'other files of an unknown type.\n' )

###		Next Steps:
# You are in the file you want to find the files
# Create a new folder where the final combined file will land
# Grab files from current directory
# smash them together
# Open the folder with the file
# Open the file
# Ask if there are other files to smash together - if Yes, restart function, if No, exit.







	
### Take this entry and match it with a corresponding folder (new folders must be created manually) ###

	if whofrom == str('Amanda'):
		whom = 'From A. Stys'
	elif whofrom == str('Anna'):
		whom = 'From A. Torres'
	elif whofrom == str('Chelsea'):
		whom = 'From C. Harris'


### This next step helps create a new directory and where to direct the eventual mass-file concatenation ###
### Need to add a Try/Except line here to account for bad entries

	wherefrom = input( "\n")
	
	pathconct = pathstart+whom+'\\'+wherefrom
	path = os.chdir(pathconct)

	



# Improvement to make here - should create an empty set, or list, and append new file types to the list, 
# then count them out, then use the % operator to print out the types of files in the print statement

	
### Here you can create a new directory or add to an existing one ###

	finalpath = input("What is the name of the final location you want your combined file in? Select a previous file or create a new name for one \n\n")
	das_finale = half_path+'\\'+finalpath
	if os.path.exists(das_finale):
		print("\nYour files will be placed here\n")
		pass
	elif not os.path.exists(das_finale):
		print("This folder didn't exist before, so I have created it for you.")
		os.makedirs(das_finale)
		pass

### NEXT STEPS ###
# smash the files together and put them in the new directory
# This step places all the Xlsx files in a list, and all the Xls files in another

	new_excel_names = []
	for file in files:
		if file.endswith('.xlsx'):
		       new_excel_names.append(file)
	print('There are', len(new_excel_names), 'files in the new_excel_names list waiting to smash together')

	old_excel_names = []
	for file in files:
		if file.endswith('.xls'):
			old_excel_names.append(file)
	print('There are', len(old_excel_names), 'files in the new_excel_names list waiting to smash together\n')

### Start smashing ###
	excels = [pd.ExcelFile(name) for name in old_excel_names]
	frames = [x.parse(x.sheet_names[0]) for x in excels]
	frames_new = [df[1:] for df in frames]
	combinedo = pd.concat(frames_new)
	os.chdir(das_finale)
	combinedo.to_excel("big.xlsx")

###Everything above this line works - files concatenate properly, but formatting is wonky if the files independently aren't properly formatted

whofrom1()"""