--------------------------------------------------------
--  DDL for Package PKG_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_WORKFLOW" as
/*******************************************************************************
-- PACKAGE: pkg_workflow_new
--
-- PURPOSE: Package Purpose
--
-- SVN: $Id: $
-- $HeadURL: $
--
--------------------------------------------------------------------------------
-- REVISION HISTORY:
--
--   DATE        VERSION NAME               DESCRIPTION
--   ----------- ------- ------------------ ------------------------------------
--   23-MAR-2016 0.1.0   Jason Aughenbaugh  Initial revision
*******************************************************************************/
--GLOBAL-PUBLIC-VARIABLES-------------------------------------------------------
  g_workflow_index number := 1;

  g_imp_content blob;

  g_ind_run_code number := 0;

  g_active_instance awf_instance.id_record%type;

  type t_io_values is table of awf_inst_vars%rowtype index by varchar2(128);
  type tt_io_values is table of t_io_values index by pls_integer;
  g_inst_own_values tt_io_values;

  type t_active_pv is table of sys.anydata index by varchar2(100);
  g_debug varchar2(100); -- := 'DEBUG'; --> TODO Set from Application

--PROGRAM-SPECIFICATIONS--------------------------------------------------------
function f_get_version
return varchar2;

function f_active_process
(p_id_process in awf_process.id_record%type default null)
return awf_process.id_record%type;

procedure run_workflow
(p_id_instance in awf_instance.id_record%type
,p_id_link in awf_node_link.id_proc_rec%type default null
,p_id_assign in awf_inst_assign.id_record%type default null);

function f_run_workflow
(p_id_instance in awf_instance.id_record%type
,p_id_link in awf_node_link.id_proc_rec%type default null
,p_id_assign in awf_inst_assign.id_record%type default null)
return number;

-- used by dbms_scheduler job to restart certain paused instances 
--procedure p_inst_autorun;

--------------------------------------------------------------------------------
-- copied from PKG_WF_BUILDER
--------------------------------------------------------------------------------
-- FUNCTION: f_an_main
--
-- PURPOSE:       Describe Purpose of the Procedure
-- ARGUMENTS:     None
-- RETURN:        number
-- ACCESS:        PUBLIC
-- -----------------------------------------------------------------------------
function f_an_main
return number;

--------------------------------------------------------------------------------
-- FUNCTION: f_an_stamp
--
-- PURPOSE:       Describe Purpose of the Procedure
-- ARGUMENTS:     None
-- RETURN:        number
-- ACCESS:        PUBLIC
-- -----------------------------------------------------------------------------
function f_an_stamp
return number;

--------------------------------------------------------------------------------
-- FUNCTION: f_an_proc
--
-- PURPOSE:       Describe Purpose of the Procedure
-- ARGUMENTS:     p_id_process
-- RETURN:        number
-- ACCESS:        PUBLIC
-- -----------------------------------------------------------------------------
function f_an_proc
(p_id_process in awf_process.id_record%type)
return number;

function f_eval_conditions
(p_id_proc_rec in awf_conditions.id_proc_rec%type
,p_amt_for_true in awf_node.amt_for_true%type
,p_id_instance in awf_instance.id_record%type default null)
return number;
--------------------------------------------------------------------------------
function f_process_import
(p_json in blob)
return number;
--------------------------------------------------------------------------------

function f_process_export
(p_id_process in number)
return blob;

/*
function f_proc_copy
(p_id_process in number
,p_action in varchar2
,p_name in varchar2 default null
,p_description in varchar2 default null)
return number;
*/

function f_proc_copy
(p_id_process in number
,p_action in varchar2
,p_name in varchar2 default null
,p_description in varchar2 default null
,p_output out varchar2)
return number;

procedure p_delete_process
(p_id_process varchar2);

-->
procedure p_run_license;
procedure p_pkg_reset;

function f_assign_exists
(p_id_process in number
,p_id_node in number)
return varchar2;

end ;

/
