SET DEFINE OFF;
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (20,'RWF01','declare
  l_program varchar2(200) := ''f_write_owner_updates.ei_block'';
  l_active_pv relay_p_workflow.t_active_pv;
  l_record {OBJECT}%rowtype;
begin
{REC_SET}
update {OBJECT}
set {SET_LIST}
where rowid = chartorowid(''{ROWID}'');
exception
  when others then
    raise;
end;');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (21,'RWF02','begin
select {SELECT_VAR}
,rowid
into {INTO_VAR}
,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).owner_rowid
from {FROM_VAR}
where {WFID_VAR} = {ID_OWNER};
end;');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (23,'RWF04','select * from awf_relationships where p_owner = ''#OBJ_OWNER#'' and p_object = ''#OBJ_NAME#'' order by rel_name');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (24,'RWF05','select  ''{REL_NAME}'' rel_name
        ,''{CHAIN_VAR}'' chain_var
        ,listagg(''''''''||c.rowid||'''''''', '','') within group (order by c.rowid) rowid_list
        ,count(c.rowid) amt_rowids
from    {P_TABLE} p
       ,{C_TABLE} c
where   p.rowid in ({P_ROWID_LIST})
  and   {REL_CLAUSE}');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (27,'RWF08','select f_get_ad_method
(p_dtype => f_get_datatype
           (p_dump_input => dump({EXPR}))
,p_method => ''CONVERT'') expr from dual');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (28,'RWF09','select anydata.{FUNCTION}({EXPR}) expr from dual');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (34,'RWF15','declare
  l_program varchar2(200) := ''f_run_method.ei_block'';
  l_log_id number := f_get_log_id;
  l_active_pv t_active_pv;

  -- Begin DLV
{DEF_L_VARS}
  -- End DLV

--{FUNC}l_retvar {RETVAR_DT};
begin
  -- logger.log(''START'', l_scope);
  p_build_log(l_program, $$plsql_line, l_log_id, ''DEBUG'', ''START'');
l_active_pv := g_active_pv;

  -- Begin LLV
{LOAD_L_VARS}
  -- End LLV

--{FUNC}l_retvar :=
{OWNER}.{PROGRAM}
({PV_SET});

  -- Begin TIS
{TO_IV_STMTS}
  -- End TIS

--todo : ADD CASE for LOB not LOB use /**/ to tie it off
--{FUNC}relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(''{RV_INST_VAR}'').var_value := sys.anydata.{DT_VAR}(l_retvar);
null;

  p_build_log(l_program, $$plsql_line, l_log_id, ''DEBUG'', ''END'');
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, ''DEBUG'', ''ERROR'');
    raise;
end;');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (1,'PAD01','select relay_p_workflow.f_get_ad_method
       (p_dtype => relay_p_workflow.f_get_datatype
                   (p_dump_input => dump({EXPR}))
       ,p_method => ''CONVERT'') expr from dual');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (2,'PAD02','select anydata.{FUNCTION}({EXPR}) expr from dual');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (10,'VAL01','select count(*) test1
from  (select * from #P_OWNER#.#P_OBJECT# where rownum = 1) p 
      ,#C_OWNER#.#C_OBJECT# c
where #WHERE_CLAUSE#');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (11,'GEN01','var #NODEVAR#_URL = $v("P302_URL");
#NODEVAR#_URL = #NODEVAR#_URL.replace("P10_VALUES","#IDROW#");
#NODEVAR#_URL = #NODEVAR#_URL.replace("P10_ITEMS","P10_ID_ROW");
var #NODEVAR# = new rly.workflow.node(''#APP_IMAGES#'',1,#NODETYPE#,#NODEID#,''#NODENAME#'',''#IDROW#'',#NODEVAR#_URL); 
canvas.add(#NODEVAR#,#X_POS#,#Y_POS#);');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (12,'GEN02','var #LINK_VAR# = new rly.workflow.conn({
    source:#PN_VAR#.getOutputPort(#PORT_ID#),
    target:#CN_VAR#.getInputPort(0),
    id:#LINK_ID#,
    color:"#LINK_COLOR#"
});
#LINK_LABEL#
#LINK_VERTEX#
canvas.add(#LINK_VAR#);');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (13,'GEN03','#LINK_VAR#.label = new draw2d.shape.basic.Label({text:"#LABEL#",color:"#0d0d0d",fontColor:"#0d0d0d",bgColor:"f0f0f0"});
#LINK_VAR#.add(#LINK_VAR#.label, new draw2d.layout.locator.ManhattanMidpointLocator());');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (14,'GEN04','#LINK_VAR#.addVertex("#VINDEX#","#XPOS#","#YPOS#");');
Insert into AWF_EI_TEXT (ID_RECORD,CODE_TEXT,TEXT) values (15,'GEN05','#NODEVAR# = new rly.workflow.node(''#APP_IMAGES#'',1,#NODETYPE#,#NODEID#,''#NODENAME#'',''#IDROW#'',''#URL#''); canvas.add(#NODEVAR#,#X_POS#,#Y_POS#);');
