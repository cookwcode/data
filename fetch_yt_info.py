import marimo

__generated_with = "0.14.16"
app = marimo.App()


@app.cell(hide_code=True)
def _(mo):
    mo.md(
        r"""
    # Fetch YT Info

    Use the YouTube Data API to fetch info for the videos in a given playlist. Results can be downloaded as external files.

    - [YouTube Data API Overview](https://developers.google.com/youtube/v3/getting-started)
    """
    )
    return


@app.cell
def _():
    API_KEY = input("Enter your YouTube Data API key: ")
    return (API_KEY,)


@app.cell
def _():
    import requests
    import pandas as pd

    # Get all video IDs in the playlist
    def get_video_ids(playlist_id, api_key):
        video_ids = []
        base_url = "https://www.googleapis.com/youtube/v3/playlistItems"
        params = {
            "part": "contentDetails",
            "playlistId": playlist_id,
            "maxResults": 50,
            "key": api_key
        }

        while True:
            res = requests.get(base_url, params=params).json()
            for item in res.get("items", []):
                video_ids.append(item["contentDetails"]["videoId"])
            next_token = res.get("nextPageToken")
            if not next_token:
                break
            params["pageToken"] = next_token

        return video_ids

    # Get stats (views, likes) for each video
    def get_video_stats(video_ids, api_key):
        stats = []
        base_url = "https://www.googleapis.com/youtube/v3/videos"
        for i in range(0, len(video_ids), 50):  # max 50 IDs per request
            ids_slice = video_ids[i:i+50]
            params = {
                "part": "statistics,snippet",
                "id": ",".join(ids_slice),
                "key": api_key
            }
            res = requests.get(base_url, params=params).json()
            for item in res.get("items", []):
                stats.append({
                    "video_id": item["id"],
                    "title": item["snippet"]["title"],
                    "views": int(item["statistics"].get("viewCount", 0)),
                    "likes": int(item["statistics"].get("likeCount", 0)),
                    "upload_date": item["snippet"].get("publishedAt", "")
                })
        return stats

    # formatting
    def format_as_df(video_stats):
        df = pd.DataFrame(video_stats)
        df['fetch_date'] = pd.Timestamp.now(tz='UTC').replace(microsecond=0).isoformat().replace('+00:00', 'Z')
        df = df.sort_values(by="upload_date", ascending=True).reset_index(drop=True)
        return df
    return format_as_df, get_video_ids, get_video_stats


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""## Fetch data from playlist""")
    return


@app.cell
def _():
    PLAYLIST_ID = input("Enter the YouTube playlist ID (the part after 'list='): ")
    return (PLAYLIST_ID,)


@app.cell
def _(API_KEY, PLAYLIST_ID, get_video_ids, get_video_stats):
    # Run and show results (pings API)
    video_ids = get_video_ids(PLAYLIST_ID, API_KEY)
    video_stats = get_video_stats(video_ids, API_KEY)
    return (video_stats,)


@app.cell
def _(format_as_df, video_stats):
    # Format
    df = format_as_df(video_stats)
    return (df,)


@app.cell
def _(df):
    # export
    df.to_csv("youtube_data.csv", index=False)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""## Fetch data from video""")
    return


@app.cell
def _():
    VIDEO_ID = input("Enter the YouTube video ID (the part after 'v='): ")
    return (VIDEO_ID,)


@app.cell
def _(API_KEY, VIDEO_ID, get_video_stats):
    single_vid_stats = get_video_stats([VIDEO_ID], API_KEY)
    return (single_vid_stats,)


@app.cell
def _(single_vid_stats):
    single_vid_stats
    return


@app.cell
def _():
    import marimo as mo
    return (mo,)


if __name__ == "__main__":
    app.run()
