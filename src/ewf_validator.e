note
	description: "Summary description for {EWF_VALIDATOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EWF_VALIDATOR

create
	validator_initialize

feature{NONE} --Initialize
	validator_initialize
		do
			create reg_exp_test.make
		end

feature --Access

	is_correct_format_of_year(value: STRING): BOOLEAN
		do
			reg_exp_test.compile (year_pattern)
			if reg_exp_test.is_compiled then
				Result := reg_exp_test.matches (value)
			end
		end

	is_correct_format_of_text(value: STRING): BOOLEAN
		do
			reg_exp_test.compile (text_pattern)
			if reg_exp_test.is_compiled then
				Result := reg_exp_test.matches (value)
			end
		end


	is_correct_format_of_date(value: STRING): BOOLEAN
		do
			reg_exp_test.compile (date_pattern)
			if reg_exp_test.is_compiled then
				Result := reg_exp_test.matches (value)
			end
		end

	is_correct_format_of_date2(value: STRING): BOOLEAN
		do
			reg_exp_test.compile (date_pattern2)
			if reg_exp_test.is_compiled then
				Result := reg_exp_test.matches (value)
			end
		end


feature{NONE} --Attributes
	year_pattern: STRING
		once
			Result := "^[0-9]{4}$"
		end

	date_pattern: STRING
		once
			Result := "^[0-9]{4}-((0[1-9])|(1[0-2]))-((0[1-9])|([12][0-9])|(3[01]))$"
		end

	date_pattern2: STRING
		once
			Result := "^((0[1-9])|([12][0-9])|(3[01])).((0[1-9])|(1[0-2])).[0-9]{4}$"
		end

	text_pattern: STRING
		once
			Result := "^[a-zA-Z0-9'%",.:?!\-() ]+$"
		end

	reg_exp_test: RX_PCRE_REGULAR_EXPRESSION

end
