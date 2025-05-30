'''
Script to turn .sql dump files into CSV format
'''

#!/usr/bin/env python
import fileinput
import csv
import sys
import os

# This prevents prematurely closed pipes from raising
# an exception in Python
from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

# allow large content in the dump
csv.field_size_limit(sys.maxsize)

def is_insert(line):
    """
    Returns true if the line begins a SQL insert statement.
    """
    return line.startswith('INSERT INTO')


def get_values(line):
    """
    Returns the portion of an INSERT statement containing values
    """
    return line.partition(' VALUES ')[2]


def values_sanity_check(values):
    """
    Ensures that values from the INSERT statement meet basic checks.
    """
    assert values
    assert values[0] == '('
    # Assertions have not been raised
    return True


def parse_values(values, outfile):
    """
    Given a file handle and the raw values from a MySQL INSERT
    statement, write the equivalent CSV to the file
    """
    latest_row = []

    # Specify the escapechar in the csv.writer initialization
    writer = csv.writer(outfile, quoting=csv.QUOTE_MINIMAL, escapechar='\\')
    
    reader = csv.reader([values], delimiter=',',
                        doublequote=False,
                        escapechar='\\',
                        quotechar="'",
                        strict=True
    )

    for reader_row in reader:
        for column in reader_row:
            # If our current string is empty...
            if len(column) == 0 or column == 'NULL':
                latest_row.append(chr(0))
                continue
            # If our string starts with an open paren
            if column[0] == "(":
                # If we've been filling out a row
                if len(latest_row) > 0:
                    # Check if the previous entry ended in
                    # a close paren. If so, the row we've
                    # been filling out has been COMPLETED
                    # as:
                    #    1) the previous entry ended in a )
                    #    2) the current entry starts with a (
                    if latest_row[-1][-1] == ")":
                        # Remove the close paren.
                        latest_row[-1] = latest_row[-1][:-1]
                        writer.writerow(latest_row)
                        latest_row = []
                # If we're beginning a new row, eliminate the
                # opening parentheses.
                if len(latest_row) == 0:
                    column = column[1:]
            # Add our column to the row we're working on.
            latest_row.append(column)
        # At the end of an INSERT statement, we'll
        # have the semicolon.
        # Make sure to remove the semicolon and
        # the close paren.
        if latest_row[-1][-2:] == ");":
            latest_row[-1] = latest_row[-1][:-2]
            writer.writerow(latest_row)


def main():
    """
    Parse arguments and start the program
    """
    # Define the output CSV file path
    output_file = 'csv_files/issues.csv'

    try:
        # Open the CSV file for writing
        with open(output_file, mode='w', newline='', encoding='utf-8') as outfile:
            # Iterate over all lines in all files
            # listed in sys.argv[1:]
            # or stdin if no args given.
            for line in fileinput.input():
                # Look for an INSERT statement and parse it.
                if not is_insert(line):
                    raise Exception("SQL INSERT statement could not be found!")
                values = get_values(line)
                if not values_sanity_check(values):
                    raise Exception("Getting substring of SQL INSERT statement after ' VALUES ' failed!")
                parse_values(values, outfile)
    except KeyboardInterrupt:
        sys.exit(0)

if __name__ == "__main__":
    main()