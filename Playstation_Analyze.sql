## final tabloların oluşturulması
-- en çok satılan oyunlar ve revenue leri
CREATE OR REPLACE TABLE gamingprofilesproject.playstation_final.count_revenue
AS (
  SELECT
    c.gameid,
    g.title,
    g.platform,
    c.purchase_count,
    p.usd,
    round((c.purchase_count * p.usd), 2) AS revenue
  FROM
    `gamingprofilesproject.playstation_clean.playstation_purchased_game_count`
      AS c
  JOIN `gamingprofilesproject.playstation_clean.playstation_games_clean` AS g
    ON c.gameid = g.gameid
  JOIN `gamingprofilesproject.playstation_clean.playstation_prices_clean` AS p
    ON c.gameid = p.gameid
  ORDER BY c.purchase_count DESC
);

## publisher tablosunun oluşturulması
create or replace table gamingprofilesproject.playstation_clean.playstation_publishers as 
SELECT
  gameid,
  -- Hem boşlukları hem de ' karakterlerini temizler
  TRIM(TRIM(publisher), "'") AS publisher
FROM `gamingprofilesproject.playstation_clean.playstation_games_clean`,
UNNEST(
  SPLIT(
    REGEXP_REPLACE(publishers, r'[\[\]]', ''),
    ','
  )
) AS publisher
WHERE TRIM(TRIM(publisher), "'") != '';

-- publisher gelirleri
CREATE OR REPLACE TABLE gamingprofilesproject.playstation_final.publisher_count_revenue
AS (
  SELECT publisher.publisher, counts.*
  FROM
    `gamingprofilesproject.playstation_clean.playstation_publishers`
      AS publisher
  LEFT JOIN `gamingprofilesproject.playstation_final.count_revenue` AS counts
    ON publisher.gameid = counts.gameid
);


-- en çok satın alım yapan ülkeler
CREATE OR REPLACE TABLE gamingprofilesproject.playstation_final.user_country
AS (
  SELECT
    lib.playerid,
    player.nickname,
    player.country,
    lib.gameid,
    games.platform,
    games.title,
    price.usd
  FROM `gamingprofilesproject.playstation_clean.players_games_clean` AS lib
  LEFT JOIN
    `gamingprofilesproject.playstation_clean.playstation_players` AS player
    ON lib.playerid = player.playerid
  LEFT JOIN
    `gamingprofilesproject.playstation_clean.playstation_prices_clean` AS price
    ON lib.gameid = price.gameid
  LEFT JOIN
    `gamingprofilesproject.playstation_clean.playstation_games_clean` AS games
    ON lib.gameid = games.gameid
);

-- ülke
SELECT player.country, round(sum(price.usd), 2) AS amount
FROM `gamingprofilesproject.playstation_clean.players_games_clean` AS lib
LEFT JOIN
  `gamingprofilesproject.playstation_clean.playstation_players` AS player
  ON lib.playerid = player.playerid
LEFT JOIN
  `gamingprofilesproject.playstation_clean.playstation_prices_clean` AS price
  ON lib.gameid = price.gameid
GROUP BY player.country
ORDER BY sum(price.usd) DESC;

-- player
SELECT player.playerid, round(sum(price.usd), 2) AS amount
FROM `gamingprofilesproject.playstation_clean.players_games_clean` AS lib
LEFT JOIN
  `gamingprofilesproject.playstation_clean.playstation_players` AS player
  ON lib.playerid = player.playerid
LEFT JOIN
  `gamingprofilesproject.playstation_clean.playstation_prices_clean` AS price
  ON lib.gameid = price.gameid
GROUP BY player.playerid
ORDER BY sum(price.usd) DESC;

----- achievement

SELECT gameid, COUNT(*) AS nb_of_achievement
FROM `gamingprofilesproject.playstation_clean.playstation_achievement_clean`
GROUP BY gameid
ORDER BY COUNT(*) DESC;

SELECT *
FROM `gamingprofilesproject.playstation_clean.playstation_achievement_clean`;

WITH
  nb_of_achievement AS (
    SELECT gameid, COUNT(*) AS nb
    FROM `gamingprofilesproject.playstation_clean.playstation_achievement_clean`
    GROUP BY gameid
  )
SELECT
  history.playerid,
  history.gameid,
  nb_of_achievement.nb,
  COUNT(achievement.achievement_id) AS earned_achievement_count,
  round(
    (
      safe_divide(COUNT(achievement.achievement_id), nb_of_achievement.nb)
      * 100),
    2)
    AS completion_percentage
FROM
  `gamingprofilesproject.playstation_clean.playstation_history_clean` AS history
LEFT JOIN
  `gamingprofilesproject.playstation_clean.playstation_achievement_clean`
    AS achievement
  ON history.new_ach_id = achievement.new_ach_id
LEFT JOIN nb_of_achievement
  ON nb_of_achievement.gameid = history.gameid
-- where history.playerid=78440 and history.gameid=462181
GROUP BY history.playerid, history.gameid, nb_of_achievement.nb;



##
-- oyunların tüm oyuncular tarafından kazanılan ortalama achievemt sayıları ve oyunun toplam achievement sayısının yüzde kaçına denk geldiği
CREATE OR REPLACE TABLE gamingprofilesproject.playstation_final.achievement_ratio(
  WITH
    player_game_stats AS (
      -- Her oyuncunun her oyunda kaç achievement kazandığını hesaplıyoruz
      SELECT
        history.gameid,
        history.playerid,
        COUNT(achievement.achievement_id) AS earned_count
      FROM
        `gamingprofilesproject.playstation_clean.playstation_history_clean`
          AS history
      LEFT JOIN
        `gamingprofilesproject.playstation_clean.playstation_achievement_clean`
          AS achievement
        ON history.new_ach_id = achievement.new_ach_id
      GROUP BY 1, 2
    ),
    game_total_achievements AS (
      -- Her oyunun toplam kaç achievement'ı olduğunu hesaplıyoruz
      SELECT
        gameid,
        COUNT(*) AS total_nb
      FROM
        `gamingprofilesproject.playstation_clean.playstation_achievement_clean`
      GROUP BY 1
    )
  SELECT
    p.gameid,
    c.title,
    t.total_nb AS total_achievement_count,
    -- Oyuncuların kazandığı achievement sayılarının ortalaması
    ROUND(AVG(p.earned_count), 2) AS avg_earned_achievement,
    -- Ortalama kazanma sayısının toplam sayıya oranı
    ROUND(
      SAFE_DIVIDE(AVG(p.earned_count), t.total_nb) * 100,
      2) AS avg_completion_percentage
  FROM
    player_game_stats p
  JOIN
    game_total_achievements t
    ON p.gameid = t.gameid
  JOIN `gamingprofilesproject.playstation_clean.playstation_games_clean` AS c
    ON p.gameid = c.gameid
  -- where p.gameid= 7779
  GROUP BY
    p.gameid, c.title, t.total_nb
  ORDER BY
    avg_completion_percentage DESC
); 


