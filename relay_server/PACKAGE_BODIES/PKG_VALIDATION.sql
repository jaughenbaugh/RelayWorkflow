--------------------------------------------------------
--  DDL for Package Body PKG_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_VALIDATION" 
is
g_copyright varchar2(200) := 'Copyright © 2018 Jason D. Aughenbaugh. All rights reserved.'
                           ||'Unwrapping, Decrypting, or attempting to retrieve source code'
                           ||'without express, written, consent is forbidden.';
/*******************************************************************************
-- PACKAGE: pkg_validation
--
-- PURPOSE: 
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
--GLOBALS-----------------------------------------------------------------------
g_id_process number;
g_val_text clob;

type t_val_line is record (line_code varchar2(30) -- NOTE/WARNING/ERROR
                          ,comp_type varchar2(50) -- WF Element
                          ,id_proc_rec number -- process element id
                          ,node_name varchar2(500) -- node name
                          ,val_text varchar2(4000)); --validation note
type t_val_t is table of t_val_line index by pls_integer;
g_val_t t_val_t;
g_val_t2 t_val_t;
g_val_idx number := 0; -- initial validation index

g_process rly_process_acct%rowtype;

type t_proc_vars_r is record (src varchar2(100), var_name varchar2(100), data_type varchar2(100));
type t_proc_vars_t is table of t_proc_vars_r index by varchar2(200);
g_proc_vars t_proc_vars_t;

type t_oprivs_r is record (obj_owner varchar2(100), obj_name varchar2(100), privs varchar2(200));
type t_oprivs_t is table of t_oprivs_r index by varchar2(100);
g_owner_privs t_oprivs_t;

type t_prog_r is record (obj_owner varchar2(100)
                        ,obj_name varchar2(1000)
                        ,obj_type varchar2(100));
type t_prog_t is table of t_prog_r index by varchar2(1000);
g_prog t_prog_t;

g_errors number := 0;
g_warn number := 0;

g_version varchar2(100) := '#VERSION#';
--PROGRAMS----------------------------------------------------------------------
function f_get_version
return varchar2
as
begin
  return g_version;
end ;
--------------------------------------------------------------------------------
procedure p_cre_val_entry
(p_line_code in varchar2
,p_comp_type in varchar2
,p_id_proc_rec in varchar2
,p_node_name in varchar2
,p_val_text in varchar2)
as

begin

  g_val_idx := g_val_idx + 1;
  g_val_t(g_val_idx).line_code := p_line_code;
  g_val_t(g_val_idx).comp_type := p_comp_type;
  g_val_t(g_val_idx).id_proc_rec := p_id_proc_rec;
  g_val_t(g_val_idx).node_name := p_node_name;
  g_val_t(g_val_idx).val_text := p_val_text;

end ;
--------------------------------------------------------------------------------
procedure p_val_node
as

  type t_node is table of awf_node%rowtype index by pls_integer;
  l_node t_node;

  l_start_nodes number := 0;
  l_stop_nodes  number := 0;  

begin

  -- List all nodes for the process id with additional metrics
  for idx in (select n.id_process
                    ,n.id_proc_rec
                    ,n.node_type
                    ,max(n.description) node_name
                    ,count(na1.id_process) actions
                    ,count(na2.id_process) assignments
                    ,(select count(id_process) from awf_node_link where id_process = n.id_process and id_parent_node = n.id_proc_rec) p_links
                    ,(select count(id_process) from awf_node_link where id_process = n.id_process and id_parent_node = n.id_proc_rec and ind_is_positive = 1) p_pos_links
                    ,(select count(id_process) from awf_node_link where id_process = n.id_process and id_parent_node = n.id_proc_rec and ind_is_positive = 0) p_neg_links
                    ,(select count(id_process) from awf_node_link where id_process = n.id_process and id_child_node = n.id_proc_rec) c_links
                    ,count(ns.id_process) s_process
                    ,count(c.id_record) cond
              from   awf_node n
                    ,awf_node_action na1
                    ,awf_node_assignment na2
                    ,awf_node_subprocess ns
                    ,awf_conditions c
              where  na1.id_process (+)= n.id_process
                and  na1.id_node_number (+)= n.id_proc_rec
                and  na2.id_process (+)= n.id_process
                and  na2.node_number (+)= n.id_proc_rec
                and  ns.id_process (+)= n.id_process
                and  ns.id_node (+)= n.id_proc_rec
                and  c.id_process (+)= n.id_process
                and  c.id_proc_rec (+)= n.id_proc_rec
                and  n.id_process = g_process.id_record
              group by n.id_process, n.id_proc_rec, n.node_type
              order by n.id_process, n.id_proc_rec) 
  loop
    -- required nodes (evaluated after loop completes)
    if idx.node_type = 'START' then
      -- count up the start nodes
      l_start_nodes := l_start_nodes + 1;
    elsif idx.node_type = 'STOP' then
      -- count up the start nodes 
      l_stop_nodes := l_stop_nodes + 1;
    end if;

    -- required links
    -- parent links
    if idx.c_links > 0 
      and idx.node_type = 'START'
    then 
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'INVALID: Node Cannt be the child of another node');
      g_errors := g_errors + 1;
    elsif idx.c_links = 0 
      and idx.node_type != 'START'
    then 
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'INVALID: Node Must be the child of another node');
      g_errors := g_errors + 1;
    end if;

    --child links
    -- stop node only
    if idx.p_links > 0 
      and idx.node_type = 'STOP'
    then 
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'INVALID: Node Cannot be the parent of another node');
      g_errors := g_errors + 1;
    end if;

    -- negative links
    if idx.p_neg_links != 1 
      and idx.node_type in ('DESCISION','MATRIX','CONDITION')
    then        
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'INVALID: Node must have only one Negative Link');
      g_errors := g_errors + 1;
    elsif idx.p_neg_links > 1 
    then        
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'INVALID: Node cannot have a Negative Link');
      g_errors := g_errors + 1;
    end if;

    -- positive links
    if idx.p_pos_links = 0 
      and idx.node_type != 'STOP'      
    then        
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'INVALID: Node must have at least one positive Link');
      g_errors := g_errors + 1;
    elsif idx.p_neg_links > 1 
      and idx.node_type not in ('DESCISION','MATRIX')
    then        
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'INVALID: Node cannot have more than one Positive Link');
      g_errors := g_errors + 1;
    end if;

    -- required assignments
    if idx.assignments = 0 
      and idx.node_type in ('TASK','DECISION')
    then       
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'Node must have at least one assignment');
      g_errors := g_errors + 1;
    elsif idx.assignments > 0 
      and idx.node_type not in ('TASK','DECISION')
    then      
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'Node cannot have any assignments');
      g_errors := g_errors + 1;
    end if;

    -- required actions
    if idx.actions = 0 
      and idx.node_type = 'ACTION'
    then       
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'Node must have at least one action');
      g_errors := g_errors + 1;
    elsif idx.actions > 0 
      and idx.node_type != 'ACTION'
    then      
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'Node cannot have any action');
      g_errors := g_errors + 1;
    end if;    

    -- required subprocesses
    if idx.actions = 0 
      and idx.node_type = 'SUBPROCESS'
    then       
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'Node must have at least one sub-process');
      g_errors := g_errors + 1;
    elsif idx.actions > 0 
      and idx.node_type != 'SUBPROCESS'
    then      
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'Node cannot have any sub-processes');
      g_errors := g_errors + 1;
    end if;

    -- required conditions
    if idx.cond = 0 
      and idx.node_type = 'CONDITION'
    then
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'Node Must have at least one condition');
      g_errors := g_errors + 1;
    elsif idx.cond > 0 
      and idx.node_type not in ('CONDITION','WAIT','TASK')
    then
      p_cre_val_entry(' ERROR','NODE',idx.id_proc_rec,idx.node_name,'Node cannot have any conditions');
      g_errors := g_errors + 1;
    end if;

  end loop;

  -- check to see if there is only one start node
  if l_start_nodes != 1 then    
    p_cre_val_entry(' ERROR','NODE',null,null,'INVALID START: There must be only one (1) Start Node in a Process.  ['||l_start_nodes||']');
    g_errors := g_errors + 1;
  end if;

  -- Check to see if there is at least one stop node
  if l_stop_nodes = 0 then    
    p_cre_val_entry(' ERROR','NODE',null,null,'NO STOP: There must be at least one (1) Stop Node in a Process.  ['||l_stop_nodes||']');
    g_errors := g_errors + 1;
  end if;

  p_cre_val_entry(' NOTE','NODES',null,null,'Node Validation Completed');

exception
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_val_proc_vars
as
  g_hash varchar2(100) := '#HASH#';
begin

  for idx in (select pv.*
                   ,(select lower(column_name) 
                     from sys.all_tab_cols 
                     where owner = g_process.obj_owner 
                       and table_name = g_process.obj_name
                       and lower(column_name) = lower(pv.var_name)) atc_column
              from   (select * from awf_proc_vars where id_process = g_process.id_record) pv ) 
  loop

    case 
      when idx.var_type not like '%LOB' 
        and (idx.dflt_clob_value is not null or idx.dflt_blob_value is not null) then

          p_cre_val_entry(' ERROR','PROC_VARS',idx.id_record,idx.var_name,'LOB Value recorded for non-LOB variable');
          g_errors := g_errors + 1;

      when idx.var_type like '%LOB' 
        and idx.default_var_value is not null 
        and (idx.dflt_clob_value is not null or idx.dflt_blob_value is not null) then

          p_cre_val_entry(' WARNING','PROC_VARS',idx.id_record,idx.var_name,'LOB Value stored in multiple columns');
          g_warn := g_warn + 1;

      when idx.var_type like '%LOB' 
        and idx.default_var_value is not null 
        and (idx.dflt_clob_value is null or idx.dflt_blob_value is null) then

          p_cre_val_entry(' ERROR','PROC_VARS',idx.id_record,idx.var_name,'LOB Value stored Incorrectly');
          g_errors := g_errors + 1;

      else
        null;
    end case;

    if nvl(idx.atc_column,'-1') != '-1' then

      p_cre_val_entry(' ERROR','PROC_VARS',idx.id_record,idx.var_name,'Workflow Variables cannot have the same name as owner columns');
      g_errors := g_errors + 1;

    end if;

    null;

  end loop;

  p_cre_val_entry(' NOTE','PROC_VARS',null,null,'Process Variable Validation Completed');

--exception 
  --when others then
    --raise;
end ;
--------------------------------------------------------------------------------
procedure p_val_process
(p_id_process in number)
as
  l_eo_data rly_obj_acct%rowtype;
begin

  -- load process data for validations
  select *
  into   g_process
  from   rly_process_acct
  where  id_record = p_id_process;

  for idx in (select 'PROCVAR' src, var_name, var_type data_type
              from   awf_proc_vars
              where  id_process = p_id_process
              union all
              select 'COLUMN' src, attr_name column_name, attr_type data_type
              from   rly_obj_attr_acct
              where  acct_id = g_process.acct_id
                and  id_object = (select id_record 
                                  from rly_obj_acct
                                  where obj_name = g_process.obj_name
                                    and acct_id = g_process.acct_id))
  loop

    g_proc_vars(idx.var_name).src := idx.src;
    g_proc_vars(idx.var_name).var_name := idx.var_name;
    g_proc_vars(idx.var_name).data_type := idx.data_type;

  end loop;

  -- load the eo data
  select *
  into   l_eo_data
  from   rly_obj_acct 
  where  acct_id = g_process.acct_id
    and  obj_name = g_process.obj_name;

  -- Check if EO record is disabled
  if l_eo_data.ind_active = 0 then

    p_cre_val_entry(' ERROR','PROCESS',null,null,'Enabled Object Record is marked as disabled');
    g_errors := g_errors + 1;

  end if;

  p_cre_val_entry(' NOTE','PROCESS',null,null,'Process Header Data Validation Completed');

end ;  
--------------------------------------------------------------------------------
procedure p_val_links
as

begin

  for idx in (SELECT
                id_record,
                id_parent_node,
                id_child_node,
                description,
                ind_is_positive,
                sequence,
                amt_for_true,
                id_process,
                id_proc_rec,
                id_check_stamp,
                (select count(*) from awf_conditions where id_process = nl.id_process and id_proc_rec = nl.id_proc_rec) conditions,
                (select count(*) from awf_node where id_process = nl.id_process and id_proc_rec = nl.id_parent_node) p_node,
                (select count(*) from awf_node where id_process = nl.id_process and id_proc_rec = nl.id_child_node) c_node,
                (select count(*) from awf_node where id_process = nl.id_process and id_proc_rec = nl.id_parent_node and node_type in ('MATRIX','DECISION')) p_node_md
              FROM awf_node_link nl
              where id_process = g_process.id_record) 
  loop

  -- Links cannot allow nodes to self-reference
    if idx.id_parent_node = idx.id_child_node then

      p_cre_val_entry(' ERROR','NODE_LINK',idx.id_proc_rec,null,'SELF_REFERENCE : Links cannot allow Nodes to loop back to themselves');
      g_errors := g_errors + 1;

    end if;

  -- Links from nodes other than Matrix / Decision cannot have conditions
    if idx.p_node_md = 0 and idx.conditions > 0 then

      p_cre_val_entry(' ERROR','NODE_LINK',idx.id_proc_rec,null,'CONDITIONAL : Links from nodes other than DECISION and MATRIX cannot be conditional');
      g_errors := g_errors + 1;

    end if;

  -- Positive Link from Matrix / Decision must have a condition
    if idx.p_node_md = 1 and idx.conditions = 0 and idx.ind_is_positive = 1 then

      p_cre_val_entry(' ERROR','NODE_LINK',idx.id_proc_rec,null,'CONDITIONAL : Positive links from DECISION and MATRIX nodes must have a condition');
      g_errors := g_errors + 1;

    end if;

  -- Negative Links cannot have conditions
    if idx.conditions > 0 and idx.ind_is_positive = 0 then

      p_cre_val_entry(' ERROR','NODE_LINK',idx.id_proc_rec,null,'CONDITIONAL : Negative Links cannot be conditional');
      g_errors := g_errors + 1;

    end if;

  -- Parent Node must be valid
    if idx.p_node = 0 then

      p_cre_val_entry(' WARNING','NODE_LINK',idx.id_proc_rec,null,'DEAD_LINK : Parent Node must be valid');
      g_warn := g_warn + 1;

    end if;

  -- Child Node must be valid
    if idx.p_node = 0 then

      p_cre_val_entry(' ERROR','NODE_LINK',idx.id_proc_rec,null,'ORPHAN : Child Node must be valid');
      g_errors := g_errors + 1;

    end if;


  end loop;

  p_cre_val_entry(' NOTE','LINKS',null,null,'Link Validation Completed');

exception 
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_val_assign
as

begin

  for idx in (SELECT
                id_record,
                description,
                priority,
                ind_notify_by_email,
                node_number,
                id_role,
                id_escrole,
                id_email_template,
                id_process,
                id_proc_rec,
                amt_for_true,
                id_check_stamp,
                (select count(*) 
                 from awf_node 
                 where id_process = na.id_process 
                   and id_proc_rec = na.node_number 
                   and node_type in ('TASK','DECISION')) node,
                (select count(*) 
                 from awf_comm_template 
                 where id_record = na.id_email_template
                   and obj_owner = g_process.obj_owner
                   and object_name = g_process.obj_name) comm_t
              FROM awf_node_assignment na
              where id_process = g_process.id_record)
  loop

  -- node is valid
    if idx.node = 0 then

      p_cre_val_entry(' ERROR','ASSIGNMENT',idx.id_proc_rec,null,'ORPHAN : Referenced Node is Invalid');
      g_errors := g_errors + 1;

    end if;

  -- if notify by email is template exist/valid    
    if idx.ind_notify_by_email = 1 and idx.id_email_template is not null and idx.comm_t = 0 then

      p_cre_val_entry(' ERROR','ASSIGNMENT',idx.id_proc_rec,null,'EMAIL : Selected Email Template not Valid');
      g_errors := g_errors + 1;

    elsif idx.ind_notify_by_email = 1 and idx.id_email_template is null then

      p_cre_val_entry(' ERROR','ASSIGNMENT',idx.id_proc_rec,null,'EMAIL : Email Template Required and not Selected');
      g_errors := g_errors + 1;

    elsif idx.ind_notify_by_email = 0 and idx.id_email_template is not null then

      p_cre_val_entry(' WARNING','ASSIGNMENT',idx.id_proc_rec,null,'EMAIL : Selected Email Template will not be sent');
      g_warn := g_warn + 1;

    end if;

  -- Role is Valid (TODO)

  -- Escalation Role is Valid (TODO)


    null;
  end loop;

  p_cre_val_entry(' NOTE','ASSIGNMENTS',null,null,'Assignment Validation Completed');

exception 
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_val_node_action
as

begin

  for idx in (SELECT
                id_record,
                action_name,
                id_relationship,
                sequence,
                amt_for_true,
                ind_stop_on_error,
                id_process,
                id_proc_rec,
                id_node_number,
                id_check_stamp,
                (select count(*) from awf_node where id_process = na.id_process and id_proc_rec = na.id_node_number and node_type = 'ACTION') node,
                (select count(*) from awf_action where action_name = na.action_name and obj_owner = g_process.obj_owner and obj_name = g_process.obj_name) action
              FROM
                awf_node_action na
              where id_process = g_process.id_record)
  loop

  -- Node is valid
    if idx.node = 0 then

      p_cre_val_entry(' ERROR','NODE_ACTION',idx.id_proc_rec,null,'ORPHAN : Referenced Node is Invalid');
      g_errors := g_errors + 1;

    end if;

  -- Action is Valid
    if idx.action = 0 then

      p_cre_val_entry(' ERROR','NODE_ACTION',idx.id_proc_rec,null,'MIA : Referenced Action is Invalid');
      g_errors := g_errors + 1;

    end if;

  end loop;

  null;

  p_cre_val_entry(' NOTE','NODE_ACTION',null,null,'Node Actions Validation Completed');

exception 
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_val_node_sp
as
  --> TODO : Need to flush out the subprocess code before validation
begin

  -- node is valid

  -- subprocess is valid
    -- sp is enabled / active

  null;

  p_cre_val_entry(' NOTE','SUBPROCESS',null,null,'Sub-Process Validation NOT Completed');

exception 
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_val_conditions
as

begin

  for idx in (SELECT
                id_record,
                condition,
                id_relationship,
                obj_owner,
                object,
                ind_must_be,
                id_process,
                id_proc_rec,
                id_check_stamp,
                (select count(*) from vw_process_records where id_process = c.id_process and id_proc_rec = c.id_proc_rec and obj != 'CONDITIONS') wf_element
              FROM
                awf_conditions c)
  loop

  -- referenced element is valid
    if idx.wf_element = 0 then

      p_cre_val_entry(' WARNING','CONDITION',idx.id_proc_rec,null,'ORPHAN : Referenced WF Element is Invalid');
      g_warn := g_warn + 1;

    end if;

  -- can I check if the condition is valid?
    -- substitution variables?
    -- TODO

  end loop;

  null;

  p_cre_val_entry(' NOTE','CONDITION',null,null,'Condition Validation Completed');

exception 
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_val_actions
as

begin

  for idx in (SELECT
                id_record,
                action_name,
                description,
                obj_owner,
                obj_name,
                code_action_type,
                id_template,
                prog_owner,
                prog_name,
                prog_type,
                func_retvar_name,
                func_retvar_type,
                id_check_stamp,
                ind_save_data,
                (select count(*) from awf_comm_template where id_record = a.id_template) comm_exist,
                (select count(*) from awf_comm_template where id_record = a.id_template and obj_owner = a.obj_owner and object_name = a.obj_name) comm_valid

              FROM awf_action a
              where obj_owner = 'AWF_TEST'
                and obj_name = 'AWF_TEST_MAIN')
  loop

    if idx.code_action_type = 'NOTIFICATION' then

      if idx.comm_exist = 0 then

        p_cre_val_entry(' ERROR','ACTION',idx.id_record,idx.action_name,'COMM : No Communication Template Idenitified');
        g_errors := g_errors + 1;

      elsif idx.comm_valid = 0 then

        p_cre_val_entry(' ERROR','ACTION',idx.id_record,idx.action_name,'COMM : Comm Template is not Valid for this Process');
        g_errors := g_errors + 1;

      end if;

    elsif idx.code_action_type = 'RUN_METHOD' then 
      null;

      -- verify method
      if not(g_prog.exists(idx.prog_name)) then

        p_cre_val_entry(' ERROR','ACTION',idx.id_record,idx.action_name,'METHOD : Program is either invalid or not granted to Workflow Schema');
        g_errors := g_errors + 1;

      else

        -- does a function have a valid variable identified to push the return value to
        if g_prog(idx.prog_name).obj_type = 'FUNCTION' then 

          if idx.func_retvar_name is null then

            p_cre_val_entry(' ERROR','ACTION',idx.id_record,idx.action_name,'METHOD : Functions must have a valid process variable to return into');
            g_errors := g_errors + 1;

          else
            -- TODO: check the variable to see if it is valid (in the set)
            null;

          end if;

        end if;


        -- Warn about proper parameters and values 
        p_cre_val_entry(' WARNING','ACTION',idx.id_record,idx.action_name,'METHOD : Ensure that referenced Methods have the proper parameters and values of the correct datatype before Activation of the process');
        g_warn := g_warn + 1;

      end if;

      -- TODO : Run verification of all parameters against program parameters

    elsif idx.code_action_type = 'SET_VALUE' then 

      -- verify the parameter against the owner object's columns
      for idx2 in (select * 
                   from   awf_action_pv 
                   where  obj_owner = g_process.obj_owner
                     and  obj_name = g_process.obj_name
                     and  action_name = idx.action_name)
      loop

        -- check that variable exists and that data_types match        
        if not(g_proc_vars.exists(idx2.act_parameter)) then

          p_cre_val_entry(' ERROR','ACTION',idx2.id_record,idx2.act_parameter,'VARIABLE : Selected Variable is not a process variable nor an owner column');
          g_errors := g_errors + 1;

        elsif g_proc_vars.exists(idx2.act_parameter)
          and g_proc_vars(idx2.act_parameter).data_type != idx2.act_param_type 
        then

          p_cre_val_entry(' ERROR','ACTION',idx2.id_record,idx2.act_parameter,'VARIABLE : Selected Variable type does not match the identified paramter');
          g_errors := g_errors + 1;

        end if;

      end loop;

    else 
      null;
    end if;

  end loop;

  p_cre_val_entry(' NOTE','ACTIONS',null,null,'Action Validation Completed');

exception 
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_val_comm_templates
as

begin

  p_cre_val_entry(' WARNING','COMM_TEMPLATES',null,null,'WARNING : Email Templates are not being validated in this version of the Relay Engine.'||chr(10)||'Please review the templates for this object and ensure that resources are properly set up');
  g_warn := g_warn + 1;

  p_cre_val_entry(' NOTE','COMM_TEMPLATES',null,null,'E-Mail Template Validation NOT Completed');

exception 
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_val_relationships
as

  l_sql varchar2(4000) := relay_p_vars.g_ei_set('VAL01').text;

  l_code varchar2(4000);
  l_test_var number;

begin
/*
  for idx in (select * 
              from   awf_relationships
              where  p_owner = g_process.obj_owner
                and  p_object = g_process.obj_name
              order by id_record)
  loop

    -- check that the child object is valid / granted
    if not(g_owner_privs.exists(idx.c_owner||'.'||idx.c_object)) then

      p_cre_val_entry(' ERROR','RELATIONSHIP',idx.id_record,idx.rel_name,'ERROR : Child Table is not valid or not granted to Workflow');
      g_errors := g_errors + 1;

    else 

      l_code := l_sql;
      l_code := replace(l_code,'#P_OWNER#',idx.p_owner);
      l_code := replace(l_code,'#P_OBJECT#',idx.p_object);
      l_code := replace(l_code,'#C_OWNER#',idx.c_owner);
      l_code := replace(l_code,'#C_OBJECT#',idx.c_object);
      l_code := replace(l_code,'#WHERE_CLAUSE#',idx.where_clause);

      begin

        execute immediate l_code into l_test_var;

      exception
        when others then

          p_cre_val_entry(' ERROR','RELATIONSHIP',idx.id_record,idx.rel_name,'ERROR : Relationship clause failed testing execution');
          g_errors := g_errors + 1;

      end;

    end if;

  end loop;
*/
  p_cre_val_entry(' NOTE','RELATIONSHIP',null,null,'Relationship Validation Completed');

