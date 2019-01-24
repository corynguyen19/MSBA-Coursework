#!/usr/bin/python
import sys

# Define the data that I want to pass through the mapper
fields = ('Message-ID', 'From', 'To', 'Cc', 'Bcc')
for line in sys.stdin:
    # Remove the whitespace
    line = line.strip()
    # Split up the individual items
    items = line.split('\t')
    # Initialize an empty list to save the desired items
    print_items = []
    # Loop through items to find only the items in the desired fields
    for i in items:
        if i.startswith(fields):
            print_items.append(i)
    # Print each item followed by a tab
    # If all values are present
    try:
        print(print_items[0]+'\t'+print_items[1]+'\t'+print_items[2]+'\t'+
              print_items[3]+'\t'+print_items[4])
    except IndexError:
        # If there is no Bcc:
        try:
            print(print_items[0]+'\t'+print_items[1]+'\t'+print_items[2]+'\t'+
                  print_items[3]+'\t'+'placeholder')
        # If there is no Cc: or Bcc:
        except IndexError:
            print(print_items[0]+'\t'+print_items[1]+'\t'+print_items[2]+'\t'+
                  'placeholder'+'\t'+'placeholder')
