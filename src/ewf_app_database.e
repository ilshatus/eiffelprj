note
	description: "Summary description for {EWF_APP_DATABASE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EWF_APP_DATABASE

create
	initialize_db

feature{NONE}
	initialize_db
		do

		end

feature

	execute_query(s: STRING): ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
		local
			i : NATURAL
			temp: ARRAYED_LIST[EWF_APP_DATABASE_PAIR]
		do
			create Result.make(0)
			create db.make_create_read_write (db_file_name)
			create query.make (s, db)
			across query.execute_new as q_row loop
				create temp.make (0)
				from
					i := 1
				until
					i > q_row.item.count
				loop
					temp.extend (create {EWF_APP_DATABASE_PAIR}.make(q_row.item.column_name (i).string, q_row.item.string_value (i).string))
					i := i + 1
				end

				Result.extend(temp)
			end
			db.close
		end

	execute_insert(s: STRING)
		do
			create db.make_create_read_write (db_file_name)
			create insert.make (s, db)
			insert.execute
			db.close
		end



feature{NONE}
	db: SQLITE_DATABASE
	insert: SQLITE_INSERT_STATEMENT
	query: SQLITE_QUERY_STATEMENT
	db_file_name: STRING
		once
			Result := "data.sqlite"
		end

end
