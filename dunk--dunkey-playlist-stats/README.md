# Dunkey Playlist Stats

Data on playlists created by [videogamedunkey](https://www.youtube.com/@videogamedunkey) on YouTube. One file per playlist.

- Playlists are for "[Dunkey's Greatest Hits](https://www.youtube.com/playlist?list=PLMBTl5yXyrGQ68Ny1mXCAaSwbjpcVwm49)" and "[More Bunkey](https://www.youtube.com/playlist?list=PLMBTl5yXyrGSa67JeYb6ctt1gCvL9BdEX)"
- Data was fetched using [YouTube Data API v3](https://developers.google.com/youtube/v3/getting-started)
- Includes a python notebook to fetch the data from a playlist or an individual video. See documentation to setup an API key.

Fields in each CSV file:
- `title`: Title of the video
- `video_id`: Unique identifier for the video. Can be used to create a link to the video: `https://www.youtube.com/watch?v=video_id`
- `views`: Number of views
- `likes`: Number of likes
- `upload_date`: Date the video was uploaded
- `fetch_date`: Date the data was fetched

Source: YouTube