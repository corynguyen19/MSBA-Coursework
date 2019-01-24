#!/usr/bin/python
import sys

# Set these initial values
wordcount = {}
current_word= None
messages_with_word = 0

# Message length will print first, so let's print that line
print ('Message length summaries: total number, total word count, sum of squares, minimum, maximum, mean, variance')
# input comes from STDIN
for line in sys.stdin:
    # Remove leading and trailing whitespace
    line = line.strip()
    
    # Split up the words, file names, and counts
    word, count = line.split('\t', 1)
    count = int(count)
    
    # If the word is equal to the current word, store the current count to the wordcount dictionary
    if current_word == word:
        wordcount[messages_with_word] = count
        # Add 1 to the index so that all messages will be stored uniquely
        messages_with_word += 1
    # When finished with a word, output summary statistics
    else:
        if current_word != None:
            message_count = len(wordcount.keys())
            total_count = sum(wordcount.values())
            mean = round(float(total_count)/float(message_count),1)
            sum_squares = round(sum(map(lambda x: (x - mean)**2, wordcount.values())),1)
            variance = round(float(sum_squares/message_count),1)
            maximum = max(wordcount.values())
            # For message length, we want to store the total value so we can calculate minimum in words later
            if current_word == 'Message':
                total_message_count = message_count
            if message_count < total_message_count:
                minimum = 0
            else:
                minimum = min(wordcount.values())
            print ('%s\t%s, %s, %s, %s, %s, %s, %s'% (current_word, message_count,total_count, sum_squares,minimum, maximum, mean,variance))

            # Let's print out the statistics being printed by the word once we've done message lengths
            if current_word == 'Message':
                print ('Word summaries: total number, total word count, sum of squares, minimum, maximum, mean, variance')
            
            # Reinitialize these values for the next word
            current_word = word
            wordcount = {}
            messages_with_word = 0
            wordcount[messages_with_word] = count
        # This else statement stores the first word as the current word
        else:
            current_word = word
            wordcount[messages_with_word] = count
            messages_with_word += 1

# Output the summaries for the last word. The key here is that the statement is out of the main 'for' loop
if current_word == word:
    message_count = len(wordcount.keys())
    total_count = sum(wordcount.values())
    mean = round(float(total_count)/float(message_count),1)
    sum_squares = round(sum(map(lambda x: (x - mean)**2, wordcount.values())),1)
    variance = round(float(sum_squares/message_count),1)
    maximum = max(wordcount.values())
    if current_word == 'Message':
        total_message_count = message_count
    if message_count < total_message_count:
        minimum = 0
    else:
        minimum = min(wordcount.values())
    print ('%s\t%s, %s, %s, %s, %s, %s, %s'% (word, message_count,total_count, sum_squares, minimum, maximum, mean,variance))
