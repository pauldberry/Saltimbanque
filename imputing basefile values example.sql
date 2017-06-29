### Simple basefile code, courtesy of T. Whittaker.  This is from a codetime where you and he covered 
### scoring the basefile with a new feature, and how to account for null values

-- STEP ONE -- select the vars we want, and turn factors/categoricals into 0/1 dummy vars
drop table if exists simple_basefile_step1;
create temp table simple_basefile_step1 as
select
  enterprise_id
, aff_state
, aff_name
, ideology_score
, vote2016_score
, case when party_affiliation = 'DEM' then 1 else 0 end as reg_dem
from analytics.members
where is_member is true;

-- Now calculate avg's for imputation, expanding outward from the smallest unit of interest
-- aff and state avgs
drop table if exists aff_avg;
create temp table aff_avg as
select 
  md5(aff_state||aff_name) aff_state_id
, avg(ideology_score) as ideology_score
, avg(vote2016_score) as vote2016_score
, avg(reg_dem) as reg_dem
from simple_basefile_step1
group by 1;

--state only avgs
drop table if exists state_avg;
create temp table state_avg as
select 
  md5(aff_state) state_id
, avg(ideology_score) as ideology_score
, avg(vote2016_score) as vote2016_score
, avg(reg_dem) as reg_dem
from simple_basefile_step1
group by 1;

--national avgs
drop table if exists natnl_avg;
create temp table natnl_avg as
select 
  avg(ideology_score) as ideology_score
, avg(vote2016_score) as vote2016_score
, avg(reg_dem) as reg_dem
from simple_basefile_step1;


--Now compile them expanding outward from smallest to largest area of interest, coalescing till you hit the natnl avg. IF natnl avg is null, we dont want that var anyway.
create table pberry.simple_modeling_basefile as
select distinct
a.enterprise_id
, coalesce(a.ideology_score, b.ideology_score, c.ideology_score, d.ideology_score) as ideology_score
, coalesce(a.vote2016_score, b.vote2016_score, c.vote2016_score, d.vote2016_score) as vote2016_score
, coalesce(a.reg_dem, b.reg_dem, c.reg_dem, d.reg_dem) as reg_dem
from simple_basefile_step1 a
left join aff_avg b on aff_state_id = md5(a.aff_state||a.aff_name)
left join state_avg c on state_id = md5(a.aff_state)
left join natnl_avg d on 1=1;


select * from pberry.simple_modeling_basefile order by random() limit 100