end ;
--------------------------------------------------------------------------------
procedure p_validate
(p_id_process in number
,p_val_desc out number
,p_val_text out clob)
as
  l_val_text clob;
  l_process awf_process%rowtype;
begin

  if g_val_t.count > 0 then
    g_val_t.delete();
    g_val_idx := 0;
    g_errors := 0;
    g_warn := 0;
    p_cre_val_entry('NOTE','PROCESS',null,null,'Process Validation Started');
  end if;

  if g_proc_vars.count > 0 then
    g_proc_vars.delete;
  end if;

  if g_owner_privs.count > 0 then
    g_owner_privs.delete;
  end if;

  if g_prog.count > 0 then
    g_prog.delete;
  end if;

  -- Process
  p_val_process(p_id_process);
  -- Process Variables
  p_val_proc_vars;
  -- Node 
  p_val_node;
  -- Node Links / Vertex
  p_val_links;
  -- Node Assignment
  p_val_assign;
  -- Node Action
  p_val_node_action;
  -- Node Sub Process
  p_val_node_sp;
  -- Process Conditions
  p_val_conditions;
  -- Object Actions / PV
  p_val_actions;
  -- Comm Templates / Send To
  p_val_comm_templates;
  -- Object Relationships
  -- TODO: p_val_relationships;

  p_cre_val_entry(' NOTE','PROCESS',p_id_process,g_process.description,'Process Validation Complete with '||g_errors||' errors and '||g_warn||' warnings');

  -- create apex collection 
  APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION(p_collection_name => 'PROC_VALIDATION');

  for idx in 1..g_val_t.count loop

    APEX_COLLECTION.ADD_MEMBER 
    (p_collection_name => 'PROC_VALIDATION'
    ,p_c001 => g_val_t(idx).line_code
    ,p_c002 => g_val_t(idx).comp_type
    ,p_c003 => g_val_t(idx).id_proc_rec
    ,p_c004 => g_val_t(idx).node_name
    ,p_c005 => g_val_t(idx).val_text);


    l_val_text := nvl(l_val_text,'Process Validation for '||g_process.process_name||' ('||g_process.id_record||') '||chr(10))|| 
      g_val_t(idx).line_code||' | '||
      g_val_t(idx).comp_type||' | '||
      g_val_t(idx).id_proc_rec||' | '||
      g_val_t(idx).node_name||' | '||
      g_val_t(idx).val_text||
    chr(10);

    null;
  end loop;

  if g_errors > 0 then 
    p_val_desc := 0;
  else 
    p_val_desc := 1;
  end if;

  p_val_text := l_val_text;

  null;
