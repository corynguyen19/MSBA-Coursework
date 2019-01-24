#!/usr/bin/python
import sys

for line in sys.stdin:
    # Make a dictionary that will hold word counts for each line
    # The dictionary will also include a key called 'Message' to store message lengths
    wordcount = {'Message':0}
    
    # Remove leading and trailing whitespace
    line = line.strip()

    # Set all words in the line to lowercase
    line = line.lower()

    # Split the line into words
    words = line.split()

    # Loop through words and store new words into a dictionary with a count of 1
    # If word is already in the dictionary, add 1 to the count
    for word in words:
        if word in wordcount.keys():
            wordcount[word] += 1
        else:
            wordcount[word] = 1
        # Also increase the message length counter by 1
        wordcount['Message'] += 1
    # Print the dictionary for each line
    for word in wordcount.keys():
        print ('%s\t%s'% (word, wordcount[word]))
