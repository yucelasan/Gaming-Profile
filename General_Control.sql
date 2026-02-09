# kontroller
-- game clean tablosu
SELECT COUNT(*)
FROM `gamingprofilesproject.xbox_kaan_clean.xbox_games_clean`
GROUP BY
  title, developers, publishers, genres, supported_languages, release_date
HAVING COUNT(*) > 1;

-- achievement tablosu
SELECT *
FROM `gamingprofilesproject.xbox_kaan_clean.xbox_achievements_clean`
WHERE
  game_id NOT IN (
    SELECT gameid FROM `gamingprofilesproject.xbox_kaan_clean.xbox_games_clean`
  );

SELECT *
FROM `gamingprofilesproject.xbox_kaan_clean.xbox_achievements_clean`
WHERE
  game_id NOT IN (
    SELECT new_gameid
    FROM `gamingprofilesproject.xbox_kaan_clean.gameid_mapping`
  );

SELECT * FROM `gamingprofilesproject.xbox_kaan_clean.xbox_achievements_clean`;

-- history tablosu
-- history clean tablosunda olup xbox games clean tablosunda olmayan game id ler var. fakat bu id ler raw tabloda yok.
SELECT *
FROM `gamingprofilesproject.xbox_kaan_clean.xbox_history_clean`
WHERE
  game_id NOT IN (
    SELECT gameid FROM `gamingprofilesproject.xbox_kaan.xbox_games`
  );  -- kayıt yok

SELECT *
FROM `gamingprofilesproject.xbox_kaan_clean.xbox_history_clean`
WHERE
  game_id NOT IN (
    SELECT gameid FROM `gamingprofilesproject.xbox_kaan_clean.xbox_games_clean`
  );  -- kayıt var silinmeli mi ??

SELECT *
FROM `gamingprofilesproject.xbox_kaan_clean.xbox_games_clean`
WHERE gameid = 1470;

SELECT *
FROM `gamingprofilesproject.xbox_kaan_clean.xbox_history_clean`
WHERE
  playerid NOT IN (
    SELECT playerid
    FROM `gamingprofilesproject.xbox_kaan_clean.xbox_players_games`
  );  -- kayıt yok

-- NOT gameid ler kontrol edildikten sonra achievement id ler tekrar kontrol edilmeli!!!!!

## prices tablosu kontrolü

SELECT *
FROM `gamingprofilesproject.xbox_kaan_clean.xbox_prices_clean`
WHERE
  gameid NOT IN (
    SELECT gameid FROM `gamingprofilesproject.xbox_kaan_clean.xbox_games_clean`
  );

SELECT *
FROM `gamingprofilesproject.steam_clean.steam_prices_clean`
WHERE
  gameid NOT IN (
    SELECT gameid FROM `gamingprofilesproject.steam_clean.steam_games_clean`
  );

SELECT *
FROM `gamingprofilesproject.playstation_clean.playstation_prices_clean`
WHERE
  gameid NOT IN (
    SELECT gameid
    FROM `gamingprofilesproject.playstation_clean.playstation_games_clean`
  );

### players_games kontrolü
SELECT *
FROM `gamingprofilesproject.xbox_kaan_clean.xbox_players_games`
WHERE
  game_id NOT IN (
    SELECT gameid FROM `gamingprofilesproject.xbox_kaan_clean.xbox_games_clean`
  );

#### games - games clean

SELECT *
FROM `gamingprofilesproject.playstation_clean.playstation_games`;  -- 23151

SELECT *
FROM
  `gamingprofilesproject.playstation_clean.playstation_games_clean`;  -- 15247

SELECT * FROM `gamingprofilesproject.steam.steam_games`;  -- 98248

SELECT * FROM `gamingprofilesproject.steam_clean.steam_games_clean`;  -- 98143

SELECT * FROM `gamingprofilesproject.xbox_kaan.xbox_games`;  -- 10489

SELECT *
FROM `gamingprofilesproject.xbox_kaan_clean.xbox_games_clean`;  -- 10188


SELECT COUNT(*)
FROM `gamingprofilesproject.steam.steam_games`
GROUP BY
  title, developers, publishers, genres, supported_languages, release_date
HAVING COUNT(*) > 1;

SELECT COUNT(*)
FROM `gamingprofilesproject.playstation.playstation_games`
GROUP BY
  title, developers, publishers, genres, supported_languages, release_date
HAVING COUNT(*) > 1;

SELECT title as name , count (*) FROM `gamingprofilesproject.steam.steam_games` group by name having count(*)>1;  -- 98248

select *  FROM `gamingprofilesproject.steam.steam_games` where title ='Lost';

SELECT * FROM `gamingprofilesproject.steam_clean.steam_games_clean`;  -- 98143



