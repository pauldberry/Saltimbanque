--#PostGreSQL practice#

select surveyresponsename, count(*)
from responses.mw_responses
where mycommitteeid = '50459' and surveyquestionid = '193968'

--Seths stuff

create table contracts_db2 as
select  ds01
        ,case when ds02 like 'COUNCIL%' then 'C'+trim('COUNCIL ' from ds02)
                when ds02 like 'LOCAL%' then 'L'+trim('LOCAL ' from ds02)
                end as aff_number
        ,document
        ,pdf
        ,doc
        ,file_name
        ,state
        ,council_number
        ,local_number
        ,case when local_number not like '%,%' then local_number
                when local_number like '%,%' then 'need_to_split' end as new_local_number
        ,chapter
        ,employer_name
        ,effective_date::date as effective_date
        ,expiration_date::date as expiration_date
        ,employer_type
        ,types_of_services_or_program_provided as sector_category
        ,bargaining_unit_description as job_category
        ,single_occupation
        ,agency_fee
        ,people_checkoff
        ,number_in_bargaining_unit::integer as unit_size
        ,number_of_members::integer as member_count
        ,archive
        ,"date modified" as date_modified
from sjohnson.contracts_db

create table contract_db2 as
select ds01, 
		case when ds02 like 'COUNCIL%' then 'C'+trim('COUNCIL ' fro; ds02)
			when ds02 like 'LOCAL' then 'L'+trim('LOCAL' from ds02)
			end as aff_number
		,document
		,pdf
		,doc
		,file_name
		,state
		,council_number
		,local_number
		,case when local_number not like '%,%' then local_number
				when local_number like '%,%' then 'need_to_split' end as new_local_number
		,chapter
		,employer_name
		,effective_date::date as effective_date
		,expiration_date::date as expiration_date
		,employer_type
		,types_of_services_or_program_provided as sector_category
		,bargaining_unit_description as job_category
		,single_occupation
		,agency_fee
		,people_checkoff
		,number_in_bargaining_unit:: as unit_size
		,number_of_members::integer as member_count
		,archive
		,"date_modified" as date_modified
        from contracts_db;


---create the first table
drop table if exists pauls_first_original;
create table pauls_first_original as
	select aff_pk, enterprise_id, dwid, dqiid, state_file_id
from analytics.members;

---rename this table cause you chose a dopey name
ALTER TABLE pauls_first_original
        RENAME TO pauls_org_tab;

---rename a column name example
ALTER TABLE pauls_first_original
        RENAME COLUMN enterprise_id TO ENTERPRISE_ID_LOUD;
