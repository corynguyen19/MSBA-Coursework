#!/usr/bin/python
import sys
# Regular Expression will need to be imported
import re

# Title the fields that we are looking for
fields = [ 'From: ', 'To: ', 'Cc: ', 'Bcc: ', 'Message-ID: ']
for line in sys.stdin:

    # Remove the whitespace
    line = line.strip()
    # Remove the title from each line
    for field in fields:
        line = line.replace(field, '')
    # Split the line into 5 variables based on tabs
    message_id, message_from, message_to, message_cc, message_bcc = line.split('\t',5)
    # Create keys -- These will be the key values in our output
    keys = [message_from, message_to, message_cc, message_bcc]

    # Enumerate allows us to cycle through the keys and their names in fields
    for item_val, key in enumerate(keys):
        # Split the items with multiple values
        key_split = re.findall('[a-zA-Z\.\/]+\@[a-zA-Z0-9.]+',key)
        for item in key_split:
            # Filter out placeholders and empty strings
            if item == 'placeholder' or item == '':
                continue
            # Print the key-value pairs separated by a tab
            else:
                print(fields[item_val]+item+'\t'+message_id)            
