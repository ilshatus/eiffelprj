note
	description: "[
				application execution
			]"
	date: "$Date: 2016-10-21 09:45:18 -0800 (Fri, 21 Oct 2016) $"
	revision: "$Revision: 99331 $"

class
	EWF_APP_EXECUTION


inherit



	WSF_ROUTED_EXECUTION
		redefine
			initialize
		end

	WSF_URI_HELPER_FOR_ROUTED_EXECUTION

	WSF_URI_TEMPLATE_HELPER_FOR_ROUTED_EXECUTION

	EWF_APP_DATABASE

	EWF_QUERIES


create
	make

feature {NONE} -- Initialization
	initialize
		do
			Precursor
			initialize_db
			initialize_router
			queries_initialize
		end

feature -- Attributes

feature -- Router

	setup_router
			-- Setup `router'
		local
			fhdl: WSF_FILE_SYSTEM_HANDLER
		do

			map_uri_agent ("/load/pages", agent handle_load_pages, router.methods_GET)
			map_uri_agent ("/load/fields", agent handle_load_fields, router.methods_GET)
			map_uri_agent ("/send/form", agent handle_sent_form, router.methods_POST)
			map_uri_template_agent ("/admin/query/{id}", agent handle_query, router.methods_GET)

			router.handle ("/doc", create {WSF_ROUTER_SELF_DOCUMENTATION_HANDLER}.make (router), router.methods_GET)
			create fhdl.make_hidden ("www")
			fhdl.set_directory_index (<<"index.html">>)
			fhdl.set_default_index_ignores
			router.handle ("", fhdl, router.methods_GET)

		end

feature --Execution



	handle_load_pages(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			s: STRING
			data: JSON_ARRAY
			j_obj: JSON_OBJECT
			q_res: ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
		do
			create data.make_empty
			q_res := execute_query("SELECT * FROM `pages`")
			across q_res as  q_row loop
				create j_obj.make_empty
				across q_row.item as q_col loop
					if q_col.item.get_value.is_integer then
						j_obj.put_integer (q_col.item.get_value.to_integer, create {JSON_STRING}.make_from_string (q_col.item.get_name))
					else
						j_obj.put_string (q_col.item.get_value, create {JSON_STRING}.make_from_string (q_col.item.get_name))
					end
				end
				data.add (j_obj)
			end
			s := data.representation
			res.set_status_code ({HTTP_STATUS_CODE}.ok)
			res.put_header_line ("Content-Type: application/json")
			res.put_header_line ("Content-Length: " + s.count.out)
			res.put_string (s)
		end


	handle_load_fields(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			s: STRING
			data: JSON_ARRAY
			j_obj: JSON_OBJECT
			q_res: ARRAYED_LIST[ARRAYED_LIST[EWF_APP_DATABASE_PAIR]]
		do
			create data.make_empty
			if
				attached {WSF_STRING} req.query_parameter ("pageId") as p_value
			then
				if p_value.value.is_integer then
					if p_value.value.is_integer then
						q_res := execute_query("SELECT * FROM `fields` WHERE `pageId` = '" + p_value.value + "'")
						across q_res as  q_row loop
							create j_obj.make_empty
							across q_row.item as q_col loop
								if q_col.item.get_value.is_integer then
									j_obj.put_integer (q_col.item.get_value.to_integer, create {JSON_STRING}.make_from_string (q_col.item.get_name))
								else
									j_obj.put_string (q_col.item.get_value, create {JSON_STRING}.make_from_string (q_col.item.get_name))
								end
							end
							data.add (j_obj)
						end
					end
				end
			end
			s := data.representation
			res.set_status_code ({HTTP_STATUS_CODE}.ok)
			res.put_header_line ("Content-Type: application/json")
			res.put_header_line ("Content-Length: " + s.count.out)
			res.put_string (s)
		end


	handle_sent_form(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			j_parser: JSON_PARSER
			s: STRING
			validator: EWF_APP_FIELDS_VALIDATOR
			sql_query: STRING
		do
			s := "Invalid request!"
			if attached {WSF_STRING} req.form_parameter ("jsonData") as json_data then
				create j_parser.make_with_string (json_data.value)
				j_parser.parse_content
				if j_parser.is_valid and then attached j_parser.parsed_json_array as j_array_data then
					create validator.make(j_array_data)
					validator.validate
					if validator.is_valid then
						sql_query := "INSERT INTO `reports` (" + validator.filled_fields + ") VALUES (" + validator.filled_fields_data + ")"
						execute_insert (sql_query)
						s := "ok"
					else
						s := "Invalid report!"
					end
				end
			end
			res.set_status_code ({HTTP_STATUS_CODE}.ok)
			res.put_header_line ("Content-Type: text/plain")
			res.put_header_line ("Content-Length: " + s.count.out)
			res.put_string (s)
		end

	handle_query(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			s: STRING
			validator: EWF_VALIDATOR
		do
			create validator.validator_initialize
			s := "Invalid query!"
			if attached {WSF_STRING}req.path_parameter ("id") as id and then id.is_integer then
				inspect id.value.to_integer
				when 0 then
					if
						attached {WSF_STRING}req.query_parameter ("par0") as year and then
						validator.is_correct_format_of_year (year.value)
					then
						s := all_publications(year.value)
					else
						s := "Wrong parametrs!"
					end
				when 1 then
					if
						attached {WSF_STRING}req.query_parameter ("par0") as unit and then
						validator.is_correct_format_of_text(unit.value)
					then
						s := cumulative_information(unit.value)
					else
						s := "Wrong parametrs!"
					end
				when 2 then
					if
						attached {WSF_STRING}req.query_parameter ("par0") as init_date and then
						validator.is_correct_format_of_date(init_date.value) and then
						attached {WSF_STRING}req.query_parameter ("par1") as fin_date and then
						validator.is_correct_format_of_date(fin_date.value)
					then
						s := courses_taught(init_date.value, fin_date.value)
					else
						s := "Wrong parametrs!"
					end
				when 3 then
					if
						attached {WSF_STRING}req.query_parameter ("par0") as unit and then
						validator.is_correct_format_of_text(unit.value)
					then
						s := number_of_supervised_students(unit.value)
					else
						s := "Wrong parametrs!"
					end
				when 4 then
					if
						attached {WSF_STRING}req.query_parameter ("par0") as unit and then
						validator.is_correct_format_of_text(unit.value)
					then
						s := number_of_research_collabarations(unit.value)
					else
						s := "Wrong parametrs!"
					end;
				when 5 then
					if
						attached {WSF_STRING}req.query_parameter ("par0") as unit and then
						validator.is_correct_format_of_text(unit.value)
					then
						s := list_of_phds(unit.value)
					else
						s := "Wrong parametrs!"
					end
				when 6 then
					if
						attached {WSF_STRING}req.query_parameter ("par0") as unit and then
						validator.is_correct_format_of_text(unit.value)
					then
						s := list_of_patents(unit.value)
					else
						s := "Wrong parametrs!"
					end
				else
					s := "Wrong id of query!"
				end
			else
				s := "Wrong id of query!"
			end
			res.set_status_code ({HTTP_STATUS_CODE}.ok)
			res.put_header_line ("Content-Type: application/json")
			res.put_header_line ("Content-Length: " + s.count.out)
			res.put_string (s)
		end
end
