ad_library {
    
    Procs to set up the dotLRN weblogger applet
    
    @author simon@collaboraid.biz
}

namespace eval dotlrn_weblogger {}
    
ad_proc -public dotlrn_weblogger::applet_key {} {
    What's my applet key?
} {
    return dotlrn_weblogger
}

ad_proc -public dotlrn_weblogger::package_key {} {
    What package do I deal with?
} {
    return "lars-blogger"
}

ad_proc -public dotlrn_weblogger::my_package_key {} {
    What package do I deal with?
} {
    return "dotlrn-weblogger"
}

ad_proc -public dotlrn_weblogger::get_pretty_name {} {
    returns the pretty name
} {
    return "Weblogger"
}

ad_proc -public dotlrn_weblogger::add_applet {} {
    One time init - must be repeatable!
} {
    dotlrn_applet::add_applet_to_dotlrn -applet_key [applet_key] -package_key [my_package_key]
}

ad_proc -public dotlrn_weblogger::remove_applet {} {
    One time destroy. 
} {
    dotlrn_applet::remove_applet_from_dotlrn -applet_key [applet_key]
}

ad_proc -public dotlrn_weblogger::add_applet_to_community {
    community_id
} {
    Add the weblogger applet to a specifc dotlrn community
} {
    set portal_id [dotlrn_community::get_portal_id -community_id $community_id]

    # create the weblogger package instance (all in one, I've mounted it)
    set package_id [dotlrn::instantiate_and_mount $community_id [package_key]]

    # set up the admin portal
    set admin_portal_id [dotlrn_community::get_admin_portal_id \
                             -community_id $community_id
                        ]

    weblogger_admin_portlet::add_self_to_page \
        -portal_id $admin_portal_id \
        -package_id $package_id
    
    set args [ns_set create]
    ns_set put $args package_id $package_id
    add_portlet_helper $portal_id $args

    return $package_id
}

ad_proc -public dotlrn_weblogger::remove_applet_from_community {
    community_id
} {
    remove the applet from the community
} {
    ad_return_complaint 1 "[applet_key] remove_applet_from_community not implimented!"
}

ad_proc -public dotlrn_weblogger::add_user {
    user_id
} {
    one time user-specifuc init
} {
    # noop
}

ad_proc -public dotlrn_weblogger::remove_user {
    user_id
} {
} {
    ad_return_complaint 1 "[applet_key] remove_user not implimented!"
}

ad_proc -public dotlrn_weblogger::add_user_to_community {
    community_id
    user_id
} {
    Add a user to a specifc dotlrn community
} {
    set package_id [dotlrn_community::get_applet_package_id -community_id $community_id -applet_key [applet_key]]
    set portal_id [dotlrn::get_portal_id -user_id $user_id]

    # use "append" here since we want to aggregate
    set args [ns_set create]
    ns_set put $args package_id $package_id
    ns_set put $args param_action append
    add_portlet_helper $portal_id $args
}

ad_proc -public dotlrn_weblogger::remove_user_from_community {
    community_id
    user_id
} {
    Remove a user from a community
} {
    set package_id [dotlrn_community::get_applet_package_id -community_id $community_id -applet_key [applet_key]]
    set portal_id [dotlrn::get_portal_id -user_id $user_id]

    set args [ns_set create]
    ns_set put $args package_id $package_id

    remove_portlet $portal_id $args
}

ad_proc -public dotlrn_weblogger::add_portlet {
    portal_id
} {
    A helper proc to add the underlying portlet to the given portal. 
    
    @param portal_id
} {
    # simple, no type specific stuff, just set some dummy values

    set args [ns_set create]
    ns_set put $args package_id 0
    ns_set put $args param_action overwrite
    add_portlet_helper $portal_id $args
}

ad_proc -public dotlrn_weblogger::add_portlet_helper {
    portal_id
    args
} {
    A helper proc to add the underlying portlet to the given portal.

    @param portal_id
    @param args an ns_set
} {
    weblogger_portlet::add_self_to_page \
        -portal_id $portal_id \
        -package_id [ns_set get $args package_id] \
        -param_action [ns_set get $args param_action]
}

ad_proc -public dotlrn_weblogger::remove_portlet {
    portal_id
    args
} {
    A helper proc to remove the underlying portlet from the given portal. 
    
    @param portal_id
    @param args A list of key-value pairs (possibly user_id, community_id, and more)
} { 
    weblogger_portlet::remove_self_from_page \
        -portal_id $portal_id \
        -package_id [ns_set get $args package_id]
}

ad_proc -public dotlrn_weblogger::clone {
    old_community_id
    new_community_id
} {
    Clone this applet's content from the old community to the new one
} {
    ns_log notice "Cloning: [applet_key]"
    set new_package_id [add_applet_to_community $new_community_id]
    set old_package_id [dotlrn_community::get_applet_package_id \
                            -community_id $old_community_id \
                            -applet_key [applet_key]
                       ]

    db_exec_plsql call_weblogger_clone {}
    return $new_package_id
}

ad_proc -public dotlrn_weblogger::change_event_handler {
    community_id
    event
    old_value
    new_value
} { 
    listens for the following events: 
} { 
}   

