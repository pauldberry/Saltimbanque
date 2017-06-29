--select distinct md5(coalesce(aff_state,'na')||coalesce(aff_council,'na')||coalesce(aff_local,'na')||coalesce(aff_subunit,'na')) as aff_id
--from analytics_staging.jobs_data


select * from twhittaker.local_name_01312016