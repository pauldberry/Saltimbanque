--Start Voter File tables
-- First table: VF first name and VF year of birth
drop table if exists vf_yob;
create temp table vf_yob as
select 
  vb_tsmart_first_name as fname
, left(vb_voterbase_dob,4) as yob
, count(case when vb_voterbase_gender = 'Female' then 1 else null end)::float/count(*) vf_yob_fname_pct
from ts.usa
where vb_voterbase_gender_source = 'Voter File' and vb_voterbase_gender != 'Unknown'
and vb_voterbase_dob_source = 'Voter File' and vb_voterbase_dob is not null
group by 1,2;

-- Second table: VF first name and VF decade
drop table if exists vf_decade;
create temp table vf_decade as
select 
  vb_tsmart_first_name as fname
, left(vb_voterbase_dob,3)||0 as birth_decade
, count(case when vb_voterbase_gender = 'Female' then 1 else null end)::float/count(*) vf_decade_fname_pct
from ts.usa
where vb_voterbase_gender_source = 'Voter File' and vb_voterbase_gender != 'Unknown'
and vb_voterbase_dob_source = 'Voter File' and vb_voterbase_dob is not null
group by 1,2;

-- Third table: VF first name
drop table if exists vf_fname;
create temp table vf_fname as
select 
  vb_tsmart_first_name as fname
, count(case when vb_voterbase_gender = 'Female' then 1 else null end)::float/count(*) vf_fname_pct
from ts.usa
where vb_voterbase_gender_source = 'Voter File' and vb_voterbase_gender != 'Unknown'
group by 1;

-- Fourth table: VF first name 3 letters
drop table if exists vf_fname3;
create temp table vf_fname3 as
select 
  left(vb_tsmart_first_name,3) as left_3_fname
, count(case when vb_voterbase_gender = 'Female' then 1 else null end)::float/count(*) vf_left_3_fname_pct
from ts.usa
where vb_voterbase_gender_source = 'Voter File' and vb_voterbase_gender != 'Unknown'
group by 1;

-- Fifth table: VF first name 2 letters
drop table if exists vf_fname2;
create temp table vf_fname2 as
select 
  left(vb_tsmart_first_name,2) as left_2_fname
, count(case when vb_voterbase_gender = 'Female' then 1 else null end)::float/count(*) vf_left_2_fname_pct
from ts.usa
where vb_voterbase_gender_source = 'Voter File' and vb_voterbase_gender != 'Unknown'
group by 1;

-- Sixth table: VF first name 1 letter
drop table if exists vf_fname1;
create temp table vf_fname1 as
select 
  left(vb_tsmart_first_name,2) as left_1_fname
, count(case when vb_voterbase_gender = 'Female' then 1 else null end)::float/count(*) vf_left_1_fname_pct
from ts.usa
where vb_voterbase_gender_source = 'Voter File' and vb_voterbase_gender != 'Unknown'
group by 1;

--Start SSA tables
-- First table: SSA first name and VF year of birth
drop table if exists ssa_yob;
create temp table ssa_yob as
select
  first_name as ssn_fname
, left(right(file_name,8),4) as yob
, sum(case when gender = 'F' then births else 0 end::float)/sum(births) ssn_yob_fem_pct
from modeling_staging.ssa_raw
group by 1,2
order by 1,2;

-- Second table: SSA first name and VF decade
drop table if exists ssa_decade;
create temp table ssa_decade as
select
  first_name as ssn_fname
, left(right(file_name,8),3)||0 as decade
, sum(case when gender = 'F' then births else 0 end::float)/sum(births) ssn_decade_fem_pct
from modeling_staging.ssa_raw
group by 1,2
order by 1,2;

-- Third table: SSA first name
drop table if exists ssa_fname;
create temp table ssa_fname as
select
  first_name as ssn_fname
, sum(case when gender = 'F' then births else 0 end::float)/sum(births) ssn_fname_fem_pct
from modeling_staging.ssa_raw
group by 1
order by 1;

-- Fourth table: SSA first name 3 letters
drop table if exists ssa_fname3;
create temp table ssa_fname3 as
select
  left(first_name, 3) as left3_ssn_fname
, sum(case when gender = 'F' then births else 0 end::float)/sum(births) ssn_3_thirdchar_pct
from modeling_staging.ssa_raw
group by 1
order by 1;

-- Fifth table: SSA first name 2 letters
drop table if exists ssa_fname2;
create temp table ssa_fname2 as
select
  left(first_name, 2) as left2_ssn_fname
