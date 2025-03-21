# This script fetches images from a specified date range using the functions defined in fetchImg.py

import sys
from components.fetchImg import download_image_from_page, generate_date_range, wait_random_time, construct_url_and_path

if len(sys.argv) != 3:
    print("Usage: python main.py <start_date_YYYYMMDD> <end_date_YYYYMMDD>")
    sys.exit(1)

# define date range
start_date = sys.argv[1]
end_date = sys.argv[2]
date_range = generate_date_range(start_date, end_date)
print(f"Dates: {start_date} to {end_date} ({len(date_range)} days)")

# fetch images for each date in the range
for d in date_range:
    wait_random_time()
    url, save_path = construct_url_and_path(d)
    print(url, end=": ")
    download_image_from_page(url, save_path=save_path)
