WITH --ach_day_count
  obs_dates AS (
    SELECT obs_date
    FROM UNNEST([
      DATE '2024-07-01',
      DATE '2024-08-01',
      DATE '2024-09-01'
    ]) AS obs_date
  ),

  -- Daily activity: senin tablon
  daily AS (
    SELECT
      playerid,
      DATE(date_acquired) AS activity_date,
      total_achievement AS achievements_earned
    FROM `gamingprofilesproject.playstation_clean.playstation_ach_day_count`
  ),

  -- İlk aktivite (lifetime için)
  first_seen AS (
    SELECT
      playerid,
      MIN(activity_date) AS first_activity_date
    FROM daily
    GROUP BY 1
  ),

  -- Observation date'e kadar feature'lar
  features AS (
    SELECT
      d.playerid,
      o.obs_date,

      MAX(IF(d.activity_date <= o.obs_date, d.activity_date, NULL)) AS last_activity_until_obs,

      DATE_DIFF(o.obs_date, f.first_activity_date, DAY) AS lifetime_days,

      SUM(IF(d.activity_date <= o.obs_date, d.achievements_earned, 0)) AS total_achievements,

      SUM(
        IF(
          d.activity_date BETWEEN DATE_SUB(o.obs_date, INTERVAL 29 DAY) AND o.obs_date,
          d.achievements_earned,
          0
        )
      ) AS ach_last_30d,

      DATE_DIFF(
        o.obs_date,
        MAX(IF(d.activity_date <= o.obs_date, d.activity_date, NULL)),
        DAY
      ) AS days_since_last_activity

    FROM daily d
    CROSS JOIN obs_dates o
    JOIN first_seen f USING (playerid)
    GROUP BY 1, 2, f.first_activity_date
  ),

  -- Velocity + flag
  features_enriched AS (
    SELECT
      *,
      SAFE_DIVIDE(ach_last_30d, 30) AS achievements_per_day_30d,
      LOG(1 + SAFE_DIVIDE(ach_last_30d, 30)) AS log_achievements_per_day,
      CASE WHEN days_since_last_activity <= 30 THEN 1 ELSE 0 END AS is_recent_active
    FROM features
  ),

  -- obs_date bazlı P75 threshold'lar
  thresholds AS (
    SELECT
      obs_date,
      APPROX_QUANTILES(total_achievements, 4)[OFFSET(3)] AS total_ach_p75,
      APPROX_QUANTILES(log_achievements_per_day, 4)[OFFSET(3)] AS log_ach_p75
    FROM features_enriched
    WHERE log_achievements_per_day IS NOT NULL
    GROUP BY 1
  ),

  -- Core score
  scored AS (
    SELECT
      fe.*,
      CASE WHEN fe.total_achievements >= t.total_ach_p75 THEN 1 ELSE 0 END AS high_total_achievement,
      CASE WHEN fe.log_achievements_per_day >= t.log_ach_p75 THEN 1 ELSE 0 END AS high_achievement_velocity,
      (
        CASE WHEN fe.days_since_last_activity <= 30 THEN 1 ELSE 0 END +
        CASE WHEN fe.total_achievements >= t.total_ach_p75 THEN 1 ELSE 0 END +
        CASE WHEN fe.log_achievements_per_day >= t.log_ach_p75 THEN 1 ELSE 0 END +
        CASE WHEN fe.lifetime_days >= 750 AND fe.days_since_last_activity <= 120 THEN 1 ELSE 0 END
      ) AS core_score
    FROM features_enriched fe
    LEFT JOIN thresholds t
    USING (obs_date)
  ),

  -- Label: obs_date sonrası 120 gün içinde hiç aktivite yoksa churn=1
  labels AS (
    SELECT
      s.playerid,
      s.obs_date,
      IF(
        COUNTIF(
          d.activity_date BETWEEN DATE_ADD(s.obs_date, INTERVAL 1 DAY)
          AND DATE_ADD(s.obs_date, INTERVAL 120 DAY)
        ) = 0,
        1,
        0
      ) AS churn_120
    FROM scored s
    LEFT JOIN daily d
      ON d.playerid = s.playerid
    GROUP BY 1, 2
  )

SELECT
  s.playerid,
  s.obs_date,

  -- MODELE GİRECEK FEATURE’LAR
  s.total_achievements,
  s.log_achievements_per_day,
  s.lifetime_days,
  s.core_score,
  s.is_recent_active,

  -- MODELE GİRMEYECEK (analiz için kalsın)
  s.days_since_last_activity,
  s.last_activity_until_obs,

  -- TARGET
  l.churn_120

FROM scored s
JOIN labels l
USING (playerid, obs_date);