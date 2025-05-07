import csv
import sys
from langdetect import detect, LangDetectException

csv.field_size_limit(sys.maxsize)

# Get only the rows with English language summary
with open('csv_files/issues.csv', mode='r', encoding='utf-8', newline='') as infile, \
     open('csv_files/`2-issues_unresolved_en.csv', mode='w', encoding='utf-8', newline='') as outfile:
    
    reader = csv.reader((line.replace('\x00', '') for line in infile))  # Handle null characters
    writer = csv.writer(outfile)

    for row in reader:
        if len(row) > 8:
            summary = row[8].strip()
            try:
                # Detect language of the summary
                language = detect(summary)
                if language == 'en':  # 'en' means English
                    writer.writerow(row)
            except LangDetectException:
                # If detection fails (e.g., empty summary), skip the row
                continue


# Get only the rows with a summary and description
with open('csv_files/`2-issues_unresolved_en.csv', mode='r', encoding='utf-8', newline='') as infile, \
     open('csv_files/`3-issues_unresolved_recent.csv', mode='w', encoding='utf-8', newline='') as outfile:
    
    reader = csv.reader((line.replace('\x00', '') for line in infile))
    writer = csv.writer(outfile)

    # Write header
    header = next(reader)
    writer.writerow(header)

    for row in reader:
        if len(row) > 9:  # Only process rows with at least 10 fields
            summary = row[8].strip()
            description = row[9].strip()

            if summary != 'NULL' and description != 'NULL':
                writer.writerow(row)