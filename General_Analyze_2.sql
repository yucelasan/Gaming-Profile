select h.gameid, h.playerid,h.new_ach_id,h.date_acquired,a.title,a.description,a.rarity
from `gamingprofilesproject.playstation_clean.playstation_history_clean` as h
left join `gamingprofilesproject.playstation_clean.playstation_achievement_clean` as a
on a.new_ach_id  = h.new_ach_id;

-- steam için de aynı tablo  oluşturuluyor 
select h.game_id, h.playerid,h.new_ach_id,h.date_acquired,a.title,a.description
from `gamingprofilesproject.steam_clean.steam_history_clean` as h
left join `gamingprofilesproject.steam_clean.steam_achievements_clean` as a
on a.new_ach_id  = h.new_ach_id; -- achievements tablosunda rarity yokmuş 



--Oyuncu Aktivite Seviyesi(player_name getirilebilir)
with history as (
SELECT playerid , COUNT(*) AS total_achievements
FROM `gamingprofilesproject.playstation_view.history_achievement`
GROUP BY playerid
ORDER BY total_achievements DESC
)
select
 u.*,
 h.total_achievements
from `playstation_final.user_country` as u
left join history as h using(playerid)


SELECT gameid , COUNT(*) AS total_achievements
FROM `gamingprofilesproject.playstation_view.history_achievement`
GROUP BY gameid 
ORDER BY total_achievements DESC;



--Oyuncu sadakati başarım üzerinden 
--kaç tane farklı oyunda başarılı oluyor 
SELECT playerid,
       COUNT(DISTINCT gameid) AS game_count
FROM `gamingprofilesproject.playstation_view.history_achievement`
GROUP BY playerid
Order by game_count desc;

--(uzun süredir achievement almayanlar)
SELECT playerid,
       MIN(date_acquired) AS first_ach,
       MAX(date_acquired) AS last_ach
FROM `gamingprofilesproject.playstation_view.history_achievement`
GROUP BY playerid;

--Oyun Zorluğu Analizi
SELECT gameid,
       COUNT(*) AS total_unlocks,
       COUNT(DISTINCT playerid) AS unique_players
FROM `gamingprofilesproject.playstation_view.history_achievement`
GROUP BY gameid;

--Hangi görevler yarıda bırakılıyor
SELECT gameid,
       new_ach_id,
       COUNT(DISTINCT playerid) AS unlock_count
FROM `gamingprofilesproject.playstation_view.history_achievement`
GROUP BY gameid, new_ach_id;

--Peak günler
SELECT DATE(date_acquired) AS day,
       COUNT(*) AS total_achievements
FROM `gamingprofilesproject.playstation_view.history_achievement`
GROUP BY day;



SELECT playerid,
       DATE_DIFF(date_acquired,
                 MIN(date_acquired) OVER(PARTITION BY playerid),
                 DAY) AS days_since_first
FROM `gamingprofilesproject.playstation_view.history_achievement`;


SELECT
  playerid,
  MIN(DATE(date_acquired)) AS first_ach_date,
  MAX(DATE(date_acquired)) AS last_ach_date,
  DATE_DIFF(
    MAX(DATE(date_acquired)),
    MIN(DATE(date_acquired)),
    DAY
  ) AS lifetime_days
FROM `gamingprofilesproject.playstation_view.history_achievement`
GROUP BY playerid;

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
FROM `gamingprofilesproject.playstation_view.history_achievement`
GROUP BY playerid;

--En Güçlü Oyuncu Profili
WITH base AS (
  SELECT
    playerid,
    DATE(date_acquired) AS d,
    MIN(DATE(date_acquired)) OVER (PARTITION BY playerid) AS first_d
  FROM `gamingprofilesproject.playstation_view.history_achievement`
)
SELECT
  playerid,
  COUNT(*) AS total_achievements,
  DATE_DIFF(MAX(d), MIN(d), DAY) AS lifetime_days,
  --DATE_DIFF(CURRENT_DATE(), MAX(d), DAY) AS days_since_last,
  AVG(DATE_DIFF(d, first_d, DAY)) AS avg_days_since_first
FROM base
GROUP BY playerid;


--Bir oyundaki her achievement’ın, o oyunda alınan toplam achievement’lara oranı
WITH ach_counts AS (
  SELECT
    gameid,
    new_ach_id AS achievementid,
    COUNT(*) AS ach_count
  FROM `gamingprofilesproject.playstation_view.history_achievement`
  GROUP BY gameid, achievementid
),
game_totals AS (
  SELECT
    gameid,
    SUM(ach_count) AS total_achievements_in_game
  FROM ach_counts
  GROUP BY gameid
)
SELECT
  a.gameid,
  a.achievementid,
  a.ach_count,
  g.total_achievements_in_game,
  SAFE_DIVIDE(a.ach_count, g.total_achievements_in_game) AS achievement_ratio
FROM ach_counts a
JOIN game_totals g
  ON a.gameid = g.gameid
ORDER BY gameid, achievement_ratio DESC;
'''