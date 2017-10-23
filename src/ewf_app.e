note
	description: "[
				application service
			]"
	date: "$Date: 2016-10-21 09:45:18 -0800 (Fri, 21 Oct 2016) $"
	revision: "$Revision: 99331 $"

class
	EWF_APP


inherit
	WSF_LAUNCHABLE_SERVICE
		redefine
			initialize
		end
	APPLICATION_LAUNCHER [EWF_APP_EXECUTION]


create
	make_and_launch

feature {NONE} -- Initialization

	initialize
			-- Initialize current service.
		do
			Precursor
			set_service_option ("port", 9090)
			set_service_option ("verbose", "yes")
		end


end
