ad_library {
    Procedures for registering implementations for the
    dotlrn weblogger package. 
    
    @creation-date 8 May 2003
    @author Simon Carstensen (simon@collaboraid.biz)
    @cvs-id $Id$
}

namespace eval dotlrn_weblogger {}

ad_proc -private dotlrn_weblogger::install {} {
    dotLRN Weblogger package install proc
} {
    register_portal_datasource_impl
}

ad_proc -private dotlrn_weblogger::uninstall {} {
    dotLRN Weblogger package uninstall proc
} {
    unregister_portal_datasource_impl
}

ad_proc -private dotlrn_weblogger::register_portal_datasource_impl {} {
    Register the service contract implementation for the dotlrn_applet service contract
} {
    set spec {
        name "dotlrn_weblogger"
	contract_name "dotlrn_applet"
	owner "dotlrn-weblogger"
        aliases {
	    GetPrettyName dotlrn_weblogger::get_pretty_name
	    AddApplet dotlrn_weblogger::add_applet
	    RemoveApplet dotlrn_weblogger::remove_applet
	    AddAppletToCommunity dotlrn_weblogger::add_applet_to_community
	    RemoveAppletFromCommunity dotlrn_weblogger::remove_applet_from_community
	    AddUser dotlrn_weblogger::add_user
	    RemoveUser dotlrn_weblogger::remove_user
	    AddUserToCommunity dotlrn_weblogger::add_user_to_community
	    RemoveUserFromCommunity dotlrn_weblogger::remove_user_from_community
	    AddPortlet dotlrn_weblogger::add_portlet
	    RemovePortlet dotlrn_weblogger::remove_portlet
	    Clone dotlrn_weblogger::clone
	    ChangeEventHandler dotlrn_weblogger::change_event_handler
        }
    }
    
    acs_sc::impl::new_from_spec -spec $spec
}

ad_proc -private dotlrn_weblogger::unregister_portal_datasource_impl {} {
    Unregister service contract implementations
} {
    acs_sc::impl::delete \
        -contract_name "dotlrn_applet" \
        -impl_name "dotlrn_weblogger"
}
