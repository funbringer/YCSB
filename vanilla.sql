CREATE TABLE vanilla(
	YCSB_KEY VARCHAR(255) NOT NULL,
	FIELD0 TEXT, FIELD1 TEXT,
	FIELD2 TEXT, FIELD3 TEXT,
	FIELD4 TEXT, FIELD5 TEXT,
	FIELD6 TEXT, FIELD7 TEXT,
	FIELD8 TEXT, FIELD9 TEXT
)
PARTITION BY RANGE (ycsb_key);

do $$
	declare
	i       int4;
	range   int4 := 1000;
	parts   int4 := 500;
	width   int4 := range / parts;
	range_end text;

	begin
		assert(range % parts = 0);

		for i in 1..parts loop
			range_end = case i<parts
					when true then format('user%s',
						lpad((width * i)::text, 3, '0'))
					else 'uses'
					end
				;
			execute format($q$create table vanilla_%s
					partition of vanilla
					for values from ('user%s') to ('%s');$q$,
				       i,
				       lpad((width * (i - 1))::text, 3, '0'),
				       range_end);

			execute format('create index on vanilla_%s (ycsb_key);', i);
		end loop;
	end;
$$;
