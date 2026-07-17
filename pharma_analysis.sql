create table patients(
	patient varchar(100) primary key,
	birthdate date,
	deathdate date,
	ssn varchar(100),
	drivers varchar(100),
	passport varchar(100),
	prefix varchar(100),
	first varchar(100), last varchar(100),suffix varchar(100),
	maiden varchar(100), marital char(1), race varchar(30), ethnicity varchar(100),
	gender char(1), birthplace varchar(100), address varchar(100)
);

select *
from patients
limit 5;


CREATE TABLE encounters (
    ID varchar(50) primary key,
	date date,
	patient varchar(100),
	constraint fk_encounter_patient foreign key (patient) references patients(patient),
	code int,
	description varchar(800),
	reasoncode bigint,
	reasondescription varchar(100)
);

select *
from encounters
limit 5;

create table conditions(
	START date,
	STOP date,
	patient varchar(100),
	encounter varchar(100),
	CODE bigint,
	DESCRIPTION varchar(150),
	constraint fk_condition_patient foreign key (patient) references patients(patient),
	constraint fk_condition_encounter foreign key (encounter) references encounters(ID)
);

select *
from conditions
limit 5;

create table medications(
	START date,
	STOP date,
	patient varchar(100),
	encounter varchar(100),
	CODE bigint,
	DESCRIPTION varchar(150),
	REASONCODE bigint,
	REASONDESCRIPTION varchar(150),
	constraint fk_condition_patient foreign key (patient) references patients(patient),
	constraint fk_condition_encounter foreign key (encounter) references encounters(ID)

);

select *
from medications
limit 5;

SELECT COUNT(*) FROM patients;
SELECT COUNT(*) FROM encounters;
SELECT COUNT(*) FROM conditions;
SELECT COUNT(*) FROM medications;

--checking for null values
select count(*) from patients
where patient is null;

select count(*) from encounters
where id is null or patient is null;

select count(*) from conditions
where encounter is null or patient is null;

select count(*) from medications
where encounter is null or patient is null;
-- no null values

--checking for duplicates
select patient, count(*)
from patients
group by patient
having count(*) > 1;

select id, count(*)
from encounters
group by id
having count(*) > 1;

--conditions without a matching patient
select count(*)
from conditions as c
left join patients as p
on c.patient = p.patient
where p.patient is null;

--medications without matching encounter
select count(*)
from medications as m 
left join encounters as e
on m.encounter = e.id
where e.id is null;


--gender distribution
select gender, count(*) as patient_count
from patients
group by gender;

--top 10 conditions
select description, count(*) as total_cases
from conditions
group by description
order by total_cases desc
limit 10;

--medication analysis
--top prescribed medications
select description, count(*) as prescriptions
from medications
group by description
order by prescriptions desc
limit 5:

--medication utilization duration
select start, stop, 
	(stop - start) as duration_days
from medications

--disease medication analysis
--most common conditions
select description, count(*) as count_description
from conditions
group by description
order by count_description desc

--most prescibed medication for each condition
select description, reasondescription, count(*) as prescriptions
from medications
group by reasondescription, description
order by reasondescription, description desc

--number of medications per condition
select reasondescription, count(distinct description) as unique_medication
from medications
where reasondescription is not null
group by reasondescription
order by unique_medication desc;


--patient analysis
-- medication usage by gender
select p.gender, count(*) as med_usage
from patients as p
left join medications as m
on p.patient = m.patient
group by p.gender

--most common disease among females
select c.description, count(*) as cases
from conditions as c
join patients as p
on p.patient = c.patient
where p.gender = 'F'
group by c.description
order by cases desc
limit 10;

--patients taking highest number of medications
select p.patient, count(*) as total
from patients as p
join medications as m
on p.patient = m.patient
group by p.patient
order by total desc
limit 10;


--enounter analysis
--most common encounter reasons
select reasondescription, count(*) as total
from encounters
where reasondescription is not null
group by reasondescription
order by total desc
limit 10;

--number of encounters per patient
select patient, count(*) total_encounter
from encounters
group by patient
order by total_encounter;

--patients taking more medications than the avg patient
select patient, count(*) as medication_count
from medications
group by patient
having count(*) > 
(
	select avg(med_count)
	from (
		select count(*) as med_count
		from medications
		group by patient
	)
);

--avg medication duration by condition
with med_duration as (
	select reasondescription, (stop-start) as duration
	from medications
	where stop is not null
)
select reasondescription, round(avg(duration),2) as avg_duration
from med_duration
group by reasondescription
order by avg_duration desc;

--patient w more than 5 med
select patient, count(*) as med_count
from medications
group by patient
having count(*) > 5
order by med_count desc

WITH patient_medications AS (
    SELECT
        patient,
        COUNT(*) AS medication_count
    FROM medications
    GROUP BY patient
)

SELECT *
FROM patient_medications
WHERE medication_count > 5
ORDER BY medication_count DESC;

--avg age of patients by gender
with patient_age as (
	select gender,
			extract(year from age(current_date,birthdate)) as age
	from patients
)
select gender, round(avg(age),2) as avg_age
from patient_age
group by gender;


--top medications view
create view top_medications as
select description as medication,
	   count(*) as prescription_count
from medications 
group by description;

select * from top_medications
order by prescription_count desc;

--medication usage by gender view
create view med_by_gender as
select p.gender, count(*) as med_usage
from patients as p
join medications as m
on p.patient = m.patient
group by p.gender;

select * from med_by_gender;

--top conditions view
create view top_condition as
select description as condition, count(*) as total_cases
from conditions
group by description;

select * from top_condition;