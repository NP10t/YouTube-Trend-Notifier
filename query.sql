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


select * from youtube_videos;


select 
video_id,
latest_by_offset(title) as title,
latest_by_offset(comments) as comments
from youtube_videos
group by video_id
EMIT CHANGES;

SELECT 
    video_id,
    latest_by_offset(title) AS title,
    latest_by_offset(comments, 2) AS comments,
    latest_by_offset(likes, 2) as likes,
    latest_by_offset(views, 2) as views,
    latest_by_offset(favorites, 2) as favorites
FROM youtube_videos
GROUP BY video_id
EMIT CHANGES;

SELECT 
    video_id,
    latest_by_offset(title) AS title,
    latest_by_offset(comments, 2)[1] AS comments_prev,        -- Giá trị trước của comments
    latest_by_offset(comments, 2)[2] AS comments_curr,        -- Giá trị hiện tại của comments
    latest_by_offset(likes, 2)[1] AS likes_prev,              -- Giá trị trước của likes
    latest_by_offset(likes, 2)[2] AS likes_curr,              -- Giá trị hiện tại của likes
    latest_by_offset(views, 2)[1] AS views_prev,              -- Giá trị trước của views
    latest_by_offset(views, 2)[2] AS views_curr,              -- Giá trị hiện tại của views
    latest_by_offset(favorites, 2)[1] AS favorites_prev,      -- Giá trị trước của favorites
    latest_by_offset(favorites, 2)[2] AS favorites_curr        -- Giá trị hiện tại của favorites
FROM youtube_videos
GROUP BY video_id
EMIT CHANGES;

    
CREATE TABLE youtube_analytics_changes with (
  KAFKA_TOPIC = 'youtube_analytics_changes' ) as
SELECT 
    video_id,
    latest_by_offset(title) AS title,
    latest_by_offset(comments, 2)[1] AS comments_prev,        -- Giá trị trước của comments
    latest_by_offset(comments, 2)[2] AS comments_curr,        -- Giá trị hiện tại của comments
    latest_by_offset(likes, 2)[1] AS likes_prev,              -- Giá trị trước của likes
    latest_by_offset(likes, 2)[2] AS likes_curr,              -- Giá trị hiện tại của likes
    latest_by_offset(views, 2)[1] AS views_prev,              -- Giá trị trước của views
    latest_by_offset(views, 2)[2] AS views_curr,              -- Giá trị hiện tại của views
    latest_by_offset(favorites, 2)[1] AS favorites_prev,      -- Giá trị trước của favorites
    latest_by_offset(favorites, 2)[2] AS favorites_curr        -- Giá trị hiện tại của favorites
FROM youtube_videos
GROUP BY video_id;



select * from YOUTUBE_analytics_changes
where comments_prev <> comments_curr
EMIT CHANGES;


select * from YOUTUBE_analytics_changes
where likes_prev <> likes_curr
EMIT CHANGES;

CREATE stream telegram_output_stream (
  `chat_id` varchar,
  `text`varchar
  ) with (kafka_topic='telegram_output_stream', PARTITIONS=1, value_format='avro');


insert into telegram_output_stream
values ('7923438082', 'Testing');

insert into telegram_output_stream
values ('7285982911', 'hshs');



CREATE STREAM youtube_analytics_stream (
    title VARCHAR,
    comments_prev VARCHAR,
    comments_curr VARCHAR,
    likes_prev INTEGER,
    likes_curr INTEGER,
    views_prev INTEGER,
    views_curr INTEGER,
    favorites_prev INTEGER,
    favorites_curr INTEGER
) WITH (
    KAFKA_TOPIC = 'youtube_analytics_changes',
    VALUE_FORMAT = 'JSON'
);

-- Trong ksqlDB, khi bạn viết một câu INSERT từ stream này sang stream khác, nó tự động được xem là persistent query mà không cần từ khóa EMIT CHANGES. Điều này khác với các câu SELECT thông thường, cần EMIT CHANGES để trở thành persistent query.
-- Ví dụ:
-- SELECT * FROM stream1; -> không phải persistent query
-- SELECT * FROM stream1 EMIT CHANGES; -> là persistent query
-- INSERT INTO stream2 SELECT * FROM stream1; -> tự động là persistent query

INSERT into telegram_output_stream
select
'7285982911' as `chat_id`,
concat('Comments changed for ',
       title,
       ' - ',
       cast(comments_prev as string),
       ':',
       cast(comments_curr as string)) as `text`
from  YOUTUBE_ANALYTICS_STREAM
WHERE comments_curr <> comments_prev;