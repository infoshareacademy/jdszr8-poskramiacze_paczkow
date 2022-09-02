-- preparing tables for importing data
create table county_facts (
fips	float(20)	,
area_name	varchar(150)	,
state_abbreviation	varchar(50)	,
PST045214	float(20)	,
PST040210	float(20)	,
PST120214	float(20)	,
POP010210	float(20)	,
AGE135214	float(20)	,
AGE295214	float(20)	,
AGE775214	float(20)	,
SEX255214	float(20)	,
RHI125214	float(20)	,
RHI225214	float(20)	,
RHI325214	float(20)	,
RHI425214	float(20)	,
RHI525214	float(20)	,
RHI625214	float(20)	,
RHI725214	float(20)	,
RHI825214	float(20)	,
POP715213	float(20)	,
POP645213	float(20)	,
POP815213	float(20)	,
EDU635213	float(20)	,
EDU685213	float(20)	,
VET605213	float(20)	,
LFE305213	float(20)	,
HSG010214	float(20)	,
HSG445213	float(20)	,
HSG096213	float(20)	,
HSG495213	float(20)	,
HSD410213	float(20)	,
HSD310213	float(20)	,
INC910213	float(20)	,
INC110213	float(20)	,
PVY020213	float(20)	,
BZA010213	float(20)	,
BZA110213	float(20)	,
BZA115213	float(20)	,
NES010213	float(20)	,
SBO001207	float(20)	,
SBO315207	float(20)	,
SBO115207	float(20)	,
SBO215207	float(20)	,
SBO515207	float(20)	,
SBO415207	float(20)	,
SBO015207	float(20)	,
MAN450207	float(20)	,
WTN220207	float(20)	,
RTN130207	float(20)	,
RTN131207	float(20)	,
AFN120207	float(20)	,
BPS030214	float(20)	,
LND110210	float(20)	,
POP060210	float(20)	
);


create table primary_results (
state	varchar(50)	,
state_abbreviation	varchar(50)	,
county	varchar(50)	,
fips	float(20),
party	varchar(50)	,
candidate	varchar(50)	,
votes	integer	,
fraction_votes	float(20)	
)

--checking gaps and best way to join tables
with stany_c as (
select
area_name
from county_facts
where mod(fips::numeric, 1000)=0),

	stany_p as
(select DISTINCT
state
from primary_results
)

select DISTINCT
c.area_name,
p.state
from stany_c c
full outer join stany_p p
on c.area_name = p.state


--creating summary table that only shows states, stats and dem/rep votes
create table state_summary as (
--total query
with votes as (
--votes
select distinct
p.state_abbreviation,
p.party,
--sum(p.votes) over (partition by p.state, p.party) as party_votes,
--sum(p.votes) over (partition by p.state) as total_votes,
sum(p.votes) over (partition by p.state, p.party)::real/sum(p.votes) over (partition by p.state)::real*100 as percent_votes
from primary_results p
order by p.state_abbreviation
),

--calculating average % stats across counties to present as states data
--selecting only stats as % for simplicity
state_data as (
-- county data
SELECT distinct
state_abbreviation as SA,
avg(AGE135214) over (partition by state_abbreviation) "Persons under 5 years",
avg(AGE295214) over (partition by state_abbreviation) "Persons under 18 years",
avg(AGE775214) over (partition by state_abbreviation) "Persons 65 years and over",
avg(SEX255214) over (partition by state_abbreviation) "Female persons",
avg(RHI125214) over (partition by state_abbreviation) "White alone",
avg(RHI225214) over (partition by state_abbreviation) "Black or African American alone",
avg(RHI325214) over (partition by state_abbreviation) "American Indian and Alaska Native alone",
avg(RHI425214) over (partition by state_abbreviation) "Asian alone",
avg(RHI525214) over (partition by state_abbreviation) "Native Hawaiian and Other Pacific Islander alone",
avg(RHI625214) over (partition by state_abbreviation) "Two or More Races",
avg(RHI725214) over (partition by state_abbreviation) "Hispanic or Latino",
avg(RHI825214) over (partition by state_abbreviation) "White alone, not Hispanic or Latino",
avg(POP715213) over (partition by state_abbreviation) "Living in same house 1 year & over",
avg(POP645213) over (partition by state_abbreviation) "Foreign born persons",
avg(EDU635213) over (partition by state_abbreviation) "High school graduate or higher",
avg(EDU685213) over (partition by state_abbreviation) "Bachelors degree or higher",
avg(HSG096213) over (partition by state_abbreviation) "Housing units in multi-unit structures",
avg(PVY020213) over (partition by state_abbreviation) "Persons below poverty level",
avg(BZA115213) over (partition by state_abbreviation) "Private nonfarm employment",
avg(SBO315207) over (partition by state_abbreviation) "Black-owned firms",
avg(SBO115207) over (partition by state_abbreviation) "American Indian- and Alaska Native-owned firms",
avg(SBO215207) over (partition by state_abbreviation) "Asian-owned firms",
avg(SBO515207) over (partition by state_abbreviation) "Native Hawaiian- and Other Pacific Islander-owned firms",
avg(SBO415207) over (partition by state_abbreviation) "Hispanic-owned firms",
avg(SBO015207) over (partition by state_abbreviation) "Women-owned firms"
from county_facts
)

--removing additional gaps - missing both parities voting data
select
*
from votes v
join state_data d
on v.state_abbreviation = d.sa
where v.percent_votes <> 100 and v.party = 'Democrat')


