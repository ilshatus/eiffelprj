note
	description: "Summary description for {EWF_APP_FIELDS_INFORMATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EWF_APP_FIELDS_INFORMATION

inherit
	EWF_APP_DATABASE

create
	info_initialize

feature{NONE} -- Initialize
	info_initialize
		do
			create format.make (0)
			create is_obligatory.make (0)
			create has_multiple_values.make (0)
			create name.make(0)
			read_attributes
		end

feature{NONE} -- Helper

	read_attributes
		local
			q_res: ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
		do
			q_res := execute_query ("SELECT * FROM `fields`")
			across q_res as  q_row loop
				across q_row.item as q_col loop
					------------------
					if q_col.item.get_name.is_equal ("name") then
						name.force(q_col.item.get_value)
					elseif q_col.item.get_name.is_equal ("format") then
						format.force (q_col.item.get_value)
					elseif q_col.item.get_name.is_equal ("obligatory") then
						if q_col.item.get_value.to_integer = 1 then
							is_obligatory.force (true);
						else
							is_obligatory.force (false);
						end
					elseif q_col.item.get_name.is_equal ("multiple_values") then
						if q_col.item.get_value.to_integer = 1 then
							has_multiple_values.force (true);
						else
							has_multiple_values.force (false);
						end
					end
					-----------------
				end
			end
		end

feature --Access
	get_name(i: INTEGER): STRING
		do
			if i <= name.count and i >= 1 then
				Result := name.at (i)
			end
		end

	get_format(i: INTEGER): STRING
		do
			if i <= format.count and i >= 1 then
				Result := format.at (i)
			end
		end

	get_is_obligatory(i: INTEGER): BOOLEAN
		do
			if i <= is_obligatory.count and i >= 1 then
				Result := is_obligatory.at (i)
			end
		end

	get_has_multiple_values(i: INTEGER): BOOLEAN
		do
			if i <= has_multiple_values.count and i >= 1 then
				Result := has_multiple_values.at (i)
			end
		end

feature{NONE} --Attributes
	name: ARRAYED_LIST[STRING]
	format: ARRAYED_LIST[STRING]
	is_obligatory: ARRAYED_LIST[BOOLEAN]
	has_multiple_values: ARRAYED_LIST[BOOLEAN]
end
