# YouTube Video Trend Monitoring System 📈

![image alt]([path/to/demo-image.png](https://github.com/NP10t/YouTube-Trend-Notifier/blob/91e255e13edc3757ede14be1fb3f583265f482ba/assets/kafka_diagram.png)) <!-- Replace with the actual path to your demo image in the repository -->

## Project Overview
This project is a data engineering solution designed to monitor YouTube videos on a specified channel or playlist, helping content managers identify trending and non-trending videos. With this information, YouTube channels can take strategic actions like updating thumbnails or titles to boost engagement and sustain video performance. This system provides real-time video trend analysis, monitoring, and notifications via Telegram for easy access.

## Key Features
- **Automated Trend Detection:** Identifies videos trending up or down on a YouTube channel.
- **Daily Notifications:** Sends alerts to Telegram, detailing trending and non-trending videos.
- **Actionable Insights:** Helps YouTube channel managers improve video performance with trend-based suggestions.
- **Scalable Setup:** Built with Docker, ksqlDB, and Confluent for robust data processing.

## Prerequisites
1. **Get a YouTube API Key**  
   Visit [Google Cloud Console](https://console.cloud.google.com/) and register for the YouTube Data API v3. For API usage, refer to the [YouTube API Documentation](https://developers.google.com/youtube/v3/docs).
  
2. **Configure Local Settings**  
   Open the file `config/config.local` and add your credentials:
   ```ini
   [youtube]
   API_KEY=<your_api_key>
   PLAYLIST_ID=<id_of_the_playlist_to_monitor> 
   ```

## Setup & Usage

### Step 1: Docker Setup
Run the following command to start up the necessary Docker services:
```bash
docker-compose up -d
```

### Step 2: Confluent and ksqlDB Setup
1. **Access Confluent Platform**  
   Open Confluent and navigate to ksqlDB.

2. **Run SQL Commands**  
   Execute the SQL commands in `Video_Growth_Monitoring.sql` within ksqlDB to set up the necessary streams and tables for monitoring video trends.

### Step 3: Telegram Notifications
1. **Telegram Connector**  
   Upload the `connector_telegram_box_sink_config.json` file to the Connect service in Confluent to establish the Telegram connection.
   
2. **Run Analysis**
   Modify the video data (such as `likes` and `comments` fields) and then run:
   ```bash
   python YoutubeAnalytics.py
   ```

### Demo
![demo](path/to/another-demo-image.png) <!-- Embed more demo images here -->

### Scheduling with Airflow
This analysis can be automated daily using Airflow, ensuring you receive up-to-date trend insights regularly.

## Thanks
Special thanks to the contributors and resources that made this project possible!  
Watch a detailed setup tutorial here: [YouTube Data Engineering Tutorial](https://www.youtube.com/watch?v=0aqSjJ3-4NI&t=991s)

## Contributions
Contributions to improve trend detection or expand notification methods are welcome!
