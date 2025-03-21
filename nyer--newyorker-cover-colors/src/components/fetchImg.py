import requests
from bs4 import BeautifulSoup
import os
from datetime import datetime, timedelta
import time
import random

def wait_random_time(min_seconds=0.1, max_seconds=1):
    wait_time = random.uniform(min_seconds, max_seconds)
    time.sleep(wait_time)

def construct_url_and_path(date):
    year = date[:4]
    month = date[4:6]
    day = date[6:8]
    url = f"https://www.newyorker.com/magazine/{year}/{month}/{day}"
    save_path = f"covers/{year}_{month}_{day}.jpg"
    return url, save_path

def download_image_from_page(
    url, 
    picture_classes=["ResponsiveImagePicture-cWuUZO", "dUOtEa", "AssetEmbedResponsiveAsset-cXBNxi", "eCxVQK", "asset-embed__responsive-asset", "responsive-image"], 
    save_path="downloaded_image.jpg"
    ):
    # Fetch the page content
    response = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
    if response.status_code != 200:
        print("Failed to fetch the page")
        return
    
    # Parse HTML
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Find the picture tag with all specified classes
    picture_tag = soup.find("picture", class_=lambda x: x and all(cls in x.split() for cls in picture_classes))

    if not picture_tag:
        print("No matching <picture> tag found")
        return

    # Find the <img> tag inside <picture>
    img_tag = picture_tag.find("img")
    if not img_tag or not img_tag.get("src"):
        print("No <img> tag or src attribute found")
        return
    
    # Get image URL
    img_url = img_tag["src"]
    if img_url.startswith("//"):
        img_url = "https:" + img_url  # Handle protocol-relative URLs
    elif img_url.startswith("/"):
        img_url = url + img_url  # Handle relative URLs

    # Download the image
    img_response = requests.get(img_url, stream=True)
    if img_response.status_code == 200:
        with open(save_path, "wb") as file:
            for chunk in img_response.iter_content(1024):
                file.write(chunk)
        print(f"Image downloaded: {save_path}")
    else:
        print("Failed to download image")

def generate_date_range(start_date, end_date):
    start = datetime.strptime(start_date, "%Y%m%d")
    end = datetime.strptime(end_date, "%Y%m%d")
    date_generated = [start + timedelta(days=x) for x in range(0, (end-start).days + 1)]
    return [date.strftime("%Y%m%d") for date in date_generated]
