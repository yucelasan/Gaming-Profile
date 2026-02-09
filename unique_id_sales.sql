WITH cleaned AS (
  SELECT
    gameid,
    LOWER(TRIM(title)) AS title_key,
    UPPER(TRIM(platform)) AS platform_key
  FROM `gamingprofilesproject.playstation.playstation_games`
  WHERE title IS NOT NULL
    AND platform IS NOT NULL
)
SELECT
  title_key,
  platform_key,
  MIN(gameid) AS canonical_gameid,
  COUNT(*) AS duplicate_gameid_count
FROM cleaned
GROUP BY title_key, platform_key
HAVING COUNT(*) > 1
ORDER BY duplicate_gameid_count DESC;

SELECT
  playerid,
  SAFE_CAST(TRIM(gameid_str) AS INT64) AS gameid
FROM `gamingprofilesproject.playstation.playstation_purchased`,
UNNEST(
  SPLIT(
    REGEXP_REPLACE(library, r'[\[\]]', ''),
    ','
  )
) AS gameid_str
WHERE TRIM(gameid_str) != '';

WITH exploded_purchases AS (
  SELECT
    playerid,
    SAFE_CAST(TRIM(gameid_str) AS INT64) AS gameid
  FROM `gamingprofilesproject.playstation.playstation_purchased`,
  UNNEST(
    SPLIT(
      REGEXP_REPLACE(library, r'[\[\]]', ''),
      ','
    )
  ) AS gameid_str
  WHERE TRIM(gameid_str) != ''
),

games_clean AS (
  SELECT
    gameid,
    title,
    platform,
    LOWER(TRIM(title)) AS title_key,
    UPPER(TRIM(platform)) AS platform_key
  FROM `gamingprofilesproject.playstation.playstation_games`
),

canonical_map AS (
  SELECT
    title_key,
    platform_key,
    MIN(gameid) AS canonical_gameid
  FROM games_clean
  GROUP BY title_key, platform_key
)

SELECT
  cm.canonical_gameid,
  ANY_VALUE(g.title) AS title,
  ANY_VALUE(g.platform) AS platform,
  COUNT(*) AS total_sales,
  COUNT(DISTINCT p.playerid) AS unique_buyers
FROM exploded_purchases p
JOIN games_clean g
  ON p.gameid = g.gameid
JOIN canonical_map cm
  ON g.title_key = cm.title_key
 AND g.platform_key = cm.platform_key
GROUP BY cm.canonical_gameid
ORDER BY total_sales DESC;