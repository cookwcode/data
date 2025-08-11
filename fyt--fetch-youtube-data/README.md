# Fetch YouTube Data

Fetch all videos from a YouTube channel and export as CSV.

## Setup

1. Get a YouTube Data API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the YouTube Data API v3

## Usage

```bash
node fetchYouTubeData.js fetch CHANNEL_ID
```

Run with `--help` for all options and API key setup instructions.

## Data Output

CSV file with columns:
- `video_id` - YouTube video ID
- `title` - Video title  
- `views` - View count
- `likes` - Like count
- `upload_date` - Publication date
- `fetch_date` - When data was retrieved