, sum(case when gender = 'F' then births else 0 end::float)/sum(births) ssn_2_secondchar_pct
from modeling_staging.ssa_raw
group by 1
order by 1;

-- Sixth table: SSA first name 1 letter
drop table if exists ssa_fname1;
create temp table ssa_fname1 as
select
  left(first_name, 1) as left1_ssn_fname
, sum(case when gender = 'F' then births else 0 end::float)/sum(births) ssn_1_firstchar_pct
from modeling_staging.ssa_raw
group by 1
order by 1;

drop table if exists gender_basefile01;
create temp table gender_basefile01 sortkey (enterprise_id) as
select distinct 
  a.enterprise_id
, a.dob
, b.yob
, c.birth_decade as vf_birth_decade
, b.vf_yob_fname_pct
, c.vf_decade_fname_pct
, d.vf_fname_pct
, e.vf_left_3_fname_pct
, f.vf_left_2_fname_pct
, g.vf_left_1_fname_pct
, h.ssn_yob_fem_pct
, i.ssn_decade_fem_pct
, j.ssn_fname_fem_pct
, k.ssn_3_thirdchar_pct
, m.ssn_2_secondchar_pct
, n.ssn_1_firstchar_pct
, case when b.fname is not null then 1 else 0 end as vf_dob_name_match
, case when c.fname is not null then 1 else 0 end as vf_decade_name_match
, case when d.fname is not null then 1 else 0 end as vf_name_match
, case when e.left_3_fname is not null then 1 else 0 end as vf_first_3_name_match
, case when f.left_2_fname is not null then 1 else 0 end as vf_first_2_name_match
, case when g.left_1_fname is not null then 1 else 0 end as vf_first_1_name_match
, case when h.ssn_fname is not null then 1 else 0 end as ssn_dob_name_match
, case when i.ssn_fname is not null then 1 else 0 end as ssn_decade_name_match
, case when j.ssn_fname is not null then 1 else 0 end as ssn_name_match
, case when k.left3_ssn_fname is not null then 1 else 0 end as ssn_first_3_name_match
, case when m.left2_ssn_fname is not null then 1 else 0 end as ssn_first_2_name_match
, case when n.left1_ssn_fname is not null then 1 else 0 end as ssn_first_1_name_match
from analytics.members a
left join vf_yob b on upper(a.ent_first_name) = b.fname and b.yob = left(a.dob,4)
left join vf_decade c on upper(a.ent_first_name) = c.fname and c.birth_decade = left(a.dob,3)||0
left join vf_fname d on upper(a.ent_first_name) = d.fname
left join vf_fname3 e on left(upper(a.ent_first_name),3) = e.left_3_fname
left join vf_fname2 f on left(upper(a.ent_first_name),2) = f.left_2_fname
left join vf_fname1 g on left(upper(a.ent_first_name),1) = g.left_1_fname
left join ssa_yob h on upper(a.ent_first_name) = h.ssn_fname and b.yob = h.yob
left join ssa_decade i on upper(a.ent_first_name) = i.ssn_fname and c.birth_decade = i.decade
left join ssa_fname j on upper(a.ent_first_name) = j.ssn_fname
left join ssa_fname3 k on left(upper(a.ent_first_name),3) = k.left3_ssn_fname
left join ssa_fname2 m on left(upper(a.ent_first_name), 2) = m.left2_ssn_fname
left join ssa_fname1 n on left(upper(a.ent_first_name), 1) = n.left1_ssn_fname;


drop table if exists gender_averages;
create temp table gender_averages as
select
  avg(vf_yob_fname_pct) as vf_yob_fname_pct
, avg(vf_decade_fname_pct) as vf_decade_fname_pct
, avg(vf_fname_pct) as vf_fname_pct
, avg(vf_left_3_fname_pct) as vf_left_3_fname_pct
, avg(vf_left_2_fname_pct) as vf_left_2_fname_pct 
, avg(vf_left_1_fname_pct) as vf_left_1_fname_pct 
, avg(ssn_yob_fem_pct) as ssn_yob_fem_pct
, avg(ssn_decade_fem_pct) as ssn_decade_fem_pct
, avg(ssn_fname_fem_pct) as ssn_fname_fem_pct
, avg(ssn_3_thirdchar_pct) as ssn_3_thirdchar_pct
, avg(ssn_2_secondchar_pct) as ssn_2_secondchar_pct
, avg(ssn_1_firstchar_pct) as ssn_1_firstchar_pct
from gender_basefile01;

