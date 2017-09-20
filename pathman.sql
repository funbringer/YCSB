CREATE EXTENSION pg_pathman;


CREATE TABLE pathman(
	YCSB_KEY VARCHAR(255) NOT NULL,
	FIELD0 TEXT, FIELD1 TEXT,
	FIELD2 TEXT, FIELD3 TEXT,
	FIELD4 TEXT, FIELD5 TEXT,
	FIELD6 TEXT, FIELD7 TEXT,
	FIELD8 TEXT, FIELD9 TEXT
);

do $$
	declare
	i       int4;
	range   int4 := 1000;
	parts   int4 := 500;
	width   int4 := range / parts;
	range_end text;

	begin
		assert(range % parts = 0);

		perform add_to_pathman_config('pathman', 'ycsb_key', NULL);

		for i in 1..parts loop
			range_end = case i<parts
					when true then format('user%s',
						lpad((width * i)::text, 3, '0'))
					else 'uses'
					end
				;

			perform add_range_partition('pathman',
				'user' || lpad((width * (i - 1))::text, 3, '0'),
				range_end,
				format('pathman_%s', i));

			execute format('create index on pathman_%s (ycsb_key);', i);
		end loop;
	end;
$$;
