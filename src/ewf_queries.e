note
	description: "Summary description for {EWF_QUERIES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EWF_QUERIES

inherit
	EWF_APP_DATABASE
	EWF_APP_FIELDS_INFORMATION
create
	queries_initialize

feature{NONE}
	queries_initialize
		do
			info_initialize
			initialize_db
		end


feature --Access
	all_publications(year: STRING): STRING
		local
			s_date: STRING
			f_date: STRING
			j_obj: JSON_OBJECT
			j_conf_p: JSON_ARRAY
			j_journ_p: JSON_ARRAY
			parameter: LIST[STRING]
			q_res: ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
		do
			s_date := year + "-01-01"
			f_date := year + "-12-31"
			q_res := execute_query ("SELECT `field12`, `field13` FROM `reports` WHERE `field2` >= '" + s_date + "' AND `field2` <= '" + f_date + "'")
			create j_obj.make_empty
			create j_conf_p.make_empty
			create j_journ_p.make_empty
			across q_res as  q_row loop
				across q_row.item as q_col loop
					------------------
					if q_col.item.get_name.is_equal ("field12") and then not q_col.item.get_value.is_empty then
						parameter := q_col.item.get_value.split(';')
						across parameter as par loop
							j_conf_p.add (create {JSON_STRING}.make_from_string (par.item))
						end
					end
					if q_col.item.get_name.is_equal ("field13") and then not q_col.item.get_value.is_empty then
						parameter := q_col.item.get_value.split(';')
						across parameter as par loop
							j_journ_p.add (create {JSON_STRING}.make_from_string (par.item))
						end
					end
					-----------------
				end
			end
			j_obj.put (j_conf_p, create {JSON_STRING}.make_from_string ("conference_publications"))
			j_obj.put (j_journ_p, create {JSON_STRING}.make_from_string ("journal_publications"))
			Result := j_obj.representation
		end

	cumulative_information(unit: STRING): STRING
		local
			j_obj: JSON_OBJECT
			j_obj_value: JSON_OBJECT
			j_arr_values: JSON_ARRAY
			j_arr: JSON_ARRAY
			q_res: ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
			info_params: LIST[STRING]
			params: LIST[STRING]
			id: INTEGER
		do
			create j_arr.make_empty
			q_res := execute_query ("SELECT * FROM `reports` WHERE `field0` = '" + unit + "'")
			across q_res as  q_row loop
				id := -1
				create j_obj.make_empty
				across q_row.item as q_col loop
					------------------
					if not q_col.item.get_name.is_equal ("id") then
						if has_multiple_values.at (id + 1) then
							create j_arr_values.make_empty
							info_params := format.at (id + 1).split ('-')
							across q_col.item.get_value.split (';') as value loop
								params := value.item.split('/')
								create j_obj_value.make_empty
								from
									params.start
									info_params.start
								until
									params.off
								loop
									j_obj_value.put_string (params.item, create {JSON_STRING}.make_from_string (info_params.item.split ('^').first))
									params.forth
									info_params.forth
								end
								j_arr_values.add (j_obj_value)
							end
							j_obj.put (j_arr_values, create {JSON_STRING}.make_from_string (name.at (id + 1)))
						else
							j_obj.put_string (q_col.item.get_value, create {JSON_STRING}.make_from_string (name.at (id + 1)))
						end
					end
					id := id + 1
					-----------------
				end
				j_arr.add (j_obj)
			end
			Result := j_arr.representation
		end

	courses_taught(initial_date, final_date: STRING): STRING
		local
			j_arr: JSON_ARRAY
			j_obj: JSON_OBJECT
			info_params: LIST[STRING]
			params: LIST[STRING]
			q_res: ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
			s: STRING
		do
			q_res := execute_query ("SELECT `field4` FROM `reports` WHERE `field2` >= '" + initial_date + "' AND `field3` <= '" + final_date + "'")
			info_params := format.at (5).split ('-')
			create j_arr.make_empty
			across q_res as  q_row loop
				across q_row.item as q_col loop
					------------------
					s := q_col.item.get_value
					if not s.is_empty then
						across s.split(';') as value loop
							params := value.item.split('/')
							create j_obj.make_empty
							from
								params.start
								info_params.start
							until
								params.off
							loop
								j_obj.put_string (params.item, create {JSON_STRING}.make_from_string (info_params.item.split ('^').first))
								params.forth
								info_params.forth
							end
							j_arr.add (j_obj)
						end
					end
					-----------------
				end
			end
			Result := j_arr.representation
		end

	number_of_supervised_students(unit: STRING): STRING
		local
			s: STRING
			j_obj: JSON_OBJECT
			count: INTEGER
			q_res: ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
		do
			q_res := execute_query ("SELECT `field6` FROM `reports` WHERE `field0` = '" + unit.string + "'")
			create j_obj.make_empty
			across q_res as  q_row loop
				across q_row.item as q_col loop
					------------------
					s := q_col.item.get_value
					if not s.is_empty then
						count := count + s.split (';').count
					end
					-----------------
				end
			end
			j_obj.put_integer (count, create {JSON_STRING}.make_from_string ("number_of_students"))
			Result := j_obj.representation
		end

	number_of_research_collabarations(unit: STRING): STRING
		local
			s: STRING
			j_obj: JSON_OBJECT
			count: INTEGER
			q_res: ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
		do
			q_res := execute_query ("SELECT `field11` FROM `reports` WHERE `field0` = '" + unit.string + "'")
			create j_obj.make_empty
			across q_res as  q_row loop
				across q_row.item as q_col loop
					------------------
					s := q_col.item.get_value
					if not s.is_empty then
						count := count + s.split (';').count
					end
					-----------------
				end
			end
			j_obj.put_integer (count, create {JSON_STRING}.make_from_string ("number_of_res_cols"))
			Result := j_obj.representation
		end

	list_of_phds(unit: STRING): STRING
		local
			list1: LIST[STRING]
			s: STRING
			j_arr: JSON_ARRAY
			j_obj: JSON_OBJECT
			q_res: ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
		do
			q_res := execute_query ("SELECT `field8` FROM `reports` WHERE `field0` = '" + unit.string + "'")
			create j_obj.make_empty
			create j_arr.make_empty
			across q_res as  q_row loop
				across q_row.item as q_col loop
					s := q_col.item.get_value
					if not s.is_empty then
						list1 := s.split (';')
						across list1 as par loop
							j_arr.add (create {JSON_STRING}.make_from_string (par.item.split ('/').at (1)))
						end
					end
				end
			end
			j_obj.put (j_arr, create {JSON_STRING}.make_from_string ("list_of_phds"))
			Result := j_obj.representation
		end

	list_of_patents(unit: STRING): STRING
		local
			j_arr: JSON_ARRAY
			j_obj: JSON_OBJECT
			info_params: LIST[STRING]
			params: LIST[STRING]
			q_res: ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
			s: STRING
		do
			q_res := execute_query ("SELECT `field14` FROM `reports` WHERE `field0` = '" + unit + "'")
			info_params := format.at (15).split ('-')
			create j_arr.make_empty
			across q_res as  q_row loop
				across q_row.item as q_col loop
					------------------
					s := q_col.item.get_value
					if not s.is_empty then
						across s.split(';') as value loop
							params := value.item.split('/')
							create j_obj.make_empty
							from
								params.start
								info_params.start
							until
								params.off
							loop
								j_obj.put_string (params.item, create {JSON_STRING}.make_from_string (info_params.item.split ('^').first))
								params.forth
								info_params.forth
							end
							j_arr.add (j_obj)
						end
					end
					-----------------
				end
			end
			Result := j_arr.representation
		end
end