drop table if exists modeling.gender_basefile;
create table modeling.gender_basefile sortkey (enterprise_id) as 
select distinct 
  enterprise_id
, len(regexp_replace(ent_first_name, '[^a-zA-Z\d]')) as name_length
, coalesce(a.vf_yob_fname_pct, b.vf_yob_fname_pct) as vf_yob_fname_pct
, coalesce(a.vf_decade_fname_pct, b.vf_decade_fname_pct) as vf_decade_fname_pct
, coalesce(a.vf_fname_pct, b.vf_fname_pct) as vf_fname_pct
, coalesce(a.vf_left_3_fname_pct, b.vf_left_3_fname_pct) as vf_left_3_fname_pct
, coalesce(a.vf_left_2_fname_pct, b.vf_left_2_fname_pct) as vf_left_2_fname_pct 
, coalesce(a.vf_left_1_fname_pct, b.vf_left_1_fname_pct) as vf_left_1_fname_pct 
, coalesce(a.ssn_yob_fem_pct, b.ssn_yob_fem_pct) as ssn_yob_fem_pct
, coalesce(a.ssn_decade_fem_pct, b.ssn_decade_fem_pct) as ssn_decade_fem_pct
, coalesce(a.ssn_fname_fem_pct, b.ssn_fname_fem_pct) as ssn_fname_fem_pct
, coalesce(a.ssn_3_thirdchar_pct, b.ssn_3_thirdchar_pct) as ssn_3_thirdchar_pct
, coalesce(a.ssn_2_secondchar_pct, b.ssn_2_secondchar_pct) as ssn_2_secondchar_pct
, coalesce(a.ssn_1_firstchar_pct, b.ssn_1_firstchar_pct) as ssn_1_firstchar_pct
, vf_dob_name_match
, vf_decade_name_match
, vf_name_match
, vf_first_3_name_match
, vf_first_2_name_match
, vf_first_1_name_match
, ssn_dob_name_match
, ssn_decade_name_match
, ssn_name_match
, ssn_first_3_name_match
, ssn_first_2_name_match 
, ssn_first_1_name_match
  -- Generate affiliate gender percentages on the fly 
, coalesce(su.affiliate_fem_pct,l.affiliate_fem_pct,aff.affiliate_fem_pct,aff2.affiliate_fem_pct,st.affiliate_fem_pct) as affiliate_fem_pct
from gender_basefile01 a
left join gender_averages b on 1=1
left join analytics.members c using (enterprise_id)
left join (
        select md5(coalesce(m.aff_state,'z')||coalesce(m.aff_council,'z')||coalesce(m.aff_type,'z')||coalesce(m.aff_local,'z')||coalesce(m.aff_subunit,'z')) as aff_id
        , count(case when cat_gender = 'female' then 1 else null end)/count(*)::float as affiliate_fem_pct
        from analytics.members m
        where cat_gender in ('female', 'male')
        and cat_gender_source = 'voterFile'
        group by 1) su on su.aff_id = md5(coalesce(c.aff_state,'z')||coalesce(c.aff_council,'z')||coalesce(c.aff_type,'z')||coalesce(c.aff_local,'z')||coalesce(c.aff_subunit,'z'))
left join (
        select md5(coalesce(m.aff_state,'z')||coalesce(m.aff_council,'z')||coalesce(m.aff_type,'z')||coalesce(m.aff_local,'z')) as aff_id
        , count(case when cat_gender = 'female' then 1 else null end)/count(*)::float as affiliate_fem_pct
        from analytics.members m
        where cat_gender in ('female', 'male')
        and cat_gender_source = 'voterFile'
        group by 1) l on l.aff_id = md5(coalesce(c.aff_state,'z')||coalesce(c.aff_council,'z')||coalesce(c.aff_type,'z')||coalesce(c.aff_local,'z'))
left join (
        select md5(coalesce(m.aff_state,'z')||coalesce(m.aff_council,'z')||coalesce(m.aff_type,'z')) as aff_id
        , count(case when cat_gender = 'female' then 1 else null end)/count(*)::float as affiliate_fem_pct
        from analytics.members m
        where cat_gender in ('female', 'male')
        and cat_gender_source = 'voterFile'
        group by 1) aff on aff.aff_id = md5(coalesce(c.aff_state,'z')||coalesce(c.aff_council,'z')||coalesce(c.aff_type,'z'))
