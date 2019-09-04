select icu.subject_id,hadm_id,icustay_id,intime, outtime,dod,
case when dod>=intime and dod <= outtime then 1 else 0 end as in_icu_mort
from mimiciii.icustays icu
left join mimiciii.patients pt
on icu.subject_id = pt.subject_id
where icustay_id in(select icustay_id from icu_18)
and icustay_id in(select icustay_id from icu_first)
