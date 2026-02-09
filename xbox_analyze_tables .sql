-- final tablolar (xbox)

-- en çok satılan oyunlar ve revenue leri
CREATE OR REPLACE TABLE gamingprofilesproject.xbox_final.xbox_count_revenue
AS (
  SELECT
    c.game_id,
    g.title,
    c.purchase_count,
    p.usd,
    round((c.purchase_count * p.usd), 2) AS revenue
  FROM
    `gamingprofilesproject.xbox_clean.xbox_purchased_games_count`
      AS c
  JOIN `gamingprofilesproject.xbox_clean.xbox_games_clean` AS g
    ON c.game_id = g.gameid
  JOIN `gamingprofilesproject.xbox_clean.xbox_prices_clean` AS p
    ON c.game_id = p.gameid
  ORDER BY c.purchase_count DESC
);

-- publisher gelirleri
CREATE OR REPLACE TABLE gamingprofilesproject.xbox_final.xbox_publisher_count_revenue
AS (
  SELECT publisher.publisher, counts.*
  FROM
    `gamingprofilesproject.xbox_clean.xbox_publishers`
      AS publisher
  LEFT JOIN `gamingprofilesproject.xbox_final.count_revenue` AS counts
    ON publisher.gameid = counts.game_id
);

-- en çok satın alım yapan ülkeler/ xboxta ülke yokmuş 
CREATE OR REPLACE TABLE gamingprofilesproject.xbox_final.xbox_user_country
AS (
  SELECT
    lib.playerid,
    player.nickname,
    lib.game_id,
    games.title,
    price.usd
  FROM `gamingprofilesproject.xbox_clean.xbox_players_games` AS lib
  LEFT JOIN
    `gamingprofilesproject.xbox.xbox_players` AS player
    ON lib.playerid = player.playerid
  LEFT JOIN
    `gamingprofilesproject.xbox_clean.xbox_prices_clean` AS price
    ON lib.game_id = price.gameid
  LEFT JOIN
    `gamingprofilesproject.xbox_clean.xbox_games_clean` AS games
    ON lib.game_id = games.gameid
);



-- oyunların tüm oyuncular tarafından kazanılan ortalama achievemt sayıları ve oyunun toplam achievement sayısının yüzde kaçına denk geldiği
CREATE OR REPLACE TABLE gamingprofilesproject.xbox_final.xbox_achievement_ratio as 
  WITH
    player_game_stats AS (
      -- Her oyuncunun her oyunda kaç achievement kazandığını hesaplıyoruz
      SELECT
        history.game_id,
        history.playerid,
        COUNT(achievement.new_ach_id) AS earned_count
      FROM
        `gamingprofilesproject.xbox_clean.xbox_history_clean`
          AS history
      LEFT JOIN
        `gamingprofilesproject.xbox_clean.xbox_achievements_clean`
          AS achievement
        ON history.new_ach_id = achievement.new_ach_id
      GROUP BY 1, 2
    ),
    game_total_achievements AS (
      -- Her oyunun toplam kaç achievement'ı olduğunu hesaplıyoruz
      SELECT
        game_id,
        COUNT(*) AS total_nb
      FROM
        `gamingprofilesproject.xbox_clean.xbox_achievements_clean`
      GROUP BY 1
    )
  SELECT
    p.game_id,
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
    ON p.game_id = t.game_id
  JOIN `gamingprofilesproject.xbox_clean.xbox_games_clean` AS c
    ON p.game_id = c.gameid
  -- where p.gameid= 7779
  GROUP BY
    p.game_id, c.title, t.total_nb
  ORDER BY
    avg_completion_percentage DESC
; 

--Peak günler
SELECT DATE(date_acquired) AS day,
       COUNT(*) AS total_achievements
FROM `gamingprofilesproject.xbox_clean.achievement_history`
GROUP BY day;

--Bu oyuncu aktif miydi yoksa arada bir mi oynadı?
-- hesaplanabilecek kpı: Platformda bir oyuncu-gün başına ortalama kaç achievement kazanılıyor?:
--TOPLAM achievement / TOPLAM lifetime_days
SELECT
  playerid,
  COUNT(*) AS total_achievements,
  MAX(DATE(date_acquired)) as last_activity,
  MIN(DATE(date_acquired)) as first_activity,
  DATE_DIFF(
    MAX(DATE(date_acquired)),
    MIN(DATE(date_acquired)),
    DAY
  ) AS lifetime_days,
  ROUND(SAFE_DIVIDE(
    COUNT(*),
    NULLIF(--günde ortalama kaç oyun oynamış
      DATE_DIFF(
        MAX(DATE(date_acquired)),
        MIN(DATE(date_acquired)),
        DAY
      ) + 1,
      0
    )
  ),2) AS achievements_per_day
FROM `gamingprofilesproject.xbox_clean.achievement_history`
GROUP BY playerid;
