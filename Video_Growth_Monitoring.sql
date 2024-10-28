CREATE STREAM youtube_videos (
    video_id VARCHAR KEY,
    title VARCHAR,
    likes INTEGER,
    comments INTEGER,
    views INTEGER,
    favorites INTEGER,
    thumbnail VARCHAR
) WITH (
    KAFKA_TOPIC = 'youtube_videos',
    PARTITIONS = 1,
    VALUE_FORMAT = 'json'
);


CREATE TABLE youtube_trend_analysis WITH (
  KAFKA_TOPIC = 'youtube_trend_analysis' 
) AS
SELECT 
    video_id,
    latest_by_offset(title) AS title,
    -- Current values
    latest_by_offset(views, 2)[2] AS views_curr,
    latest_by_offset(likes, 2)[2] AS likes_curr,
    latest_by_offset(comments, 2)[2] AS comments_curr,
    -- Previous values
    latest_by_offset(views, 2)[1] AS views_prev,
    latest_by_offset(likes, 2)[1] AS likes_prev,
    latest_by_offset(comments, 2)[1] AS comments_prev,
    -- Growth rate calculations with type casting to DOUBLE
    COALESCE(
        (CAST(latest_by_offset(views, 2)[2] AS DOUBLE) - CAST(latest_by_offset(views, 2)[1] AS DOUBLE)) / 
        NULLIF(CAST(latest_by_offset(views, 2)[1] AS DOUBLE), CAST(0 AS DOUBLE)) * 100, 
        CAST(0 AS DOUBLE)
    ) AS views_growth_rate,
    COALESCE(
        (CAST(latest_by_offset(likes, 2)[2] AS DOUBLE) - CAST(latest_by_offset(likes, 2)[1] AS DOUBLE)) / 
        NULLIF(CAST(latest_by_offset(likes, 2)[1] AS DOUBLE), CAST(0 AS DOUBLE)) * 100, 
        CAST(0 AS DOUBLE)
    ) AS likes_growth_rate,
    COALESCE(
        (CAST(latest_by_offset(comments, 2)[2] AS DOUBLE) - CAST(latest_by_offset(comments, 2)[1] AS DOUBLE)) / 
        NULLIF(CAST(latest_by_offset(comments, 2)[1] AS DOUBLE), CAST(0 AS DOUBLE)) * 100, 
        CAST(0 AS DOUBLE)
    ) AS comments_growth_rate
FROM youtube_videos
GROUP BY video_id;




CREATE stream telegram_output_stream (
  `chat_id` varchar,
  `text`varchar
  ) with (kafka_topic='telegram_output_stream', PARTITIONS=1, value_format='avro');



CREATE STREAM youtube_trend_analysis_stream (
    title VARCHAR,
    comments_prev VARCHAR,
    comments_curr VARCHAR,
    likes_prev INTEGER,
    likes_curr INTEGER,
    views_prev INTEGER,
    views_curr INTEGER,
    favorites_prev INTEGER,
    favorites_curr INTEGER,
    views_growth_rate DOUBLE,
    likes_growth_rate DOUBLE,
    comments_growth_rate DOUBLE
) WITH (
    KAFKA_TOPIC = 'youtube_trend_analysis',
    VALUE_FORMAT = 'JSON'
);

INSERT INTO telegram_output_stream
SELECT 
    '7285982911' AS `chat_id`,
    CONCAT(
        'Video ', title, ' is trending!\n',
        'Views growth rate: ', CAST(views_growth_rate AS STRING), '%\n',
        'Likes growth rate: ', CAST(likes_growth_rate AS STRING), '%\n',
        'Comments growth rate: ', CAST(comments_growth_rate AS STRING), '%'
    ) AS `text`
FROM youtube_trend_analysis_stream
WHERE (comments_growth_rate * 1000) % 2 = 0;

WHERE views_growth_rate > 10 OR likes_growth_rate > 10 OR comments_growth_rate > 10;


INSERT INTO telegram_output_stream
SELECT 
    '7285982911' AS `chat_id`,
    CONCAT(
        'Video ', title, ' is no longer trending.\n',
        'Views growth rate: ', CAST(views_growth_rate AS STRING), '%\n',
        'Likes growth rate: ', CAST(likes_growth_rate AS STRING), '%\n',
        'Comments growth rate: ', CAST(comments_growth_rate AS STRING), '%'
    ) AS `text`
FROM youtube_trend_analysis_stream
WHERE (comments_growth_rate * 1000) % 2 <> 0;

WHERE views_growth_rate < 1 AND likes_growth_rate < 1 AND comments_growth_rate < 1;


-- CREATE TABLE video_trend_timeline AS
-- SELECT 
--     video_id,
--     title,
--     ROWTIME AS trend_time,
--     views_curr AS current_views,
--     likes_curr AS current_likes,
--     comments_curr AS current_comments,
--     views_growth_rate,
--     likes_growth_rate,
--     comments_growth_rate
-- FROM youtube_trend_analysis
-- EMIT CHANGES;
