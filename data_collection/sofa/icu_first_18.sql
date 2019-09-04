DROP MATERIALIZED VIEW IF EXISTS icu_first cascade;
CREATE MATERIALIZED VIEW icu_first as
select * from
(select subject_id,hadm_id,icustay_id,intime,outtime,row_number() over (partition by hadm_id order by intime) as occurance
from mimiciii.icustays ) as a
where occurance = 1

DROP MATERIALIZED VIEW IF EXISTS icu_first_18 cascade;
CREATE MATERIALIZED VIEW icu_first_18 as

select * from(select p.subject_id,i.hadm_id,i.icustay_id,i.intime,i.outtime,p.dob ,(extract( epoch from i.intime-p.dob))/60/60/24/365.25 as age
from mimiciii.patients p inner join
			  icu_first i 
on p.subject_id = i.subject_id ) a
where age >= 18