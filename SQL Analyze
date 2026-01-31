CREATE OR REPLACE TABLE `gamingprofilesproject.xbox_kaan.gameid_mapping` AS
SELECT
  gameid AS old_gameid,
  MIN(gameid) OVER (
    PARTITION BY
      title,
      developers,
      publishers,
      genres,
      supported_languages,
      release_date
  ) AS new_gameid
FROM `gamingprofilesproject.xbox_kaan.xbox_games`;

select * from `gamingprofilesproject.xbox_kaan.gameid_mapping`
where old_gameid != new_gameid; 

CREATE OR REPLACE TABLE `gamingprofilesproject.xbox_kaan.xbox_games_clean` AS
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY
             title,
             developers,
             publishers,
             genres,
             supported_languages,
             release_date
           ORDER BY gameid
         ) AS rn
  FROM `gamingprofilesproject.xbox_kaan.xbox_games`
)
WHERE rn = 1;
