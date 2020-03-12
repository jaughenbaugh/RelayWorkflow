
  CREATE OR REPLACE EDITIONABLE PACKAGE "RLY_DEV02"."PKG_RELAY_IFACE_APX" as 
-- the use of this package requires application express and an active app session
--------------------------------------------------------------------------
type t_apx_coll is table of apex_collections%rowtype index by pls_integer;
g_apx_coll t_apx_coll;

g_response clob;

g_test number := 0;

g_coll_page number := 0;
g_coll  varchar2(50);
g_c001	apex_application_global.vc_arr2;
g_c002	apex_application_global.vc_arr2;
g_c003	apex_application_global.vc_arr2;
g_c004	apex_application_global.vc_arr2;
g_c005	apex_application_global.vc_arr2;
g_c006	apex_application_global.vc_arr2;
g_c007	apex_application_global.vc_arr2;
g_c008	apex_application_global.vc_arr2;
g_c009	apex_application_global.vc_arr2;
g_c010	apex_application_global.vc_arr2;
g_c011	apex_application_global.vc_arr2;
g_c012	apex_application_global.vc_arr2;
g_c013	apex_application_global.vc_arr2;
g_c014	apex_application_global.vc_arr2;
g_c015	apex_application_global.vc_arr2;
g_c016	apex_application_global.vc_arr2;
g_c017	apex_application_global.vc_arr2;
g_c018	apex_application_global.vc_arr2;
g_c019	apex_application_global.vc_arr2;
g_c020	apex_application_global.vc_arr2; 
g_c021	apex_application_global.vc_arr2; 
-------------------------------------------------------------------------
-- the following programs fetch data from the relay abstract web services
-- and then load it into apex_collections 

-- retrieves all active assignments for a user
procedure p_assignment_list
(p_person_code in varchar2 default null);

-- retrieves workflow object header information
procedure p_object_list
(p_object_name in varchar2 default null
,p_ind_active in number default null);

-- retrieves workflow attributes for an object
procedure p_object_attr
(p_object_name in varchar2);

-- retrieves process information 
procedure p_process_list
(p_process_name in varchar2 default null
,p_object_name in varchar2 default null
,p_ind_enabled in varchar2 default null
,p_ind_active in varchar2 default null
,p_internal_id in varchar2 default null);

-- retrieves workflow instances
procedure p_queue_list
(p_request_id in varchar2 default null
,p_flow_name in varchar2 default null
,p_internal_id in varchar2 default null
,p_node_type in varchar2 default null
,p_object_name in varchar2 default null
,p_change_id in varchar2 default null
,p_ind_closed in varchar2 default null);

-- retrieves the server-side object data
procedure p_queue_data
(p_request_id in varchar2);

-- retrieves the instance variables/values 
procedure p_queue_vars
(p_request_id in varchar2);

-- retrieves the instance history records
procedure p_queue_hist
(p_request_id in varchar2);

-- retrieves instance assignments
procedure p_queue_assign
(p_request_id in varchar2
,p_person_code in varchar2 default null);

-- retrieves decision choices 
procedure p_queue_opts
(p_request_id in varchar2);

-- retrieves resource groups
procedure p_resource_group
(p_description in varchar2 default null
,p_group_name in varchar2 default null
,p_group_status in varchar2 default null);

-- retrieves person resources
procedure p_resource_person_list
(p_email in varchar2 default null
,p_first_name in varchar2 default null
,p_last_name in varchar2 default null
,p_person_code in varchar2 default null
,p_status in varchar2 default null);

--------------------------------------------------------------------------
end;
