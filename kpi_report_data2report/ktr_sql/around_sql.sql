-- vip.qq.com qq.com foxmail.com
-- sina.com vip.sina.com sina.com.cn sina.cn
-- gmail.com
-- yahoo.cn yahoo.com.hk yahoo.com.cn yahoo.com.vn yahoo.com.tw yahoo.com.sg yahoo.com.au yahoo.ca yahoo.com yahoo.cn
-- yahoo.co yahoo.co.uk yahoo.co.id yahoo.co.jp
-- hotmail.com msn.com
-- 163.com vip.163.com 126.com
-- 163.net (tom vip) top.com
-- sohu.com vip.sohu.com
-- 表空间 focus
-- 从发信log中按域名分类
select 
  distinct lower(substr(to_email,instr(to_email,'@' )+1 ,length(to_email)-instr(to_email, '@'))) as d
from dog_totle_bi 
where campaign_id = 335
and log_cm = 'OK'
and  instr(lower(substr(to_email,instr(to_email,'@' )+1 ,length(to_email)-instr(to_email, '@'))), 'gmail') > 0


-- os为other:
-- Mozilla/5.0 (compatible; Baiduspider/2.0; +http://www.baidu.com/search/spider.html)
-- Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)
-- Mozilla/4.0 (占大多数)
-- 表空间 focus
-- 根据remote-browser 判断系统类型
select 
  browser,
  os
from
(
    select 
      campaign_id as camp_id,
      member_id,
      browser,
      case 
        when instr(lower(browser), 'android') > 0 then 'android'
        when instr(lower(browser), 'linux') > 0 then 'linux'
        when instr(lower(browser), 'window') > 0 or instr(lower(browser), 'win32') > 0 then 'window'
        when instr(lower(browser), 'iphone') > 0 or instr(lower(browser), 'ipad') > 0 then 'ios'
        when instr(lower(browser), 'mac') > 0 then 'mac'
        else 'other'
      end as os
    from clicks 
    where length(browser) > 0
) tmp where os = 'other'

-- 表空间 focus
-- 根据remote-browser 判断浏览器类型
select 
  browser, 
  browser_brand
from 
(
  select 
    campaign_id as camp_id,
    member_id,
    browser,
    case 
      when instr(lower(browser), 'msie') > 0 then 'ie'
      when instr(lower(browser), 'chrome') > 0 then 'chrome'
      when instr(lower(browser), 'firefox') > 0 then 'firefox'
      when instr(lower(browser), 'safari') > 0 then 'safari'
      when instr(lower(browser), 'opera') > 0 then 'opera'
      when instr(lower(browser), 'qq') > 0 then 'qq'
      else 'other'
    end as browser_brand
  from clicks 
  where length(browser) > 0
) one where browser_brand = 'other'
