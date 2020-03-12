--------------------------------------------------------
--  DDL for View TK_FQUEUE
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "TK_FQUEUE" ("ID_RECORD", "ID_REQUEST", "INTERNAL_ID", "FLOW_NAME", "OBJ_NAME", "NODE_TYPE", "INPUT_A", "INPUT_C", "CHANGE_ID", "ID_PROCESS", "TIMELIMIT", "IND_CONDITION") AS 
  SELECT
  i.id_record,
  relay_p_vars.f_conv_hex(i.id_record||s.id_record||s.id_process
    ||relay_p_vars.f_conv_to_ue(i.date_start)) id_request,
  id_owner internal_id,
  p.process_name flow_name,
  p.obj_name obj_name,
  case 
    when i.ind_active = 0 then 'CLOSED'
    else nvl(n.node_type,'OPEN')
  end node_type,
  '          ' input_a, -- no length in view
  '          ' input_c,
  relay_p_vars.f_conv_hex(s.id_check_stamp||i.id_check_stamp
    ||relay_p_vars.f_conv_to_ue(nvl(s.date_set,i.date_start))) change_id,
  p.id_record id_process,
--  to_char(s.date_set + f_conv_to_days(n.interval_uom,n.interval),'YYYY.MM.DD.SSSSS') timelimit,
  to_char(relay_p_anydata.f_date_to_epoch(s.date_set + f_conv_to_days(n.interval_uom,n.interval))) timelimit,
  case when (select count(*) from awf_conditions where id_process = n.id_process and id_proc_rec = n.id_proc_rec) > 0 then 1 else 0 end ind_condition
FROM
  awf_instance i
 ,awf_instance_state s
 ,awf_process p
 ,awf_node n
where s.id_instance = i.id_record
  and p.id_record = i.id_process
  and n.id_process (+)= p.id_record
  and n.id_proc_rec (+)= s.node_number
;
