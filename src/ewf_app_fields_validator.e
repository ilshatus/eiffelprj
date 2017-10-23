note
	description: "Summary description for {EWF_APP_FIELDS_VALIDATOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EWF_APP_FIELDS_VALIDATOR

inherit
	EWF_VALIDATOR
	EWF_APP_FIELDS_INFORMATION

create
	make

feature --Initialize
	make(a_data: JSON_ARRAY)
		do
			create data.make (0)
			across a_data.array_representation as curr_field
			loop
				if attached {JSON_STRING}curr_field.item as j_str then
					if j_str.item.prunable then
						j_str.item.prune_all ('\')
					end
					data.force (j_str.item)
				end
			end

			filled_fields := ""
			filled_fields_data := ""
			is_validated := false
			is_valid := false
			validator_initialize
			info_initialize
		end

feature --Execution
	validate
		local
			curr_field_id: INTEGER
			s: STRING
		do
			is_validated := true
			if data.count = format.count then
				is_valid := true
				from
					data.start
					curr_field_id := 0
				until
					data.off
				loop
					if not check_field(data.item, curr_field_id) then
						is_valid := false
						data.finish
					else
						if not data.item.is_empty then
							if not filled_fields.is_empty then
								filled_fields.append (",")
								filled_fields_data.append (",")
							end
							filled_fields.append ("`field" + curr_field_id.out + "`")
							s := ""
							across data.item as curr_ch loop
								if curr_ch.item = '%'' then
									s.append ("'")
								end
								s.append (curr_ch.item.out)
							end
							filled_fields_data.append ("'" + s + "'")
						end
					end
					curr_field_id := curr_field_id + 1
					data.forth
				end

			end
		end

feature{NONE} --Checker methods

	check_field(value: STRING; id: INTEGER): BOOLEAN
		do
			Result := true
			if is_obligatory.array_at (id) and then value.is_empty then
			--	print("%NObligatory field " + id.out + " is empty!..%N")
				Result := false
			elseif not value.is_empty then
				if has_multiple_values.array_at (id) then
				--	print("%NChecking field " + id.out +  " with multiple values...%N")
					Result := check_multiple_values(value.split (';'), format.array_at (id).split ('-'))
				else
				--	print("%NChecking field " + id.out +  " with single value...%N")
					if format.array_at (id) ~ "date" then
						Result := is_correct_format_of_date(value)
						if not Result then
						--	print("%NField has wrong format of date!!%N")
						end
					else
						Result := is_correct_format_of_text(value)
						if not Result then
						--	print("%NField has wrong format of text!!%N")
						end
					end
				end
			end
		end



	check_multiple_values(a_values: LIST[STRING]; a_formats: LIST[STRING]): BOOLEAN
		local
			parametrs: LIST[STRING]
			c_format: LIST[STRING]
		do
			Result := true
		--	print("%NGoing throw " + a_values.count.out + " values...%N")
			across a_values as curr_value  loop
			--	print("%NGoing throw value " + a_values.index.out + " ...%N")
				parametrs := curr_value.item.split ('/')
				if parametrs.count /= a_formats.count then
				--	print("%NNumber of parametrs is wrong!%N")
					Result := false
					a_values.finish
				else
				--	print("%NGoing throw " + parametrs.count.out + " parametrs...%N")
					from
						parametrs.start
						a_formats.start
					until
						parametrs.off or not Result
					loop
					--	print("%NGoing throw parametr " + parametrs.index.out + " ...%N")
						c_format := a_formats.item.split ('^')
						if c_format.count = 1 and then not is_correct_format_of_text(parametrs.item) then
						--	print("%NParametr has wrong format of text!!%N")
							Result := false
							a_values.finish
						elseif c_format.count = 2 then
							if c_format.at (2) ~ "date" and then not is_correct_format_of_date2(parametrs.item) then
							--	print("%NParametr has wrong format of date!!%N")
								Result := false
								a_values.finish
							elseif c_format.at (2) ~ "number" and then not parametrs.item.is_integer then
							--	print("%NParametr has wrong format of number!!%N")
								Result := false
								a_values.finish
							end
						end
						parametrs.forth
						a_formats.forth
					end
				end
			end
		end

feature --Access

	is_valid: BOOLEAN
	is_validated: BOOLEAN
	filled_fields: STRING
	filled_fields_data: STRING

feature{NONE} --Attributes
	data: ARRAYED_LIST[STRING]
end
