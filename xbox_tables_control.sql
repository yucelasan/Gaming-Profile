select
*
from `xbox_kaan.xbox_games`; -- 10489 satır 

select
*
from `xbox_kaan.xbox_games_clean`; -- 10188 satır 

## xbox games tablsounda bütün kolonlarda aynı veriye sahip ama farklı game id olan kaç tane değer var?
SELECT SUM(dup_count) AS total_duplicate_rows
FROM (
  SELECT COUNT(*) AS dup_count
  FROM `xbox_kaan.xbox_games`
  GROUP BY
    title, developers, publishers, genres, supported_languages, release_date
  HAVING COUNT(*) > 1
); -- 575 tane 

## xbox games tablosunda bütün kolonlar için aynı veriye sahip ama farklı gameid olan duplicates sayısı 
SELECT SUM(dup_count - 1) AS extra_duplicates
FROM (
  SELECT COUNT(*) AS dup_count
  FROM `xbox_kaan.xbox_games`
  GROUP BY
    title,
    developers,
    publishers,
    genres,
    supported_languages,
    release_date
  HAVING COUNT(*) > 1
); -- 301 tane 

## games_clean tablosuna hiç geçmeye gameid sayısı?
SELECT COUNT(*) AS removed_gameid_count
FROM `xbox_kaan.xbox_games` g
LEFT JOIN `xbox_kaan_clean.xbox_games_clean` c
  ON g.gameid = c.gameid
WHERE c.gameid IS NULL; -- 301 (sonuçlar tuttarlı mapping doğru çalışmış)

## games_clean tablosu için duplicates kontrol
SELECT
  title,
  developers,
  publishers,
  genres,
  supported_languages,
  release_date,
  COUNT(*) AS cnt
FROM `xbox_kaan_clean.xbox_games_clean`
GROUP BY
  title,
  developers,
  publishers,
  genres,
  supported_languages,
  release_date ; -- satır dönmedi 

## xbox raw games tablosunda olup games_cleande olmayan idler (mapping sırasında değiştirilen idler)
select
 gameid 
from `xbox_kaan.xbox_games`
where gameid not in (
  select 
   gameid 
  from `xbox_kaan.xbox_games_clean`
); -- 301 tane sonuçlar tutarlı 

## değiştirilen bir id için kontrol yapalım = örn: 667239
select 
 gameid
from `xbox_kaan.xbox_games` 
where gameid = 667239
 and gameid in (
  select 
   game_id 
  from `xbox_kaan_clean.xbox_achievements_clean`
); -- achievement doğru temizlenmiş

## historyde bakalım aynı id için (667239)
select 
 gameid
from `xbox_kaan.xbox_games` 
where gameid = 667239
 and gameid in (
  select 
   game_id 
  from `xbox_kaan_clean.xbox_history_clean`
); -- history temizlenmemiş 

## price için bakalım 
select 
 gameid
from  `xbox_clean.xbox_prices_clean`
where gameid = 667239
 and gameid in (
  select 
   gameid 
  from `xbox_kaan.xbox_games`
); -- prices temizlenmemiş 

## players_games için 
select 
 gameid
from `xbox_kaan.xbox_games`
where gameid = 667239
 and gameid in (
  select 
   game_id 
  from `xbox_kaan_clean.xbox_players_games`
); -- temizlenmemiş 

## purchased_game_count içib bakalım
select 
 gameid
from `xbox_kaan.xbox_games`
where gameid = 667239
 and gameid in (
  select 
   game_id 
  from `xbox_kaan_clean.xbox_purchased_games_count`
); -- temiz 

## players_games_cleande olan playerid lerin hepsi steam_players tablosunda var mı?
select 
 playerid
from `xbox_kaan_clean.xbox_players_games`
where playerid not in (
  select 
   playerid
  from `xbox_kaan.xbox_players`
); -- hepsi var 

### clean games tablosu ile clean prices tablosu arası gameid kontrol
select
*
from `xbox_kaan_clean.xbox_prices_clean`
where gameid not in (
  select 
   gameid 
  from `xbox_kaan_clean.xbox_games_clean`
); -- 602 saatır döndü yani mapping uygulanmamış 

### clean games tablosu ile clean achievement tablosu arası gameid kontrol
select
count(*)
from `xbox_clean.xbox_achievements_clean`
where game_id not in (
  select 
   game_id 
  from  `xbox_clean.xbox_games_clean`
); -- satır dönmedi achievement tablosu mapping başarılı 

### clean games tablosu ile clean history tablosu arası gameid kontrol
SELECT *
FROM `xbox_clean.xbox_history_clean` h
WHERE NOT EXISTS (
  SELECT 1
  FROM `xbox_clean.xbox_games_clean` g
  WHERE g.gameid = h.game_id
); -- satır dönmedi 

### clean games tablosu ile clean players_games tablosu arası gameid kontrol 
SELECT *
FROM `xbox_clean.xbox_players_games` sp
WHERE NOT EXISTS (
  SELECT 1
  FROM `xbox_clean.xbox_games_clean` g
  WHERE g.gameid = sp.game_id
); -- satır dönmedi 

### clean games tablosu ile clean purchase_game_count tablosu arası gameid kontrol
select
*
from `xbox_clean.xbox_purchased_games_count`
where game_id not in (
  select 
   game_id 
  from `xbox_clean.xbox_games_clean` 
); -- satır dönmedi mapping yapılmış  


