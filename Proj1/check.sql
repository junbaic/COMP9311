-- COMP9311 19s1 Project 1 Check
--
-- MyMyUNSW Check

create or replace function
	proj1_table_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='r';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_view_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_function_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=tname;
	return (_check > 0);
end;
$$ language plpgsql;

-- proj1_check_result:
-- * determines appropriate message, based on count of
--   excess and missing tuples in user output vs expected output

create or replace function
	proj1_check_result(nexcess integer, nmissing integer) returns text
as $$
begin
	if (nexcess = 0 and nmissing = 0) then
		return 'correct';
	elsif (nexcess > 0 and nmissing = 0) then
		return 'too many result tuples';
	elsif (nexcess = 0 and nmissing > 0) then
		return 'missing result tuples';
	elsif (nexcess > 0 and nmissing > 0) then
		return 'incorrect result tuples';
	end if;
end;
$$ language plpgsql;

-- proj1_check:
-- * compares output of user view/function against expected output
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_check(_type text, _name text, _res text, _query text) returns text
as $$
declare
	nexcess integer;
	nmissing integer;
	excessQ text;
	missingQ text;
begin
	if (_type = 'view' and not proj1_view_exists(_name)) then
		return 'No '||_name||' view; did it load correctly?';
	elsif (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (not proj1_table_exists(_res)) then
		return _res||': No expected results!';
	else
		excessQ := 'select count(*) '||
				 'from (('||_query||') except '||
				 '(select * from '||_res||')) as X';
		-- raise notice 'Q: %',excessQ;
		execute excessQ into nexcess;
		missingQ := 'select count(*) '||
					'from ((select * from '||_res||') '||
					'except ('||_query||')) as X';
		-- raise notice 'Q: %',missingQ;
		execute missingQ into nmissing;
		return proj1_check_result(nexcess,nmissing);
	end if;
	return '???';
end;
$$ language plpgsql;

-- proj1_rescheck:
-- * compares output of user function against expected result
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_rescheck(_type text, _name text, _res text, _query text) returns text
as $$
declare
	_sql text;
	_chk boolean;
begin
	if (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (_res is null) then
		_sql := 'select ('||_query||') is null';
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	else
		_sql := 'select ('||_query||') = '||quote_literal(_res);
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	end if;
	if (_chk) then
		return 'correct';
	else
		return 'incorrect result';
	end if;
end;
$$ language plpgsql;

-- check_all:
-- * run all of the checks and return a table of results

drop type if exists TestingResult cascade;
create type TestingResult as (test text, result text);

create or replace function
	check_all() returns setof TestingResult
as $$
declare
	i int;
	testQ text;
	result text;
	out TestingResult;
	tests text[] := array['q1', 'q2', 'q3', 'q4', 'q5','q6','q7','q8','q9','q10','q11','q12'];
begin
	for i in array_lower(tests,1) .. array_upper(tests,1)
	loop
		testQ := 'select check_'||tests[i]||'()';
		execute testQ into result;
		out := (tests[i],result);
		return next out;
	end loop;
	return;
end;
$$ language plpgsql;


--
-- Check functions for specific test-cases in Project 1
--

create or replace function check_q1() returns text
as $chk$
select proj1_check('view','q1','q1_expected',
									 $$select * from q1$$)
$chk$ language sql;

create or replace function check_q2() returns text
as $chk$
select proj1_check('view','q2','q2_expected',
									 $$select * from q2$$)
$chk$ language sql;

create or replace function check_q3() returns text
as $chk$
select proj1_check('view','q3','q3_expected',
									 $$select * from q3$$)
$chk$ language sql;

create or replace function check_q4() returns text
as $chk$
select proj1_check('view','q4','q4_expected',
									 $$select * from q4$$)
$chk$ language sql;

create or replace function check_q5() returns text
as $chk$
select proj1_check('view','q5','q5_expected',
									 $$select * from q5$$)
$chk$ language sql;

create or replace function check_q6() returns text
as $chk$
select proj1_check('view','q6','q6_expected',
									 $$select * from q6$$)
$chk$ language sql;

create or replace function check_q7() returns text
as $chk$
select proj1_check('view','q7','q7_expected',
									 $$select * from q7$$)
$chk$ language sql;

create or replace function check_q8() returns text
as $chk$
select proj1_check('view','q8','q8_expected',
									 $$select * from q8$$)
$chk$ language sql;

create or replace function check_q9() returns text
as $chk$
select proj1_check('view','q9','q9_expected',
									 $$select * from q9$$)
$chk$ language sql;

create or replace function check_q10() returns text
as $chk$
select proj1_check('view','q10','q10_expected',
									 $$select * from q10$$)
$chk$ language sql;

create or replace function check_q11() returns text
as $chk$
select proj1_check('view','q11','q11_expected',
									 $$select * from q11$$)
$chk$ language sql;

create or replace function check_q12() returns text
as $chk$
select proj1_check('view','q12','q12_expected',
									 $$select * from q12$$)
$chk$ language sql;
--
-- Tables of expected results for test cases
--

drop table if exists q1_expected;
create table q1_expected (
	subject_name mediumname
);

drop table if exists q2_expected;
create table q2_expected (
	room_name shortname
);

drop table if exists q3_expected;
create table q3_expected (
	no bigint, orgunit_name mediumstring, program_num integer
);

drop table if exists q4_expected;
create table q4_expected (
	course_id integer
);

drop table if exists q5_expected;
create table q5_expected (
	unswid integer, name longname
);

drop table if exists q6_expected;
create table q6_expected (
	course_id integer, staff_name longname
);

drop table if exists q7_expected;
create table q7_expected (
	room_name longname, course_num integer
);

drop table if exists q8_expected;
create table q8_expected (
	no bigint, unswid integer
);

drop table if exists q9_expected;
create table q9_expected (
	year courseyeartype,
	term character(2),
	max_avg_mark numeric(4,2)
);

drop table if exists q10_expected;
create table q10_expected (
	unswid integer,
	average_mark numeric(4,2),
	grade character(2)
);

drop table if exists q11_expected;
create table q11_expected (
		orgunit_name mediumstring,
		intl_ratio numeric(3,2)
);

drop table if exists q12_expected;
create table q12_expected (
	unswid integer,
	name longname,
	course_num integer
);

-- ( )+\|+( )+

COPY q1_expected (subject_name) FROM stdin;
Combinatorial Data Processing
Info Retrieval and Web Search
(In-)Formal Methods
Modelling Concurrent Systems
\.

COPY q2_expected (room_name) FROM stdin;
K17-621
K17-103
K17-603
K17-113
\.

COPY q3_expected (no, orgunit_name, program_num) FROM stdin;
1	College of Fine Arts (COFA)	15
2	UNSW Asia	16
3	Faculty of Law	20
4	Faculty of Medicine	30
5	Faculty of Engineering	31
6	UNSW Canberra at ADFA	48
7	Faculty of Science	50
8	Faculty of Built Environment	65
9	Australian School of Business	79
10	Faculty of Arts and Social Sciences	164
\.

COPY q4_expected (course_id) FROM stdin;
47842
47843
47844
47845
47846
47847
47848
47884
48539
48819
49019
\.

COPY q5_expected (unswid, name) FROM stdin;
3108150	Kathryn Giuriato
3128590	Lisa Tung
3157307	Kabir Brace
3167327	Woon Toha
3170224	Sisheng Yee
3185242	Kylie Orlando
3187413	Equeen Inglis
\.

COPY q6_expected (course_id, staff_name) FROM stdin;
55519	Bruce Hall
55519	Irene Nemes
55519	Chin Ng
55519	Martin Duffy
55522	Jennifer Hartley
55522	Anuja Arunothayam
55522	Andrew Lynch
55523	David Vaile
55523	Dominic Fitzsimmons
55523	Mehera San Roque
55523	Susan Engel
55523	Margaret McAleese
55523	Brenda Tronson
55523	Stephanie Patterson
55525	Denis Harley
55525	May Cheong
\.

COPY q7_expected (room_name, course_num) FROM stdin;
MathewsThA	696
\.

COPY q8_expected (no, unswid) FROM stdin;
1	3282128
2	3255404
3	3236351
4	3220879
5	3214688
6	3165999
7	3128353
8	3107091
\.

COPY q9_expected (
		year,
		term,
		max_avg_mark
) FROM stdin;
2009	S1	73.20
\.

COPY q10_expected (unswid, average_mark, grade) FROM stdin;
2204126	62.00	PS
2224324	65.00	CR
2231753	81.00	DN
2234658	76.25	DN
2240781	76.33	DN
2242669	72.50	CR
2245633	72.00	CR
2261437	67.00	CR
2263389	90.00	HD
2279065	77.50	DN
\.


COPY q11_expected (orgunit_name, intl_ratio) FROM stdin;
Faculty of Engineering	0.44
Australian School of Business	0.40
Faculty of Built Environment	0.28
Faculty of Medicine	0.21
Faculty of Science	0.18
\.

COPY q12_expected (unswid, name,course_num) FROM stdin;
8711332	Stephen Colbran	47
8506392	Jacquelyn Cranney	41
9155962	Noor-E-Alam Ahmed	32
\.
