## achievement tablo incelemesi

SELECT achievement_id, COUNT(*)
FROM `gamingprofilesproject.playstation.playstation_achievement_split`
GROUP BY achievement_id
HAVING COUNT(*) > 1;

## olmayan id ler ghost game id olarak kaydedildi
SELECT DISTINCT a.game_id
FROM `gamingprofilesproject.playstation.playstation_achievement_split` AS a
LEFT JOIN `gamingprofilesproject.playstation.playstation_games` AS b
  ON a.game_id = b.gameid
WHERE b.gameid IS NULL;

delete
FROM `gamingprofilesproject.playstation.playstation_achievements`
WHERE
  gameid IN (
    SELECT game_id FROM `gamingprofilesproject.playstation.ghost_game_ids`
  );

## history tablo incelemesi

SELECT
  playerid,
  achievementid,
  CAST(SPLIT(achievementid, '_')[OFFSET(0)] AS int64) AS game_id,
  CAST(SPLIT(achievementid, '_')[OFFSET(1)] AS int64) AS achievement_id,
  date_acquired
FROM `gamingprofilesproject.playstation.playstation_history`;


SELECT DISTINCT a.game_id
FROM `gamingprofilesproject.playstation.playstation_history_split2` AS a
LEFT JOIN `gamingprofilesproject.playstation.playstation_games` AS b
  ON a.game_id = b.gameid
WHERE b.gameid IS NULL;

DELETE FROM `gamingprofilesproject.playstation.playstation_history_split2`
WHERE
  game_id IN (
    SELECT DISTINCT a.game_id
    FROM `gamingprofilesproject.playstation.playstation_history_split` AS a
    LEFT JOIN `gamingprofilesproject.playstation.playstation_games` AS b
      ON a.game_id = b.gameid
    WHERE b.gameid IS NULL
  );


# purchase tablsounda olan gameid lerin 7231 tanesi için games tablosunda veri yok/listesi
delete from `playstation.playstation_purchased_games_count2` where game_id in (
  SELECT 
    c.game_id
  FROM `gamingprofilesproject.playstation.playstation_purchased_games_count` c
  LEFT JOIN `gamingprofilesproject.playstation.playstation_games` g
    ON g.gameid = c.game_id
  WHERE g.gameid IS NULL );

# price tablosunda olan ama gameste olmayan gameid ler silindi 
delete from `playstation.playstation_prices` where gameid in (
SELECT 
    c.gameid
  FROM `gamingprofilesproject.playstation.playstation_prices` c
  LEFT JOIN `gamingprofilesproject.playstation.playstation_games` g
    ON g.gameid = c.gameid
  WHERE g.gameid IS NULL 
);

#satın alınan oyunların toplam sayısı json dan çıkartılarak hesaplandı ve purchased game count tablosu olarak kaydedildi

SELECT 
    TRIM(game_id) as game_id, -- Boşlukları temizler
    COUNT(*) as purchase_count
FROM 
    `gamingprofilesproject.playstation_clean.playstation_purchased`,
    UNNEST(SPLIT(TRIM(library, '[]'), ',')) AS game_id
GROUP BY 
    1
ORDER BY 
    purchase_count DESC;

#players_games tablosu oluşturuldu. bu tabloda olmayan gameid lere ait kayıtlar silindi

SELECT
  playerid,
  SAFE_CAST(TRIM(gameid_str) AS INT64) AS gameid
FROM `gamingprofilesproject.playstation_clean.playstation_library`,
UNNEST(
  SPLIT(
    REGEXP_REPLACE(library, r'[\[\]]', ''),
    ','
  )
) AS gameid_str
WHERE TRIM(gameid_str) != ''; 


delete from `gamingprofilesproject.playstation_clean.players_games` where gameid not in (select gameid from `gamingprofilesproject.playstation_clean.playstation_games`) --2.200.613

select count(*) from `gamingprofilesproject.playstation_clean.players_games` --10.893.552


## price tablosundaki oyunlara ait en güncel fiyatları tablonun üzerine yazdık
create or replace table gamingprofilesproject.playstation_clean.playstation_prices_clean as (
WITH RankedPrices AS (
  SELECT 
    gameid, 
    usd,
    eur,
    gbp,
    jpy,
    rub, 
    date_acquired,
    -- Her game_id için tarihleri en yeniden en eskiye sıralayıp numara verir
    ROW_NUMBER() OVER(PARTITION BY gameid ORDER BY date_acquired DESC) as rn
  FROM 
    `gamingprofilesproject.playstation_clean.playstation_prices_clean`
)
SELECT 
    gameid, 
    usd,
    eur,
    gbp,
    jpy,
    rub,  
    date_acquired
FROM 
    RankedPrices
WHERE 
    rn = 1); -- Sadece her oyunun en güncel (1 numaralı) satırını getir

------


UPDATE `gamingprofilesproject.playstation_clean.playstation_prices_clean`
SET usd = ROUND(
  COALESCE(
    usd,
    eur * 1.08,
    gbp * 1.27,
    jpy * 0.0067,
    rub * 0.011,
    0
  ),
  2
)
WHERE usd IS NULL;

select * from `gamingprofilesproject.playstation_clean.playstation_prices_clean`;