--exception
  --when others then
    --raise;
end ;
--------------------------------------------------------------------------------
function f_enable
(p_id_process in number)
return number
as
  l_val_desc number;
  l_val_text clob;
begin

  p_validate(p_id_process => p_id_process
            ,p_val_desc => l_val_desc
            ,p_val_text => l_val_text);

  if l_val_desc = 1 then

    update awf_process
    set ind_enabled = 1
    where id_record = p_id_process;

  end if;

  return 1;

exception
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
function f_disable
(p_id_process in number)
return number
as

  l_active_inst number;
  l_retvar number;

begin

  select count(*)
  into l_active_inst
  from awf_instance
  where ind_active = 1 
    and id_process = p_id_process;

  if l_active_inst = 0 then

    update awf_process
    set ind_enabled = 0
    where id_record = p_id_process;

    l_retvar := 1;

  else 

    l_retvar := 0;

  end if;

  return l_retvar;

exception
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
function f_activate
(p_id_process in number)
return number
as

  l_retvar number;
  l_activated number;

begin

  select *
  into g_process
  from rly_process_acct
  where id_record = p_id_process;

  if g_process.ind_enabled = 1 then 
    -- check for other processes that have the same name owner and object that are activated
    select count(*)
    into l_activated
    from rly_process_acct
    where obj_owner = g_process.obj_owner
      and obj_name = g_process.obj_name
      and process_name = g_process.process_name
      and ind_active = 1
      and id_record != p_id_process;

    if l_activated > 0 then
    -- if yes then deactivate others
      update awf_process 
      set ind_active = 0 
      where obj_owner = g_process.obj_owner
        and obj_name = g_process.obj_name
        and process_name = g_process.process_name
        and ind_active = 1
        and id_record != p_id_process;
    end if;

    -- then activate this one
    update awf_process 
    set ind_active = 1
    where id_record = p_id_process;

  end if;

  l_retvar := 1;

  return l_retvar;

exception
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
function f_deactivate
(p_id_process in number)
return number
as

  l_retvar number;

begin

  -- deactivate process
  update awf_process 
  set ind_active = 0
  where id_record = p_id_process;

  l_retvar := 1;

  return l_retvar;

exception
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
end ;

/
