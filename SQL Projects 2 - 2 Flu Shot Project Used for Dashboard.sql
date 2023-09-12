/* Objectives
Come up with flu shots dashoard for 2022 that does the folling:

1.) Total % of patients getting flu shots stratified by
	a.) Age 
	b.) Race
	c.) County (on a map)
	d.) Overall
2.) Running total of flu shots over the course of 2022
3.) Total number of flu shots given in 2022
4.) A list of patients that show whether of not they received the flu shot

Requirements:

Patients must have been "Active at our hospital"
*/


-- <______________________________________________> *** Exploring The Data *** <_____________________________________________________>


Select *
from Patients as pat

select *
from Immunizations as imm

select IMM.PATIENT, IMM.DATE, IMM.CODE, IMM.DESCRIPTION, COUNT(IMM.DESCRIPTION) OVER (PARTITION BY PATIENT ORDER BY IMM.PATIENT, IMM.DATE) RollingVaccines 
from Immunizations as imm



Select pat.ID
	  ,pat.first
	  ,pat.last
	  ,pat.birthdate
	  ,pat.race
	  ,pat.county
	  ,imm.date
	  ,imm.DESCRIPTION
from Patients pat
join Immunizations imm on pat.id = imm.PATIENT
where imm.CODE = '5302' and date between '2022-01-01' and '2022-12-31'
order by 1

select *
from Immunizations as imm
where imm.CODE = '5302' and date between '2022-01-01' and '2022-12-31'
	 


Select pat.ID
	  ,pat.first
	  ,pat.last
	  ,pat.birthdate
	  ,pat.race
	  ,pat.county
	  ,imm.date
	  ,imm.DESCRIPTION
from Patients pat
join Immunizations imm on pat.id = imm.PATIENT
where imm.CODE = '5302' and date between '2022-01-01' and '2022-12-31'
order by 1

Select *
from Patients as pat

select *
from Immunizations as imm
where date between '2022-01-01' and '2022-12-31'

With CTE_Flu_Shot_2022 as
(
Select imm.PATIENT, min(imm.DATE) as Earliest_Flu_Shot_2022, FIRST_VALUE(Imm.DESCRIPTION) over (order by imm.description) First_Immunization_Shot
from Immunizations as imm
where imm.CODE = '5302' 
	and imm.DATE between '2022-01-01' and '2023-01-01'
Group by Patient, DESCRIPTION
)

Select pat.ID
	  ,pat.first
	  ,pat.last
	  ,pat.birthdate
	  ,pat.race
	  ,pat.county
	  ,First_Immunization_Shot
from Patients as pat
Left join CTE_Flu_Shot_2022 as flu on pat.id = flu.patient 


-- <______________________________________________> *** Code used to set up dataset for Tableau *** <_____________________________________________________>

-- Data check
Select *
from Patients as pat

select *
from Immunizations as imm
where date between '2022-01-01' and '2022-12-31'

Update Patients
Set DEATHDATE = null
Where DEATHDATE = '\N'

/*
<<<<< -------------------------------------------**Code to set up the queries to pull dataset**------------------------------------------->>>>>
*/

/* Objectives:
Come up with flu shots dashoard for 2022 that does the folling:

1.) Total % of patients getting flu shots stratified by
	a.) Age 
	b.) Race
	c.) County (on a map)
	d.) Overall
2.) Running total of flu shots over the course of 2022
3.) Total number of flu shots given in 2022
4.) A list of patients that show whether of not they received the flu shot

Requirements:

Patients must have been "Active at our hospital"
*/

-- Setting up Common Table Expression to list patients that were active and older than 6 months
With CTE_Active_Patients as 
(
Select Distinct Patient PatientID, datediff(YEAR,pat.birthdate,'2022-12-31') Age
From dbo.Encounters e
Join dbo.Patients pat 
	on e.patient = pat.ID
where start between '2020-01-01' and '2023-01-01'
	and pat.DEATHDATE is null
	and datediff(MONTH,pat.birthdate,'2022-12-31') >=6
	--and Pat.Id in ('0013dd75-b1c0-6894-88cd-302ccca3ad89','00305dd1-5f4d-27d9-5dcf-1ebe66017688') <Use when looking up multiple items in one column>
Group by Patient, BIRTHDATE
),
-- Setting up Common Table Expression to create list of unique patients

CTE_Flu_Shot_2022 as
(
Select imm.PATIENT PatientID
	, min(imm.DATE) as Earliest_Flu_Shot_2022
	, FIRST_VALUE(Imm.DESCRIPTION) over (order by imm.description) First_Immunization_Shot
	, 1 as Flu_Shot_2022
from Immunizations imm
where imm.CODE = '5302' 
	and imm.DATE between '2022-01-01' and '2023-01-01'
Group by Patient, DESCRIPTION
)

Select distinct pat.ID PatientID
	  ,pat.First
	  ,pat.Last
	  ,pat.Birthdate
	  ,AP.Age
	  ,Case
			when Age is null then 'Unknwon'
			when Age between 0 and 17 then '0-17'
			When Age between 18 and 24	then '18-24'
			When Age between 25 and 34	then '25-34'
			When Age between 35 and 44	then '35-44'
			When Age between 45 and 54	then '45-54'
			When Age between 55 and 64	then '55-64'
			When Age >=65 then '65+'
			Else 'Unknown'
	   End as AgeRange
	  ,Last_Value(pat.race) over (order by pat.race) Race
	  ,pat.County
	  ,flu.First_Immunization_Shot
	  ,flu.Earliest_Flu_Shot_2022
	  --,Flu_Shot_2022
	  ,Case when flu.PatientID is not null then 1
		else 0
		end Flu_Shot_2022 

from Patients pat
Left join CTE_Flu_Shot_2022 flu 
	on pat.Id = flu.PatientID 
Left join CTE_Active_Patients AP 
	on pat.Id = AP.PatientID
where 1=1
	and pat.id in (select PatientID from CTE_Active_Patients)
--group by ID, First, Last, Birthdate, Race, County, flu.First_Immunization_Shot, flu.Earliest_Flu_Shot_2022, Flu_Shot_2022
Order by 1
