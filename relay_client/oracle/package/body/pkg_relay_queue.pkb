
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "RLY_DEV02"."PKG_RELAY_QUEUE" 
as
--------------------------------------------------------------------------------
procedure p_update_owner
(p_queue_id in number)
as
  l_obj tk_object%rowtype;

  l_attr tk_obj_attr%rowtype;

  l_que tk_test_queue%rowtype;

  type t_qdata is table of tk_tque_data%rowtype index by pls_integer;
  l_qdata t_qdata;

  l_code_base clob := q'|
update [OBJECT]
set [SET_COLS]
where to_char([KEY_COL]) = '[KEY_VALUE]'
  |';

  l_code clob;

  l_id_queue number;
  l_set_cols clob;
  l_amt number;

begin

  -- get queue/obj data into a collection
  select * 
  into l_que
  from tk_test_queue
  where id_record = p_queue_id;

  select * 
  bulk collect into l_qdata
  from tk_tque_data
  where id_queue = p_queue_id
    and ind_rev = 1;

  select *
  into l_obj
  from tk_object
  where obj_name = l_que.obj_name;

  select * 
  into l_attr
  from tk_obj_attr
  where id_object = l_obj.id_record
    and ind_key = 1
    and rownum = 1;  

  if l_qdata.count > 0 then

    select id_queue
          ,listagg(
             attr_name||' = '||
             case when ad_value is null 
             then 'null' else
                  'anydata.access'||attr_type||'(pkg_relay_queue.f_clob_to_anydata(to_clob('''||ad_value||'''),'''||attr_type||'''))'
             end
          ,','||chr(10)) within group (order by seq_id) 
          upd_cols,
          count(*) amt
    into l_id_queue, l_set_cols, l_amt
    from (
      select q.id_record id_queue
            ,o.attr_name
            ,o.attr_type
            ,o.ind_upd
            ,d.ad_value
            ,o.seq_id
      from (select o.obj_name, a.* 
            from tk_object o, tk_obj_attr a
            where a.id_object = o.id_record) o,
           tk_tque_data d,
           tk_test_queue q
      where d.id_queue = q.id_record
        and o.obj_name = q.obj_name
        and o.seq_id = d.col_id

        and o.ind_upd = 1 -- updates allowed by object cfg
        and d.ind_rev = 1 -- value changed by workflow
        and nvl(d.ad_value,'-abc123') != nvl(d.ad_value_orig,'-abc123') -- value is different

        and q.id_record = l_que.id_record
      order by q.id_record, o.seq_id
      ) a
    group by id_queue;

    l_code := l_code_base;
    l_code := replace(l_code,'[SET_COLS]',l_set_cols);
    l_code := replace(l_code,'[OBJECT]',l_obj.source_id);
    l_code := replace(l_code,'[KEY_COL]',l_attr.attr_name);
    l_code := replace(l_code,'[KEY_VALUE]',l_que.internal_id);

    dbms_output.put_line(l_code);

    execute immediate l_code;

  end if;
end;
--------------------------------------------------------------------------------
procedure p_update_queue
(p_queue_id in number)
as

  l_assign number;
  l_res_req number;
  l_choices number;
  l_alerts number;
  l_err_log number;

begin

  l_res_req := pkg_relay_api.g_res_req;
  l_assign := pkg_relay_api.g_assignments;
  l_choices := pkg_relay_api.g_choices;
  l_alerts := pkg_relay_api.g_alert_log;
  l_err_log := pkg_relay_api.g_err_log;

  UPDATE tk_test_queue
  SET id_request = pkg_relay_api.g_a
     ,node_type = pkg_relay_api.g_h
     ,change_id = pkg_relay_api.g_i
     ,timelimit = pkg_relay_api.g_j
     ,ind_condition = pkg_relay_api.g_k
     ,assign = l_assign
     ,res_req = l_res_req
     ,choices = l_choices
     ,alerts = l_alerts
     ,err_log = l_err_log
  WHERE
    id_record = p_queue_id;

  if pkg_relay_api.g_owner_data.count > 0 then
    forall idx in 1..pkg_relay_api.g_owner_data.count
    update tk_tque_data
    set ind_rev = 1
       ,ad_value = pkg_relay_api.g_owner_data(idx).b
    where id_queue = p_queue_id
      and col_id = pkg_relay_api.g_owner_data(idx).a;
  end if;

  null;
end;
--------------------------------------------------------------------------------
procedure p_run_queue
(p_queue_id in number
,p_auth_id in varchar2)
as

  type t_obj_attr is table of tk_obj_attr%rowtype index by pls_integer;
  l_obj_attr t_obj_attr;

begin
  dbms_output.put_line('p_queue_id: '||p_queue_id);
  select
    id_request,
    internal_id,
    flow_name,
    obj_name,
    node_type,
    input_a,
    input_c,
    change_id
  into 
    pkg_relay_api.g_a
   ,pkg_relay_api.g_b
   ,pkg_relay_api.g_d
   ,pkg_relay_api.g_e
   ,pkg_relay_api.g_h
   ,pkg_relay_api.g_f
   ,pkg_relay_api.g_g
   ,pkg_relay_api.g_i
  from
    tk_test_queue
  where id_record = p_queue_id;

  pkg_relay_api.g_c := p_auth_id;

  select a.* 
  bulk collect into l_obj_attr
  from tk_obj_attr a
      ,tk_object o
  where o.id_record = a.id_object
    and o.obj_name = pkg_relay_api.g_e
  order by seq_id;

  if pkg_relay_api.g_owner_data.count > 0 then
    pkg_relay_api.g_owner_data.delete;
  end if;

  select col_id, ad_value
  bulk collect into pkg_relay_api.g_owner_data
  from tk_vw_test_queue 
  where id_queue = p_queue_id
  order by col_id;

  null;
exception 
  when others then
    raise;
end;
--------------------------------------------------------------------------------
function f_date_to_epoch
(p_input in date)
return number
as
  l_retvar number;
begin

  l_retvar := round((sysdate - to_date('19700101000000','YYYYMMDDHH24MISS'))*24*60*60);

  return l_retvar;
end;
--------------------------------------------------------------------------------
function f_epoch_to_date
(p_input in number)
return date
as
  l_retvar date;
begin

  l_retvar := to_date('19700101000000','YYYYMMDDHH24MISS') + (p_input/60/60/24);

  return l_retvar;
end;
--------------------------------------------------------------------------------
function f_anydata_to_clob
(p_input sys.anydata)
return clob
as
--  l_scope logger_logs.scope%type := pkg_logger_assist.f_get_scope;
  --l_params logger.tab_param;

  l_retvar clob;
  l_var_type varchar2(100);
begin
--  logger.log($$plsql_line||' START', l_scope, null, l_params);
  if p_input is not null then

    -- get the variable source type
    l_var_type := ltrim(p_input.gettypename,'SYS.');

    case l_var_type
      when 'BINARY_DOUBLE' then l_retvar := to_clob(anydata.AccessBDouble(p_input));
  --    when 'BFILE' then l_retvar := to_clob(anydata.AccessBfile(p_input));
      when 'BINARY_FLOAT' then l_retvar := to_clob(anydata.AccessBFloat(p_input));
  --    when 'BLOB' then l_retvar := to_clob(anydata.AccessBlob(p_input));
      when 'CHAR' then l_retvar := to_clob(anydata.AccessChar(p_input));
      when 'CLOB' then l_retvar := to_clob(anydata.AccessClob(p_input));
--      when 'DATE' then l_retvar := to_clob(to_char(anydata.AccessDate(p_input),'YYYY.MM.DD.SSSSS'));
      when 'DATE' then l_retvar := to_clob(to_char(f_date_to_epoch(anydata.AccessDate(p_input))));
      when 'INTERVAL DAY TO SECOND' then l_retvar := to_clob(anydata.AccessIntervalDS(p_input));
      when 'INTERVAL YEAR TO MONTH' then l_retvar := to_clob(anydata.AccessIntervalYM(p_input));
      when 'NCHAR' then l_retvar := to_clob(anydata.AccessNchar(p_input));
      when 'NCLOB' then l_retvar := to_clob(anydata.AccessNClob(p_input));
      when 'NUMBER' then l_retvar := to_clob(anydata.AccessNumber(p_input));
      when 'NVARCHAR2' then l_retvar := to_clob(anydata.AccessNVarchar2(p_input));
      when 'RAW' then l_retvar := to_clob(anydata.AccessRaw(p_input));
      when 'TIMESTAMP' then l_retvar := to_clob(anydata.AccessTimestamp(p_input));
      when 'TIMESTAMP WITH TIMEZONE' then l_retvar := to_clob(anydata.AccessTimestampTZ(p_input));
      when 'TIMESTAMP WITH LOCAL TIMEZONE' then l_retvar := to_clob(anydata.AccessTimestampLTZ(p_input));
      when 'UROWID' then l_retvar := to_clob(anydata.AccessURowid(p_input));
      when 'VARCHAR' then l_retvar := to_clob(anydata.AccessVarchar(p_input));
      when 'VARCHAR2' then l_retvar := to_clob(anydata.AccessVarchar2(p_input));
      else null; --logger.log($$plsql_line||' Invalid Variable Type', l_scope);
    end case;

    --logger.log($$plsql_line||' END Return:'||l_retvar, l_scope);
  end if; 

  return l_retvar;
exception
  when others then
    --logger.log_error('Unhandled Exception', l_scope, null, l_params);
    raise;
end ;
--------------------------------------------------------------------------------
function f_clob_to_anydata
(p_input in clob
,p_data_type in varchar2)
return anydata
as

  l_input clob := p_input;
  l_retvar anydata;
  l_stmt varchar2(4000);

begin

  if l_input like '%~%' then
    l_input := replace(l_input,'~',chr(10));
  end if;

  if p_data_type = 'DATE' then 
--    l_stmt := 'select sys.anydata.convert'||p_data_type||'(to_date(:a,''YYYY.MM.DD.SSSSS'')) val1 from dual';  
-->    l_retvar := sys.anydata.convertdate(to_date(p_input,'YYYY.MM.DD.SSSSS'));
    l_retvar := sys.anydata.convertdate(f_epoch_to_date(to_number(p_input)));
  elsif p_data_type = 'NUMBER' then 
--    l_stmt := 'select sys.anydata.convert'||p_data_type||'(to_number(:a)) val1 from dual';
    l_retvar := sys.anydata.convertnumber(to_number(p_input));
  elsif p_data_type = 'VARCHAR2' then 
--    l_stmt := 'select sys.anydata.convert'||p_data_type||'(to_number(:a)) val1 from dual';
    l_retvar := sys.anydata.convertnumber(dbms_lob.substr(p_input,3999,1));
  else
    l_stmt := 'select sys.anydata.convert'||p_data_type||'(:a) val1 from dual';  
--  end if;

  --  dbms_output.put_line(l_stmt);
    begin 
      execute immediate (l_stmt) into l_retvar using p_input;
    exception
      when others then
        l_retvar := null;
    end;
  --  dbms_output.put_line(to_char(sys.anydata.accessDate(l_retvar),'YYYYMMDDHH24MISS'));

  end if;

  return l_retvar;
exception
  when others then
    --logger.log_error('Unhandled Exception', l_scope, null, l_params);
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_init_ad_array as
begin
   g_ad_array := tk_ad_array(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
                            ,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
                            ,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
                            ,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
                            ,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
                            );
    g_ad_set := t_ad_set();
end p_init_ad_array;
--------------------------------------------------------------------------------
procedure p_load_qdata
(p_obj_name in varchar2
,p_key_value in varchar2
,p_id_queue in number)
as

  type t_rly_cfg is table of tk_obj_attr%rowtype index by pls_integer;
  l_rly_cfg t_rly_cfg;

  l_rly_obj tk_object%rowtype;

  l_code_base clob := q'|
begin
pkg_relay_queue.p_init_ad_array;
select 
 [SEL_COLS]
into 
 [INTO_COLS]
from [OBJECT]
where to_char([KEY_COL]) = '[KEY_VALUE]';

[AD_REC]

end;
|';

  l_code clob;

  l_sel_cols clob := '';
  l_into_cols clob;
  l_ad_rec clob;
  l_key_col varchar2(100);

begin
  if g_ad_set.count > 0 then
    g_ad_set.delete;
  end if;

  -- load object
  select o.* 
  into l_rly_obj 
  from tk_object o
  where obj_name = p_obj_name;

  -- load workflow obj definition
  select a.* 
  bulk collect into l_rly_cfg
  from tk_obj_attr a
      ,tk_object o
  where o.id_record = a.id_object
    and obj_name = p_obj_name;

  for idx in 1..l_rly_cfg.count loop

    if l_rly_cfg(idx).ind_key = 1 then
      l_key_col := l_rly_cfg(idx).attr_name;
    end if;

    l_sel_cols := case when l_sel_cols is not null then l_sel_cols||chr(10)||',' else '' end
                  ||'anydata.convert'||l_rly_cfg(idx).attr_type
                  ||'('||l_rly_cfg(idx).attr_name
                  ||') '||l_rly_cfg(idx).attr_name;

    l_into_cols := case when l_into_cols is not null then l_into_cols||chr(10)||',' else '' end
                   ||'pkg_relay_queue.g_ad_array.ad_'||lpad(to_char(idx),4,'0');

    l_ad_rec := case when l_ad_rec is not null then l_ad_rec||chr(10) else '' end
                   ||'pkg_relay_queue.g_ad_set('||idx||').a := '||l_rly_cfg(idx).seq_id||';';

    l_ad_rec := case when l_ad_rec is not null then l_ad_rec||chr(10) else '' end
                   ||'pkg_relay_queue.g_ad_set('||idx||').b := pkg_relay_queue.g_ad_array.ad_'||lpad(to_char(idx),4,'0')||';';

    l_ad_rec := case when l_ad_rec is not null then l_ad_rec||chr(10) else '' end
                   ||'pkg_relay_queue.g_ad_set('||idx||').c := '||tk_iface_main.nextval()||';';

  end loop;

  l_code := l_code_base;
  l_code := replace(l_code,'[OBJECT]',l_rly_obj.source_id);
  l_code := replace(l_code,'[KEY_VALUE]',p_key_value);
  l_code := replace(l_code,'[KEY_COL]',l_key_col);
  l_code := replace(l_code,'[SEL_COLS]',l_sel_cols);
  l_code := replace(l_code,'[INTO_COLS]',l_into_cols);
  l_code := replace(l_code,'[AD_REC]',l_ad_rec);

  execute immediate(l_code);

  forall idx in 1..l_rly_cfg.count
  insert into tk_tque_data
  (ID_RECORD
  ,ID_QUEUE
  ,COL_ID
  ,IND_REV
  ,AD_VALUE
  ,AD_VALUE_ORIG)
  VALUES
  (g_ad_set(idx).c
  ,p_id_queue
  ,g_ad_set(idx).a
  ,0
  ,f_anydata_to_clob(pkg_relay_queue.g_ad_set(idx).b)
  ,f_anydata_to_clob(pkg_relay_queue.g_ad_set(idx).b));

end;
--------------------------------------------------------------------------------
function f_load_queue
(p_internal_id in varchar2
,p_flow_name in varchar2
,p_obj_name in varchar2)
return number
as
  l_id_queue number;
  l_retvar number;
begin

  l_id_queue := tk_iface_main.nextval();

  insert into tk_test_queue
  (id_record, internal_id, flow_name, obj_name)
  values
  (l_id_queue, p_internal_id, p_flow_name, p_obj_name);

  p_load_qdata(p_obj_name, p_internal_id, l_id_queue);

  l_retvar := l_id_queue;

  return l_retvar;
end;
--------------------------------------------------------------------------------
procedure p_load_queue
(p_internal_id in varchar2
,p_flow_name in varchar2
,p_obj_name in varchar2)
as
  l_var varchar2(50);
begin

  l_var := f_load_queue(p_internal_id,p_flow_name,p_obj_name);

end;
--------------------------------------------------------------------------------
end;
