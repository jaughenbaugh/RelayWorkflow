
  CREATE OR REPLACE EDITIONABLE PACKAGE "RLY_DEV02"."PKG_RELAY_QUEUE" as   
-- the use of this package requires additional database objects to be installed
--------------------------------------------------------------------------
g_ad_array tk_ad_array;

type t_ad_rec is record (a number, b anydata, c number);
type t_ad_set is table of t_ad_rec index by pls_integer;
g_ad_set t_ad_set := t_ad_set();
--------------------------------------------------------------------------
-- runs the prepped queue
procedure p_run_queue
(p_queue_id number
,p_auth_id in varchar2);

-- updates the local workflow queue and data from the json response
procedure p_update_queue
(p_queue_id in number);

-- updates the db object that is referenced in the queue object
procedure p_update_owner
(p_queue_id in number);

-- converts date input to unix epoch value
function f_date_to_epoch
(p_input in date)
return number;

-- converts an unix epoch value to date 
function f_epoch_to_date
(p_input in number)
return date;

-- changes data in anydata type to a clob
function f_anydata_to_clob
(p_input sys.anydata)
return clob;

-- changes a clob into an anydata type of the specified datatype
-- only supports DATE input should conform to unix epoch (number in seconds since 01-01-1970 00:00:00)  format
function f_clob_to_anydata
(p_input in clob
,p_data_type in varchar2)
return anydata;

-- initiates the anydata array
procedure p_init_ad_array;

-- builds the queue record and qdata records from an object record
procedure p_load_queue
(p_internal_id in varchar2
,p_flow_name in varchar2
,p_obj_name in varchar2);

-- builds the queue record and qdata records from an object record
-- returning the queue ID
function f_load_queue
(p_internal_id in varchar2
,p_flow_name in varchar2
,p_obj_name in varchar2)
return number;
--------------------------------------------------------------------------
end;
