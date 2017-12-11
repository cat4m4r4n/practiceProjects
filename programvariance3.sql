--program variance again again, but with dates and getting rid of some tables i didn't use before
--get rid of all the daypart filtering and stuff in the base exposure tables
--just count households and exposure duration per household per exposure type per program id per date

--get the test db max dates for abc
drop table if exists sandbox.cl_dates;
create table sandbox.cl_dates 
as
select exposure_type, max(utc_program_view_time) as maxviewtime, max(national_program_air_time) as maxairtime
from public.abc_programming_exposure
group by exposure_type;

--add test db max dates for control exposure
insert into sandbox.cl_dates 
select exposure_type, max(utc_program_view_time) as maxviewtime, max(national_program_air_time) as maxairtime
from public.control_programming_exposure
group by exposure_type;

--get total max dates per exposure type
drop table if exists sandbox.cl_max_date;
create table sandbox.cl_max_date
as
select exposure_type, min(maxviewtime) as maxviewtime, min(maxairtime) as maxairtime
from sandbox.cl_dates
group by exposure_type;

--make base  tables
--create programming base table with control programming exposure data
drop table if exists sandbox.cl_programming_base;
create table sandbox.cl_programming_base
    distkey(household_id)
    sortkey(household_id, program_id)
as
select cpe.household_id,
       cpe.exposure_type,
       cpe.utc_program_view_time,
       cpe.local_program_view_time,
       cpe.local_program_air_time,
       cpe.program_id,
       cpe.exposure_duration as exposure_duration,
       cpe.program_duration as program_duration,
       cpe.network,
       cpe.utc_program_air_time
    from public.control_programming_exposure as cpe
        inner join public.household as hhld on cpe.household_id = hhld.household_id
        inner join public.program as p on cpe.program_id = p.program_id
        left join sandbox.cl_dates as cld on cpe.exposure_type = cld.exposure_type
    where cpe.utc_program_view_time > $module_start_date
        and cpe.utc_program_view_time < cld.maxviewtime
        and p.season_number is not null
        and p.series_id is not null
        and cpe.exposure_type in ('LIVE', 'DVR', 'DIGITAL', 'VOD')
        and hhld.is_a18_49_present = 1 
;

--Add abc programming exposure data to the programming base table
insert into sandbox.cl_programming_base
select cpe.household_id,
       cpe.exposure_type,
       cpe.utc_program_view_time,
       cpe.local_program_view_time,
       cpe.local_program_air_time,
       cpe.program_id,
       cpe.exposure_duration as exposure_duration,
       cpe.program_duration as program_duration,
       cpe.network,
       cpe.utc_program_air_time
    from public.abc_programming_exposure as cpe
        inner join public.household as hhld on cpe.household_id = hhld.household_id
        inner join public.program as p on cpe.program_id = p.program_id
        left join sandbox.cl_dates as cld on cpe.exposure_type = cld.exposure_type
    where cpe.utc_program_view_time > '2017-11-01'
        and cpe.utc_program_view_time < cld.maxviewtime
        and p.season_number is not null
        and p.series_id is not null
        and cpe.exposure_type in ('LIVE', 'DVR', 'DIGITAL', 'VOD')
        and hhld.is_a18_49_present = 1 
;
        
vacuum sandbox.cl_programming_base;
analyze sandbox.cl_programming_base;

--Create programming exposure table; this is a ROLL UP of the base table
drop table if exists sandbox.cl_programming_exposure;
create table sandbox.cl_programming_exposure
    distkey(household_id)
    sortkey(household_id, program_id)
as
select 1 as join_key,
       cpe.household_id,
       max(cpe.exposure_type) as exposure_type,
       min(cpe.utc_program_view_time) as utc_program_view_time,
       min(cpe.local_program_view_time) as local_program_view_time,
       min(cpe.local_program_air_time) as local_program_air_time,
       cpe.program_id,
       sum(cpe.exposure_duration) as exposure_duration,
       avg(cpe.program_duration) as program_duration,
       cpe.network,
       min(cpe.utc_program_air_time)as utc_program_air_time
    from sandbox.cl_programming_base as cpe
group by 2, 7, 10
  having sum(cpe.exposure_duration) > 360;

vacuum sandbox.cl_programming_exposure;
analyze sandbox.cl_programming_exposure;

drop table sandbox.cl_programming_base;


--hhs and exp per program id per date
drop table if exists sandbox.cl_hhs_perprogram;

create table sandbox.cl_hhs_perprogram
distkey(program_id)
sortkey(program_id)
as
select 1 as joinkey,
program_id,
max(utc_program_view_time) as utc_program_view_time,
exposure_type,
count(household_id) as num_hhs,
sum(exposure_duration) as sumExpDur
from sandbox.cl_programming_exposure
group by program_id, exposure_type
having count(household_id) > 29
order by program_id asc;

vacuum sandbox.cl_hhs_perprogram;
analyze sandbox.cl_hhs_perprogram;

--ACTIVATE_THIS_LINE_ON_R_CONVERSION--UNLOAD FROM sandbox.cl_hhs_perprogram

--get overall metrics
drop table if exists sandbox.cl_exptype_metrics;
create table sandbox.cl_exp_type_metrics
  as
select exposure_type, avg(num_hhs) as avg_hhs, stddev(num_hhs) as sd_hhs, variance(num_hhs) as var_hhs,
avg(sumexpdur) as avg_expdur, stddev(sumexpdur) as sd_expdur, variance(sumexpdur) as var_expdur
from sandbox.cl_hhs_perprogram
group by exposure_type
;

