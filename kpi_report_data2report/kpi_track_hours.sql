--## ktr_file: kpi_track_hours.ktr  timestamp:2014/05/29 11:31:59

--#connection size: 2
--#connection0
--#   name     : orcl-167
--#   server   : 192.168.0.167
--#   type     : ORACLE
--#   access   : Native
--#   database : orcl
--#   port     : 1521
--#   username : focus
--#   password : Encrypted 2be98afc86aa7f2e48d16ad65cdadff8b
--#connection1
--#   name     : report-167
--#   server   : 192.168.0.167
--#   type     : ORACLE
--#   access   : Native
--#   database : orcl
--#   port     : 1521
--#   username : report
--#   password : Encrypted 2be98afc86aa7f2e48d16ad65cdadff8b

--#TableInput size: 1
--#TableInput0
--#   connection: orcl-167
--#   sql:
select
  camp.id     as camp_id,
  camp.name   as camp_name,
  t.hours     as hours,
  c.hours     as hours2,
  max(t.qty_opens)          as qty_opens,
  max(t.qty_open_accounts)  as qty_open_accounts,
  max(c.qty_clicks)         as qty_clicks,
  max(c.qty_click_accounts) as qty_click_accounts,
  sysdate                   as date_load
from
  campaigns camp
left join
  (
    select
      campaign_id                as camp_id,
      to_char(created_at,'HH24') as hours,
      count(c.member_id)         as qty_clicks,
      count(distinct c.member_id)as qty_click_accounts
    from clicks c
    group by campaign_id , to_char(created_at,'HH24')
  ) c on c.camp_id = camp.id
left join
  (
    select
      t.campaign_id               as camp_id,
      to_char(t.created_at,'HH24')as hours,
      count(t.member_id)          as qty_opens,
      count(distinct t.member_id) as qty_open_accounts
    from tracks t
    group by campaign_id , to_char(created_at,'HH24')
  ) t on t.camp_id = camp.id
where
  c.hours = t.hours and
  camp.id in
  (
    --get dynamic data campaign
    --today's most new sync data is yestoday
    select
      distinct campaign_id
    from clicks
    where
      to_char(created_at, 'YYYYMMDD') = to_char(sysdate-1, 'YYYYMMDD')
    group by campaign_id)
group by
  camp.id,
  camp.name,
  c.hours,
  t.hours
order by
  camp.id,
  c.hours

--#ExecSql size: 1
--#ExecSql0
--#   connection: report-167
--#   sql:
-- delete the data insert today but already exist before
delete 
from kpi_tracks_hours 
where date_load <> 
   (
      -- lastest date load
      select 
        max(date_load) as last_date_load
      from kpi_tracks_hours 
      where to_char(date_load, 'YYYYMMDD') = to_char(sysdate, 'YYYYMMDD')
    )
and camp_id in 
  (
    -- camp_id - new insert today
    select 
      distinct camp_id 
    from kpi_tracks_hours 
    where date_load = 
    (
      -- lastest date load
      select 
        max(date_load) as last_date_load
      from kpi_tracks_hours 
      where to_char(date_load, 'YYYYMMDD') = to_char(sysdate, 'YYYYMMDD')
    )
  )
