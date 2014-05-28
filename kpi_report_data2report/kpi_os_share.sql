---ktr_file: kpi_os_share.ktr  timestamp:2014/05/28 23:12:09

---connection size: 2
---connection0
---   name     : 167-focus
---   server   : 192.168.0.167
---   type     : ORACLE
---   access   : Native
---   database : orcl
---   port     : 1521
---   username : focus
---   password : Encrypted 2be98afc86aa7f2e48d16ad65cdadff8b
---connection1
---   name     : 167-report
---   server   : 192.168.0.167
---   type     : ORACLE
---   access   : Native
---   database : orcl
---   port     : 1521
---   username : report
---   password : Encrypted 2be98afc86aa7f2e48d16ad65cdadff8b

---TableInput size: 1
---TableInput0
---   connection: 167-focus
---   sql:
select 
  camp.id as camp_id,
  camp.name as camp_name,
  click.os,
  track.qty_opens,
  track.qty_open_accounts,
  click.qty_clicks,
  click.qty_click_accounts,
  sysdate as date_load
from campaigns  camp
left join
(
  select 
    one.camp_id,
    one.os,
    count(distinct one.member_id) as qty_click_accounts,
    count(one.member_id) as qty_clicks
  from 
  (
    select 
      campaign_id as camp_id,
      member_id,
      browser,
      case 
        when instr(lower(browser), 'android') > 0 then 'android'
        when instr(lower(browser), 'linux') > 0 then 'linux'
        when instr(lower(browser), 'window') > 0 then 'window'
        when instr(lower(browser), 'iphone') > 0 or instr(lower(browser), 'ipad') > 0 then 'ios'
        when instr(lower(browser), 'mac') > 0 then 'mac'
        else 'other'
      end as os
    from clicks 
    where length(browser) > 0
  ) one
  group by one.camp_id, one.os
) click on click.camp_id = camp.id
left join
(
  select 
    one.camp_id,
    one.os,
    count(distinct one.member_id) as qty_open_accounts,
    count(one.member_id) as qty_opens
  from 
  (
    select 
      campaign_id as camp_id,
      member_id,
      browser,
      case 
        when instr(lower(browser), 'android') > 0 then 'android'
        when instr(lower(browser), 'linux') > 0 then 'linux'
        when instr(lower(browser), 'window') > 0 then 'window'
        when instr(lower(browser), 'iphone') > 0 or instr(lower(browser), 'ipad') > 0 then 'ios'
        when instr(lower(browser), 'mac') > 0 then 'mac'
        else 'other'
      end as os
    from tracks 
    where length(browser) > 0
  ) one
  group by one.camp_id, one.os
) track on track.camp_id = camp.id
where click.os = track.os
and camp.id in 
(
  select distinct ct.campaign_id from
  (
    select distinct campaign_id from clicks where to_char(created_at, 'YYYYMMDD') = to_char(sysdate-1, 'YYYYMMDD')
    union all
    select distinct campaign_id from tracks where to_char(created_at, 'YYYYMMDD') = to_char(sysdate-1, 'YYYYMMDD')
  ) ct
)


---ExecSql size: 1
---ExecSql0
---   connection: 167-report
---   sql:
-- delete the data insert today but already exist before
delete 
from kpi_os_share 
where date_load <> 
   (
      -- lastest date load
      select 
        max(date_load) as last_date_load
      from kpi_os_share 
      where to_char(date_load, 'YYYYMMDD') = to_char(sysdate, 'YYYYMMDD')
    )
and camp_id in 
  (
    -- camp_id - new insert today
    select 
      distinct camp_id 
    from kpi_os_share 
    where date_load = 
    (
      -- lastest date load
      select 
        max(date_load) as last_date_load
      from kpi_os_share 
      where to_char(date_load, 'YYYYMMDD') = to_char(sysdate, 'YYYYMMDD')
    )
  )