--calculating correlation coefficients stats vs voting across states

select
corr(s.percent_votes,s."Persons under 5 years") "Persons under 5 years",
corr(s.percent_votes,s."Persons under 18 years") "Persons under 18 years",
corr(s.percent_votes,s."Persons 65 years and over") "Persons 65 years and over",
corr(s.percent_votes,s."Female persons") "Female persons",
corr(s.percent_votes,s."White alone") "White alone",
corr(s.percent_votes,s."Black or African American alone") "Black or African American alone",
corr(s.percent_votes,s."American Indian and Alaska Native alone") "American Indian and Alaska Native alone",
corr(s.percent_votes,s."Asian alone") "Asian alone",
corr(s.percent_votes,s."Native Hawaiian and Other Pacific Islander alone") "Native Hawaiian and Other Pacific Islander alone",
corr(s.percent_votes,s."Two or More Races") "Two or More Races",
corr(s.percent_votes,s."Hispanic or Latino") "Hispanic or Latino",
corr(s.percent_votes,s."White alone, not Hispanic or Latino") "White alone, not Hispanic or Latino",
corr(s.percent_votes,s."Living in same house 1 year & over") "Living in same house 1 year & over",
corr(s.percent_votes,s."Foreign born persons") "Foreign born persons",
corr(s.percent_votes,s."High school graduate or higher") "High school graduate or higher",
corr(s.percent_votes,s."Bachelors degree or higher") "Bachelors degree or higher",
corr(s.percent_votes,s."Housing units in multi-unit structures") "Housing units in multi-unit structures",
corr(s.percent_votes,s."Persons below poverty level") "Persons below poverty level",
corr(s.percent_votes,s."Private nonfarm employment") "Private nonfarm employment",
corr(s.percent_votes,s."Black-owned firms") "Black-owned firms",
corr(s.percent_votes,s."American Indian- and Alaska Native-owned firms") "American Indian- and Alaska Native-owned firms",
corr(s.percent_votes,s."Asian-owned firms") "Asian-owned firms",
corr(s.percent_votes,s."Native Hawaiian- and Other Pacific Islander-owned firms") "Native Hawaiian- and Other Pacific Islander-owned firms",
corr(s.percent_votes,s."Hispanic-owned firms") "Hispanic-owned firms",
corr(s.percent_votes,s."Women-owned firms") "Women-owned firms"
from state_summary s


-- selecting only states close to vote parity
select *
from state_summary
where percent_votes between 45 and 55
order by "Hispanic-owned firms" desc

--end task


--backup queries
select * from primary_results




select
v.state_abbreviation,
v.party,
v.percent_votes,
max(d."Persons under 5 years") over (order by d."Persons under 5 years")-
min(d."Persons under 5 years") over (order by d."Persons under 5 years") as diff
from votes v
join state_data d
on v.state_abbreviation = d.state_abbreviation
where v.percent_votes <> 100 and v.party = 'Democrat'










select distinct
f.state_abbreviation,
r.state_abbreviation
from county_facts f
full outer join primary_results r
on f.state_abbreviation = r.state_abbreviation





--join by fips
--left join
with facts as (
select distinct
c.fips as fips,
c.state_abbreviation,
c.area_name as county
from county_facts c
order by c.fips),

results as (
select DISTINCT
p.fips,
p.state_abbreviation,
p.county
from primary_results p
order by p.fips)

select * 
from facts f
left join results r
on f.fips = r.fips
where r.fips is null and f.state_abbreviation is not null

--right join
with facts as (
select distinct
c.fips as fips,
c.state_abbreviation,
c.area_name as county
from county_facts c
order by c.fips),

results as (
select DISTINCT
p.fips,
p.state_abbreviation,
p.county
from primary_results p
order by p.fips)

select * 
from facts f
right join results r
on f.fips = r.fips
where f.fips is null

--joining by states
with facts as (
select distinct
c.state_abbreviation,
c.area_name as county
from county_facts c),

results as (
select DISTINCT
p.state_abbreviation,
p.county
from primary_results p)

select * 
from facts f
right join results r
on f.state_abbreviation = r.state_abbreviation

select * from county_facts