left join (
        select md5(coalesce(m.aff_state,'z')||coalesce(m.aff_council,'z')) as aff_id
        , count(case when cat_gender = 'female' then 1 else null end)/count(*)::float as affiliate_fem_pct
        from analytics.members m
        where cat_gender in ('female', 'male')
        and cat_gender_source = 'voterFile'
        group by 1) aff2 on aff2.aff_id = md5(coalesce(c.aff_state,'z')||coalesce(c.aff_council,'z'))
left join (
        select md5(coalesce(m.aff_state,'z')) as aff_id
        , count(case when cat_gender = 'female' then 1 else null end)/count(*)::float as affiliate_fem_pct
        from analytics.members m
        where cat_gender in ('female', 'male')
        and cat_gender_source = 'voterFile'
        group by 1) st on st.aff_id = md5(coalesce(c.aff_state,'z'));

-- Create table and final score
create table if not exists modeling.gender_score_v2
(enterprise_id bigint, modeled_gender varchar(1), gender_score_raw float)
sortkey (enterprise_id);

truncate table modeling.gender_score_v2;
insert into modeling.gender_score_v2 (
select distinct
  enterprise_id
, case when 
	(case
		-- Full name exists on file
		when name_length > 1 then  
		(1/(1+EXP(-(-2.619632 +
		(vf_yob_fname_pct * 1.09394)+
		(vf_fname_pct * 4.515931)))))
		-- No full name exists on file
		when name_length = 1 then
		(1/(1+EXP(-(-0.8467727540415213027813+
		(vf_yob_fname_pct * 0.4431074487031501085710) + 
		(vf_decade_fname_pct * 3.4488917936641581007962) + 
		(vf_fname_pct * -1.8062216798928061312068) + 
		(vf_left_3_fname_pct * -0.0729590002505451640236) + 
		(ssn_1_firstchar_pct * 0.6404846194668839531872) + 
		(vf_dob_name_match * 0.4335885285498964902828) + 
		(vf_decade_name_match * 0.3054011688277338820718) + 
		(vf_name_match * -3.1839087455762791201153) + 
		(vf_first_3_name_match * -0.0000000000000618490725) + 
		(vf_first_2_name_match * -0.0000000000000007949752) + 
		(vf_first_1_name_match * -0.0000000000000004769851) + 
		(ssn_first_1_name_match * -0.3486471819456721243924) + 
		(affiliate_fem_pct * 4.4475056631053000444354)))))
	end) >=.5 then 'F' else 'M' end as modeled_gender
, (case
		-- Full name exists on file
		when name_length >= 1 then  
		(1/(1+EXP(-(-2.619632 +
		(vf_yob_fname_pct * 1.09394)+
		(vf_fname_pct * 4.515931)))))
		
		-- No full name exists on file
		when name_length = 1 then
		(1/(1+EXP(-(-0.8467727540415213027813+
		(vf_yob_fname_pct * 0.4431074487031501085710) + 
		(vf_decade_fname_pct * 3.4488917936641581007962) + 
		(vf_fname_pct * -1.8062216798928061312068) + 
		(vf_left_3_fname_pct * -0.0729590002505451640236) + 
		(ssn_1_firstchar_pct * 0.6404846194668839531872) + 
		(vf_dob_name_match * 0.4335885285498964902828) + 
		(vf_decade_name_match * 0.3054011688277338820718) + 
		(vf_name_match * -3.1839087455762791201153) + 
		(vf_first_3_name_match * -0.0000000000000618490725) + 
		(vf_first_2_name_match * -0.0000000000000007949752) + 
		(vf_first_1_name_match * -0.0000000000000004769851) + 
		(ssn_first_1_name_match * -0.3486471819456721243924) + 
		(affiliate_fem_pct * 4.4475056631053000444354)))))
	end) as gender_score_raw
from modeling.gender_basefile
where name_length != 0);

-- Cleanup
drop table if exists vf_yob;
drop table if exists vf_decade;
drop table if exists vf_fname;
drop table if exists vf_fname3;
drop table if exists vf_fname2;
drop table if exists vf_fname1;
drop table if exists ssa_yob;
drop table if exists ssa_decade;
drop table if exists ssa_fname;
drop table if exists ssa_fname3;
drop table if exists ssa_fname2;
drop table if exists ssa_fname1;
drop table if exists modeling.gender_basefile;