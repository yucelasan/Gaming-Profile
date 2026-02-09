
-- achievement_ratio 
CREATE OR REPLACE VIEW stores.achievement_ratio_all AS

SELECT
  gameid,
  title,
  total_achievement_count,
  avg_earned_achievement,
  avg_completion_percentage,
  'PlayStation' AS store
FROM playstation_final.achievement_ratio

UNION ALL

SELECT
  game_id,
  title,
  total_achievement_count,
  avg_earned_achievement,
  avg_completion_percentage,
  'Steam' AS store
FROM steam_final.steam_achievement_ratio

UNION ALL

SELECT
  game_id,
  title,
  total_achievement_count,
  avg_earned_achievement,
  avg_completion_percentage,
  'Xbox' AS store
FROM xbox_final.xbox_achievement_ratio

-- count_revenue
CREATE OR REPLACE VIEW stores.count_revenue_all AS

SELECT
  gameid as game_id,
  title,
  purchase_count,
  usd,
  revenue,
  'PlayStation' AS store
FROM `playstation_final.count_revenue`

UNION ALL

SELECT
  game_id,
  title,
  purchase_count,
  usd,
  revenue,
  'Steam' AS store
FROM `steam_final.steam_count_revenue`


UNION ALL

SELECT
  game_id,
  title,
  purchase_count,
  usd,
  revenue,
  'Xbox' AS store
FROM `xbox_final.xbox_count_revenue`

-- peak_days
CREATE OR REPLACE VIEW stores.peak_days_all AS

SELECT
  day,
  total_achievements,
  'PlayStation' AS store
FROM `playstation_final.peak_day`

UNION ALL

SELECT
  day,
  total_achievements,
  'Steam' AS store
FROM `steam_final.steam_peak_days`


UNION ALL

SELECT
  day,
  total_achievements,
  'Xbox' AS store
FROM `xbox_final.xbox_peak_days`


-- players_activity
CREATE OR REPLACE VIEW stores.players_activity_all AS

SELECT
  playerid as player_id,
  total_achievements,
  last_activity,
  first_activity,
  lifetime_days,	
  achievements_per_day,
  'PlayStation' AS store
FROM `playstation_final.players_activity`

UNION ALL

SELECT
  playerid as player_id,
  total_achievements,
  last_activity,
  first_activity,
  lifetime_days,	
  achievements_per_day,
  'Steam' AS store
FROM `steam_final.steam_players_activity`



UNION ALL

SELECT
  playerid as player_id,
  total_achievements,
  last_activity,
  first_activity,
  lifetime_days,	
  achievements_per_day,
  'Xbox' AS store
FROM `xbox_final.xbox_players_activity`

-- publisher_count_revenue
CREATE OR REPLACE VIEW stores.publisher_count_revenue_all AS

SELECT
  publisher,
  gameid as game_id,
  title,
  platform,
  purchase_count,	
  usd,
  revenue,
  'PlayStation' AS store
FROM `playstation_final.publisher_count_revenue`

UNION ALL

SELECT
  publisher,
  game_id,
  title,
  NULL AS platform, -- platform yok o yüzden null
  purchase_count,	
  usd,
  revenue,
  'Steam' AS store
FROM `steam_final.steam_publisher_count_revenue`



UNION ALL

SELECT
  publisher,
  game_id,
  title,
  NULL AS platform, 
  purchase_count,	
  usd,
  revenue,
  'Xbox' AS store
FROM `xbox_final.xbox_publisher_count_revenue`


-- user_country ama xboxta country yok yapmadım belki playstation ve steam için yapılabilir
CREATE OR REPLACE VIEW stores.user_country_all AS

SELECT
  publisher,
  gameid as game_id,
  title,
  platform,
  purchase_count,	
  usd,
  revenue,
  'PlayStation' AS store
FROM `playstation_final.publisher_count_revenue`

UNION ALL

SELECT
  publisher,
  game_id,
  title,
  NULL AS platform,
  purchase_count,	
  usd,
  revenue,
  'Steam' AS store
FROM `steam_final.steam_publisher_count_revenue`



UNION ALL

SELECT
  publisher,
  game_id,
  title,
  NULL AS platform,
  purchase_count,	
  usd,
  revenue,
  'Xbox' AS store
FROM `xbox_final.xbox_publisher_count_revenue`


select 
country,
count(*)
from `steam_final.steam_user_country`
group by country 
order by country 
select 
count(distinct country)
from `playstation_final.user_country`