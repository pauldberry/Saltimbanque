--Create a temp table with the "affiliate" and "local" columns added on to the enterprise.members table so as to join with pberry.jobsector2017_staging

drop table if exists temp1_mems;
create temp table temp1_mems as
select enterprise_id
, aff_state
, aff_council
, aff_local
, aff_subunit
, mbr_type
, case when aff_council is not null then 'C'||aff_council
       when aff_council is null and aff_local is not null then 'L'||aff_local end as affiliate1
, case when aff_council is null and aff_local is not null and aff_subunit is not null then aff_subunit
       when aff_council is not null then aff_local end as local1
from enterprise.members;

--Join the previous temp table to the imported job sector data

drop table if exists joinjobs_staging;
create temp table joinjobs_staging as
select a.*
, b.affiliate
, b.local
, b.aff_name
, b.industry
, b.jurisdiction
, b.employer
, b.function
, b.single_ocptn
, b.org_type 
from temp1_mems a
left join pberry.jobsector2017_staging b on a.affiliate1 = b.affiliate and a.local1 = b.local
ORDER BY 1,2,3,4,5,6,7,9,8;

select * from joinjobs_staging
limit 100;

select distinct aff_council, aff_local as Locals
from joinjobs_staging
where aff_name is null;

--These are affiliates in Enterprise that don't have a matching contract
select distinct affiliate1, local1
from joinjobs_staging as enterprise_affiliates_without_a_contract
where aff_name is null

select * from pberry.jobsector2017_staging
limit 100


--Original join attempt - this resulted in many null values

--create table jobs as
--select a.enterprise_id
--, b.aff_state
--, a.aff_council
--, a.aff_local
--, b.aff_chapter
--, b.aff_name
--, b.industry
--, b.jurisdiction
--, b.employer
--, b.function
--, b.single_ocptn
--, b.org_type 
--from enterprise.members a
--left join pberry.jobsector2017 b on b.aff_council = a.aff_council and b.aff_local = a.aff_local and b.aff_state = a.aff_state

--the following couldn't run - there were no error messages, but DbViz kept processing and processing, so I went back and manually added the columns to the pberry.jobs table in the CSV and re-uploaded it

--drop table if exists temp2_jobs;
--create temp table temp2_jobs as
--select *
--, case when aff_council is not null then 'C'||aff_council
--       when aff_council is null and aff_local is not null then 'L'||aff_local end as affiliate
--, case when aff_council is null and aff_local is not null and aff_chapter is not null then aff_chapter
--       when aff_council is not null then aff_local end as local
--from pberry.jobs