select
*
from `playstation.playstation_games` ;-- 23151 satır

select
*
from `playstation.playstation_games_clean` ;-- 15247 satır

## playstation tablosunda bütün kolonlar için aynı veriye sahip ama farklı gameid olan duplicates sayısı 
SELECT SUM(dup_count - 1) AS extra_duplicates
FROM (
  SELECT COUNT(*) AS dup_count
  FROM `gamingprofilesproject.playstation_clean.playstation_games`
  GROUP BY
    title,
    platform,
    developers,
    publishers,
    genres,
    supported_languages,
    release_date
  HAVING COUNT(*) > 1
); -- sonuç 7904 

## games_clean tablosuna hiç geçmeye gameid sayısı?
SELECT COUNT(*) AS removed_gameid_count
FROM `playstation_clean.playstation_games` g
LEFT JOIN `playstation_clean.playstation_games_clean` c
  ON g.gameid = c.gameid
WHERE c.gameid IS NULL; -- 7904 (sonuçlar tuttarlı mapping doğru çalışmış)

## games_clean tablosu için duplicates kontrol
SELECT
  title,
  platform,
  developers,
  publishers,
  genres,
  supported_languages,
  release_date,
  COUNT(*) AS cnt
FROM `gamingprofilesproject.playstation.playstation_games_clean`
GROUP BY
  title,
  platform,
  developers,
  publishers,
  genres,
  supported_languages,
  release_date
HAVING COUNT(*) > 1; -- satır dönmedi yani temiz

## playstation raw games tablosunda olup games_cleande olmayan 7904 adet id var (mapping sırasında değiştirilen idler)
select
 gameid 
from `playstation_clean.playstation_games` 
where gameid not in (
  select 
   gameid 
  from `playstation_clean.playstation_games_clean`
);

## değiştirilen bir id için kontrol yapalım = örn: 17667 
select 
 gameid
from `playstation.playstation_games`
where gameid = 17667
 and gameid in (
  select 
   gameid 
  from `playstation_clean.playstation_achievement_clean`
); -- yokmuş zaten olmaması lazımdı

## historyde bakalım aynı id için (17667)
select 
 gameid
from `playstation.playstation_games`
where gameid = 17667
 and gameid in (
  select 
   gameid 
  from `playstation_clean.playstation_history_clean`
); -- historyde de yokmuş 

## price için bakalım 
select 
 gameid
from `playstation.playstation_games`
where gameid = 17667
 and gameid in (
  select 
   gameid 
  from `playstation_clean.playstation_prices_clean`
); -- yokmuş

## players_games için bakalım
select 
 gameid
from `playstation.playstation_games`
where gameid = 17667
 and gameid in (
  select 
   gameid 
  from `playstation_clean.players_games_clean`
); --yokmuş

## purchased_game_count içib bakalım
select 
 gameid
from `playstation.playstation_games`
where gameid = 17667
 and gameid in (
  select 
   gameid 
  from `playstation_clean.playstation_purchased_game_count`
); --yokmuş 

## players_games_cleande olan playerid lerin hepsi playstation_players tablosunda var mı?
select 
 playerid
from `playstation_clean.players_games_clean`
where playerid not in (
  select 
   playerid
  from `playstation_clean.playstation_players`
); --hepsi var 

### clean games tablosu ile clean prices tablosu arası gameid kontrol
select
*
from `playstation_clean.playstation_prices_clean`
where gameid not in (
  select 
   gameid 
  from `playstation_clean.playstation_games_clean`
); -- satır dönmedi

### clean games tablosu ile clean achievement tablosu arası gameid kontrol
select
*
from `playstation_clean.playstation_achievement_clean`
where gameid not in (
  select 
   gameid 
  from `playstation_clean.playstation_games_clean`
); -- satır dönmedi 

### clean games tablosu ile clean history tablosu arası gameid kontrol
select
*
from `playstation_clean.playstation_history_clean`
where gameid not in (
  select 
   gameid 
  from `playstation_clean.playstation_games_clean`
); -- satır dönmedi

### clean games tablosu ile clean players_games tablosu arası gameid kontrol
select
*
from `playstation_clean.players_games_clean`
where gameid not in (
  select 
   gameid 
  from `playstation_clean.playstation_games_clean`
); -- satır dönmedi

### clean games tablosu ile clean purchase_game_count tablosu arası gameid kontrol
select
*
from `playstation_clean.playstation_purchased_game_count`
where gameid not in (
  select 
   gameid 
  from `playstation_clean.playstation_games_clean`
); -- satır dönmedi 