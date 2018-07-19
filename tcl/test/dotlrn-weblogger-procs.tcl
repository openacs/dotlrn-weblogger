ad_library {
    Tests for dotlrn-weblogger
}

aa_register_case dotlrn-weblogger_notifications {
} {
    aa_run_with_teardown \
	-rollback \
	-test_code {
	    db_transaction {
		# Create a new dotlrn test user
		array set user [auth::create_user \
				 -email __test@example.com \
				 -first_names __test__ \
				 -last_name __test__]
		set user_id $user(user_id)
		aa_log "User created user_id='${user_id}'"
		dotlrn::user_add -user_id $user_id
		# create a new dotlrn test class
		set community_id [dotlrn_community::new \
				      -community_type dotlrn_community \
				      -pretty_name "__test_community__"]
		aa_log "Community created community_id='${community_id}'"
		# add weblogger to class
		dotlrn_community::add_applet_to_community \
		    $community_id dotlrn_weblogger
		# add user to class
		dotlrn_community::add_user \
		    $community_id $user_id
		# subscribe to weblogger notifications
		set weblogger_package_id \
		    [dotlrn_community::get_applet_package_id \
			 -community_id $community_id \
			 -applet_key dotlrn_weblogger]

		set notif_type_id [notification::type::get_type_id -short_name lars_blogger_notif]
		set request_id [notification::request::new \
		    -type_id $notif_type_id \
		    -user_id $user_id \
		    -object_id $weblogger_package_id \
		    -interval_id [notification::get_interval_id -name instant]\
				    -delivery_method_id [notification::get_delivery_method_id -name email]]
		# drop user from class
		dotlrn_community::remove_user $community_id $user_id
		# check for notifications
		set request_id [notification::request::get_request_id \
				 -type_id $notif_type_id \
				 -object_id $weblogger_package_id \
				 -user_id $user_id]
		aa_true "Notification dropped" [string equal "" $request_id]
	    }   
	} -teardown_code {
	    #clean up site node cache
	    ns_log notice "\nDAVEB99:START running teardown code\n"
	    site_node::update_cache -node_id [dotlrn::get_node_id] -sync_children
	    ns_log notice "\nDAVEB99:DONE running teardown code\n"	    
	}
}

aa_register_case dotlrn-weblogger_notification_member_check {

} {
    aa_run_with_teardown \
	-rollback \
	-test_code {
	    
	    set notif_type_id [notification::type::get_type_id -short_name lars_blogger_notif]

	    # get a list of classes
	    foreach community_id \
		[db_list get_communities \
		     "select community_id from dotlrn_communities_all"] \
		{
		    set weblogger_package_id \
			[dotlrn_community::get_applet_package_id \
			     -community_id $community_id \
			     -applet_key dotlrn_weblogger]
		    
		    set user_ids [list]
		    set wrong_subs [list]
		    foreach user [dotlrn_community::list_users $community_id] {
			lappend user_ids [ns_set get $user user_id]
		    }
		    
		    foreach request_user_id \
			[db_list get_requests \
			     "select user_id from notification_requests
                              where type_id=:notif_type_id
                              and object_id=:weblogger_package_id"] \
			{
			    if {[lsearch -exact $user_ids $request_user_id] < 0} {
				lappend wrong_subs $request_user_id
			    }
			}

		    aa_false "Non-members $wrong_subs subscribed to $weblogger_package_id in $community_id" {[llength $wrong_subs]>0}
		    }
	    # make sure only members are subscribed
	}
    
}
