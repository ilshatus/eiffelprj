note
	description: "Summary description for {EWF_APP_DATABASE_PAIR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EWF_APP_DATABASE_PAIR
create
	make
feature{NONE}
	make(f, s: STRING)
		do
			name := f
			value := s
		end
feature --Access
	get_name: STRING
		do
			Result := name
		end
	get_value: STRING
		do
			Result := value
		end


feature{NONE} --Attributes
	name: STRING
	value: STRING


end
