---ktr_file: kpi_camp_report.ktr  timestamp:2014/05/28 22:53:32

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
   cl.qty_all,
   (cl.qty_all - dog.qty_send) as qty_not_valid,
   dog.qty_send,
   dog.qty_ok,
   dog.qty_hardback,
   dog.qty_softback
 from campaigns camp
 left join
 (
   select
     campaign_id as camp_id,
     count(distinct to_email) as qty_all
   from cemail_logs
   group by campaign_id
 ) cl on cl.camp_id = camp.id
 left join
 (
   select 
     campaign_id as camp_id,
     send_num    as qty_send,
     send_ok     as qty_ok,
     back_hard   as qty_hardback,
     back_soft   as qty_softback
   from dog_totle_data
 ) dog on dog.camp_id = camp.id

---ExecSql size: 2---ExecSql0
------connection: 167-report
------sql:
truncate table kpi_camp_report;

commit;---ExecSql1
------connection: 167-report
------sql:
commit;

update kpi_camp_report
set date_load = sysdate,
kpi_camp_report.qty_opens = 
(
  select sum(kth.qty_opens)
  from kpi_tracks_hours kth
  where kth.camp_id = kpi_camp_report.camp_id
),
kpi_camp_report.qty_open_accounts = 
(
  select sum(kth.qty_open_accounts)
  from kpi_tracks_hours kth
  where kth.camp_id = kpi_camp_report.camp_id
),
kpi_camp_report.qty_clicks = 
(
  select sum(kth.qty_clicks)
  from kpi_tracks_hours kth
  where kth.camp_id = kpi_camp_report.camp_id
),
kpi_camp_report.qty_click_accounts = 
(
  select sum(kth.qty_click_accounts)
  from kpi_tracks_hours kth
  where kth.camp_id = kpi_camp_report.camp_id
);

commit;
