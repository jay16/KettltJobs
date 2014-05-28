---ktr_file: kpi_domain_share.ktr  timestamp:2014/05/28 22:53:32

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
  cl.camp_id,
  cl.camp_name,
  cl.domains,
  cl.qty_accounts,
  track.qty_opens,
  track.qty_open_accounts,
  click.qty_clicks,
  click.qty_click_accounts,
  sysdate as date_load
from 
(
  select 
    two.camp_id,
    two.camp_name,
    two.domain as domains,
    count(two.domain) as qty_accounts
  from
  (
    select 
      one.camp_name,
      one.camp_id,
      case 
        when one.d = 'qq.com' or one.d = 'vip.qq.com' or one.d = 'foxmail.com' then 'qq' 
        when one.d = '126.com' or one.d = 'vip.126.com' or one.d = '163.com' or one.d = 'vip.163.com' then '163'
        when one.d = 'yahoo.com' or one.d = 'yahoo.com.cn' or one.d = 'yahoo.cn' then 'yahoo'
        when one.d = 'hotmail.com' or one.d = 'msn.com' then 'hotmail'
        when one.d = 'gmail.com' then 'gmail'
        when one.d = 'sohu.com' then 'sohu'
        when one.d = 'sina.com' or one.d = 'sina.com.cn' or one.d = 'sina.cn' then 'sina'
        else 'other' 
      end as domain
    from
    (
      select 
        subject as camp_name,
        campaign_id as camp_id,
        lower(substr(to_email,instr(to_email,'@' )+1 ,length(to_email)-instr(to_email, '@'))) as d
      from cemail_logs
    ) one
  ) two
  group by two.camp_id, two.camp_name, two.domain
) cl
left join
(
    select 
      two.camp_id,
      two.domain as domains,
      count(two.member_id) as qty_opens,
      count(distinct two.member_id) as qty_open_accounts
    from
    (
    select 
      one.camp_id,
      one.member_id,
      case 
        when one.d = 'qq.com' or one.d = 'vip.qq.com' or one.d = 'foxmail.com' then 'qq' 
        when one.d = '126.com' or one.d = 'vip.126.com' or one.d = '163.com' or one.d = 'vip.163.com' then '163'
        when one.d = 'yahoo.com' or one.d = 'yahoo.com.cn' or one.d = 'yahoo.cn' then 'yahoo'
        when one.d = 'hotmail.com' or one.d = 'msn.com' then 'hotmail'
        when one.d = 'gmail.com' then 'gmail'
        when one.d = 'sohu.com' then 'sohu'
        when one.d = 'sina.com' or one.d = 'sina.com.cn' or one.d = 'sina.cn' then 'sina'
        else 'other' 
      end as domain
     from
     (
       select 
         tracks.campaign_id as camp_id,
         tracks.member_id,
         lower(substr(members.email,instr(members.email,'@' )+1 ,length(members.email)-instr(members.email, '@'))) as d
       from tracks, members
       where tracks.member_id = members.id
     ) one
     ) two
     group by two.camp_id, two.domain
) track on track.camp_id = cl.camp_id and track.domains = cl.domains
left join
(
    select 
      two.camp_id,
      two.domain as domains,
      count(two.member_id) as qty_clicks,
      count(distinct two.member_id) as qty_click_accounts
    from
    (
    select 
      one.camp_id,
      one.member_id,
      case 
        when one.d = 'qq.com' or one.d = 'vip.qq.com' or one.d = 'foxmail.com' then 'qq' 
        when one.d = '126.com' or one.d = 'vip.126.com' or one.d = '163.com' or one.d = 'vip.163.com' then '163'
        when one.d = 'yahoo.com' or one.d = 'yahoo.com.cn' or one.d = 'yahoo.cn' then 'yahoo'
        when one.d = 'hotmail.com' or one.d = 'msn.com' then 'hotmail'
        when one.d = 'gmail.com' then 'gmail'
        when one.d = 'sohu.com' then 'sohu'
        when one.d = 'sina.com' or one.d = 'sina.com.cn' or one.d = 'sina.cn' then 'sina'
        else 'other' 
      end as domain
     from
     (
       select 
         clicks.campaign_id as camp_id,
         clicks.member_id,
         lower(substr(members.email,instr(members.email,'@' )+1 ,length(members.email)-instr(members.email, '@'))) as d
       from clicks, members
       where clicks.member_id = members.id
     ) one
     ) two
     group by two.camp_id, two.domain
) click on click.camp_id = cl.camp_id and click.domains = cl.domains
where cl.camp_id in 
(
  select 
    distinct campaign_id
  from cemail_logs
  where to_char(created_at, 'YYYYMMDD') = to_char(sysdate-1, 'YYYYMMDD')
)
---ExecSql size: 1---ExecSql0
------connection: 167-report
------sql:
-- delete the data insert today but already exist before
delete 
from kpi_domain_share 
where date_load <> 
   (
      -- lastest date load
      select 
        max(date_load) as last_date_load
      from kpi_domain_share 
      where to_char(date_load, 'YYYYMMDD') = to_char(sysdate, 'YYYYMMDD')
    )
and camp_id in 
  (
    -- camp_id - new insert today
    select 
      distinct camp_id 
    from kpi_domain_share 
    where date_load = 
    (
      -- lastest date load
      select 
        max(date_load) as last_date_load
      from kpi_domain_share 
      where to_char(date_load, 'YYYYMMDD') = to_char(sysdate, 'YYYYMMDD')
    )
  )
