

# creates a view of the members of UDW in a schema for L3930
create view L3930.members as
	select *
	from analytics.members
	where aff_name = 'L3930'

#creates a view of UDW responses
create view L3930.van_responses as
	select *
	from responses.mw_responses 
	where committeeid in (48899, 49139,50840, 51158, 49138, 49138, 52380)

#creates a view of UDW most recent responses
create view L3930.van_responses_recent as
	select *
	from responses.mw_responses_recent
	where committeeid in (48899, 49139,50840, 51158, 49138, 49138, 52380)

# creates a view of van events
create view L3930.van_events as
	select *
	from responses.mw_events 
	where committeeid in (48899, 49139,50840, 51158, 49138, 49138, 52380)

# creates a view of activist codes applied to this committee
create view L3930.van_activistcodes as
	select *
	from responses.mw_activistcodes
	where committeeid in (48899, 49139,50840, 51158, 49138, 49138, 52380)

# creates a view of attempts made in VAN
create view L3930.van_attempts as
	select *
	from responses.mw_attempts
	where committeeid in (48899, 49139,50840, 51158, 49138, 49138, 52380)







	