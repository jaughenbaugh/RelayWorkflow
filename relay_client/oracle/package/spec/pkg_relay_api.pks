
  CREATE OR REPLACE EDITIONABLE PACKAGE "RLY_DEV02"."PKG_RELAY_API" 
as 
-- the use of this package does not require any additional items beyond the database
--------------------------------------------------------------------------
  type t_obj_attr is record(a varchar2(4000), b varchar(4000));
  type t_obj is table of t_obj_attr index by pls_integer;

  -- interface (run) body variables
  g_a             VARCHAR2(4000); -- request_id (I/O)
  g_b             VARCHAR2(4000); -- internal_id (I/O)
  g_c             VARCHAR2(4000); -- auth_id (I)
  g_d             VARCHAR2(4000); -- process_name (I/O)
  g_e             VARCHAR2(4000); -- object_id (I/O)
  g_f             VARCHAR2(4000); -- input_assignment (I)
  g_g             VARCHAR2(4000); -- input_choice (I)
  g_h             VARCHAR2(4000); -- node_type (O)
  g_i             VARCHAR2(4000); -- change_id (I/O)
  g_j             VARCHAR2(4000); -- time limit (O)
  g_k             VARCHAR2(4000); -- indicator conditional (O)
  g_owner_data    t_obj := t_obj(); -- (I/O)
  g_res_reply     t_obj := t_obj(); -- (I)
  g_assignments   number; -- t_obj := t_obj(); -- (O)
  g_res_req       number; -- t_obj := t_obj(); -- (O)
  g_choices       number; -- t_obj := t_obj(); -- (O)
  g_alert_log     number; -- t_obj := t_obj(); -- (O)
  g_err_log       number; -- t_obj := t_obj(); -- (O)

  -- connection values
  g_relay_url varchar2(4000) := 'https://loa4qoehldoqc9p-luna.adb.us-ashburn-1.oraclecloudapps.com/ords/relay';   
  g_oauth_url varchar2(4000) := g_relay_url||'/oauth/token';
  g_auth_id   varchar2(4000) := 'LkS0MkgPuFptmHiyN1rbfQ..';
  g_auth_pw   varchar2(4000) := 'ijm3GtDV1mrlx-GCw2KTRw..';
  g_auth_code varchar2(4000) := '926AC7C7C80D25B4F84CEB7382F392EA';

  -- REST Response Body
  g_response clob;

  -- api service urls for programs
  g_relay_interface varchar2(200) := g_relay_url||'/programs/RELAY_INTERFACE';
  g_refresh_instance varchar2(200) := g_relay_url||'/programs/REFRESH_INSTANCE';
  g_stop_instance varchar2(200) := g_relay_url||'/programs/STOP_INSTANCE';

--------------------------------------------------------------------------
-- the workflow interface program 
procedure p_interface;

-- kills a workflow instance
procedure p_stop
(p_request_id in varchar2);

-- pulls the current state of an instance 
procedure p_refresh
(p_request_id in varchar2);

-- gets data from one of the GET services
procedure p_data_service
(p_service in varchar2);
--------------------------------------------------------------------------
end;