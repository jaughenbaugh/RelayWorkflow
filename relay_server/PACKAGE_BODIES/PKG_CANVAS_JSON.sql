--------------------------------------------------------
--  DDL for Package Body PKG_CANVAS_JSON
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_CANVAS_JSON" as
--------------------------------------------------------------------------------
  g_version varchar2(100) := '#VERSION#';
  g_clob_tab apex_application_global.vc_arr2;
--PROGRAMS----------------------------------------------------------------------
function f_get_version
return varchar2
as
begin
  return g_version;
end ;
--------------------------------------------------------------------------------
function f_proc_rec_exists
(p_id_process in number
,p_id_proc_rec in varchar2)
return number
as

  l_retvar number;
begin

  select  count(*)
  into    l_retvar
  from    vw_process_records
  where   id_process = p_id_process
    and   to_char(id_proc_rec) = p_id_proc_rec;

  return l_retvar;
exception
  when others then
    return -1;
end ;
--------------------------------------------------------------------------------
procedure p_clob_to_table
(p_clob in clob)
as
  l_clob clob;
begin

  l_clob := p_clob;

  -- Convert clobtotable
  declare
    c_max_vc2_size pls_integer := 3900; -- Bug with dbms_lob.substr 8191

    l_offset pls_integer := 1;
    l_clob_length pls_integer;
  begin
    l_clob_length := dbms_lob.getlength(l_clob);

    while l_offset <= l_clob_length loop
      g_clob_tab(g_clob_tab.count + 1) :=
        dbms_lob.substr (
         lob_loc => l_clob,
         amount => least(c_max_vc2_size, l_clob_length - l_offset +1 ),
         offset => l_offset);

      l_offset := l_offset + c_max_vc2_size;
    end loop;
  end;

end;
--------------------------------------------------------------------------------
function f_get_ac_clob
return clob
as
  l_retvar clob;
begin

  select clob001
  into l_retvar
  from apex_collections
  where collection_name = 'RLY_JSON'
    and seq_id = 1;

  return l_retvar;
end;
--------------------------------------------------------------------------------
procedure p_process_wf_json
(p_id_process number
,p_proc_json clob)
as

  g_hash varchar2(100) := '#HASH#';

  f_pre_error exception;
  l_json clob;
  j apex_json.t_values;
  l_count number;

  type tt_rec_processed is table of number index by pls_integer;
  l_proc_rec tt_rec_processed;

  type tt_obj_del is table of rowid index by pls_integer;
  l_node_del tt_obj_del;
  l_link_del tt_obj_del;

  type to_ext_node is record (id_d2d varchar2(50)
                             ,id_sequence number
                             ,x_val number
                             ,y_val number
                             ,path_val varchar2(4000)
                             ,id_process number
                             ,id_proc_rec number
                             ,node_type varchar2(50)
                             ,node_name varchar2(50)
                             ,col_val number
                             ,row_val number);
  type tt_ext_node is table of to_ext_node index by pls_integer;
  l_ext_node tt_ext_node;

  type to_ext_link is record (id_d2d varchar2(50)
                             ,id_sequence number
                             ,source_node varchar2(50)
                             ,source_port varchar2(50)
                             ,target_node varchar2(50)
                             ,id_process number
                             ,id_proc_rec number
                             ,id_parent_node number
                             ,id_child_node number
                             ,ind_is_positive number
                             ,vertex_amt number);
  type tt_ext_link is table of to_ext_link index by pls_integer;
  l_ext_link tt_ext_link;

  type to_ext_link_vertex is record(id_d2d varchar2(50)
                                   ,x_val number
                                   ,y_val number
                                   ,id_sequence number
                                   ,id_process number
                                   ,id_proc_rec number);
  type tt_ext_link_vertex is table of to_ext_link_vertex index by pls_integer;
  l_ext_link_vertex tt_ext_link_vertex;

  type tt_ext_node_lookup is table of number index by varchar2(100);
  l_ext_node_lookup tt_ext_node_lookup;

  l_id_process number := p_id_process;
  l_id_proc_rec number;

  l_loop1 number := 0;
  l_loop_1a number := 0;
  l_loop_1b number := 0;
  l_loop_1c number := 0;

begin

  -- load the process record index value for the process
  l_id_proc_rec := relay_p_workflow.f_an_proc(l_id_process)+1;

  -- get json into local variable
  l_json := p_proc_json;

  p_clob_to_table(p_clob => l_json);

  -- parse the json
  apex_json.parse(p_values => j
                 ,p_source => g_clob_tab
                 ,p_strict => true);

  -- get a count of the main objects in the json
  l_count := apex_json.get_count(p_path => '.', p_values => j);

  for idx in 1..l_count loop

    if APEX_JSON.get_varchar2(p_path => '['||idx||'].type',p_default => '-1' ,p_values => j) like '%Image' then
      -- increment loop 1a
      l_loop_1a := l_loop_1a + 1;

      -- get the primary node data
      l_ext_node(l_loop_1a).id_d2d := replace(APEX_JSON.get_varchar2(p_path => '['||idx||'].id',p_default => '-1' ,p_values => j),'-','');
      l_ext_node(l_loop_1a).x_val := replace(APEX_JSON.get_number(p_path => '['||idx||'].x',p_default => '-1' ,p_values => j),'-','');
      l_ext_node(l_loop_1a).y_val := replace(APEX_JSON.get_number(p_path => '['||idx||'].y',p_default => '-1' ,p_values => j),'-','');
      l_ext_node(l_loop_1a).id_sequence := l_loop_1a;
      l_ext_node(l_loop_1a).path_val := replace(APEX_JSON.get_varchar2(p_path => '['||idx||'].path',p_default => '-1' ,p_values => j),'-','');

      l_ext_node(l_loop_1a).node_name := apex_json.get_varchar2(p_path => '['||idx||'].userData.nodename', p_values => j);
      l_ext_node(l_loop_1a).node_type := apex_json.get_varchar2(p_path => '['||idx||'].userData.nodetype', p_values => j);

      -- set the process id
      l_ext_node(idx).id_process := l_id_process;

      -- if the node does not exist then set the id_proc_rec and increment the value
      case f_proc_rec_exists(l_id_process, l_ext_node(l_loop_1a).id_d2d)
        when 0 then 

          l_ext_node(l_loop_1a).id_proc_rec := l_id_proc_rec;
          l_proc_rec(l_id_proc_rec) := l_id_proc_rec;
          l_id_proc_rec := l_id_proc_rec + 1;

        when -1 then 
          raise f_pre_error;
        else 
          l_ext_node(l_loop_1a).id_proc_rec := l_ext_node(l_loop_1a).id_d2d;
          l_proc_rec(l_ext_node(l_loop_1a).id_d2d) := l_ext_node(l_loop_1a).id_d2d;
      end case;

      -- use json x/y to get column and row values
      l_ext_node(l_loop_1a).col_val := ceil(l_ext_node(l_loop_1a).x_val);
      l_ext_node(l_loop_1a).row_val := ceil(l_ext_node(l_loop_1a).y_val);
 
      -- add node to the lookup table for use with links
      l_ext_node_lookup(l_ext_node(l_loop_1a).id_d2d) := l_ext_node(l_loop_1a).id_proc_rec;

    else
      -- increment loop 1b
      l_loop_1b := l_loop_1b + 1;

      -- get the d2d id
      l_ext_link(l_loop_1b).id_d2d := replace(APEX_JSON.get_varchar2(p_path => '['||idx||'].id',p_default => '-1' ,p_values => j),'-','');

      -- logger.log($$plsql_line||' l_ext_link(l_loop_1b).id_d2d: '||l_ext_link(l_loop_1b).id_d2d,-- l_scope);

      -- set id process in the collection
      l_ext_link(l_loop_1b).id_process := l_id_process;   

      -- if the link does not exist then set the id_proc_rec and increment that value
      case f_proc_rec_exists(l_id_process, l_ext_link(l_loop_1b).id_d2d)
        when 0 then  
          l_ext_link(l_loop_1b).id_proc_rec := l_id_proc_rec;
          l_proc_rec(l_id_proc_rec) := l_id_proc_rec;
          l_id_proc_rec := l_id_proc_rec + 1;
        when -1 then 
          raise f_pre_error;
        else 
          l_ext_link(l_loop_1b).id_proc_rec := l_ext_link(l_loop_1b).id_d2d;
          l_proc_rec(l_ext_link(l_loop_1b).id_d2d) := l_ext_link(l_loop_1b).id_d2d;
      end case;

      -- set the link sequence values
      -- TODO: make sure it resets for each node
      l_ext_link(l_loop_1b).id_sequence := l_loop_1b;

      -- get source and target data
      l_ext_link(l_loop_1b).source_node := replace(APEX_JSON.get_varchar2(p_path => '['||idx||'].source.node',p_default => '-1' ,p_values => j),'-','');
      l_ext_link(l_loop_1b).source_port := APEX_JSON.get_varchar2(p_path => '['||idx||'].source.port',p_default => '-1' ,p_values => j);
      l_ext_link(l_loop_1b).target_node := replace(APEX_JSON.get_varchar2(p_path => '['||idx||'].target.node',p_default => '-1' ,p_values => j),'-','');

      -- if the source port is output0 then this is a positive link, else negative
      if l_ext_link(l_loop_1b).source_port like '%0' then 
        l_ext_link(l_loop_1b).ind_is_positive := 1;
      else 
        l_ext_link(l_loop_1b).ind_is_positive := 0;
      end if;

      -- find the parent / child nodes of the link
      l_ext_link(l_loop_1b).id_parent_node := l_ext_node_lookup(l_ext_link(l_loop_1b).source_node);
      l_ext_link(l_loop_1b).id_child_node := l_ext_node_lookup(l_ext_link(l_loop_1b).target_node);

      l_ext_link(l_loop_1b).vertex_amt := apex_json.get_count(p_path => '['||idx||'].vertex', p_values => j);

      -- loop vertex
      for idx2 in 1..l_ext_link(l_loop_1b).vertex_amt loop
        -- increment loop 1c
        l_loop_1c := l_loop_1c + 1;

        -- set values of the vertext in the collection
        l_ext_link_vertex(l_loop_1c).id_process := l_id_process;
        l_ext_link_vertex(l_loop_1c).id_proc_rec := l_ext_link(l_loop_1b).id_proc_rec;
        l_ext_link_vertex(l_loop_1c).id_d2d := l_ext_link(l_loop_1b).id_d2d;
        l_ext_link_vertex(l_loop_1c).id_sequence := idx2;

        -- round the position attributes to the nearest whole number
        l_ext_link_vertex(l_loop_1c).x_val := apex_json.get_number(p_path => '['||idx||'].vertex['||idx2||'].x', p_values => j);
        l_ext_link_vertex(l_loop_1c).y_val := apex_json.get_number(p_path => '['||idx||'].vertex['||idx2||'].y', p_values => j);

      end loop;

    end if;    
  end loop;

  -- merge the node data
  forall idx in 1..l_ext_node.count
  merge into awf_node an
  using (select l_ext_node(idx).id_process id_process
               ,l_ext_node(idx).id_proc_rec id_proc_rec
               ,l_ext_node(idx).node_type node_type
               ,l_ext_node(idx).node_name node_name
               ,l_ext_node(idx).col_val col_val
               ,l_ext_node(idx).row_val row_val
         from dual) d
    on (an.id_process = d.id_process and an.id_proc_rec = d.id_proc_rec)
  when matched then 
    update set node_name = d.node_name
              ,node_type = d.node_type
              ,layout_column = d.col_val
              ,layout_row = d.row_val
  when not matched then
    insert (id_process, id_proc_rec, node_name, node_type, layout_column, layout_row, id_record, id_check_stamp)
    values (d.id_process, d.id_proc_rec, d.node_name, d.node_type, d.col_val, d.row_val, relay_p_workflow.f_an_main, relay_p_workflow.f_an_stamp);

    -- delete links if required
  l_loop1 := 1;
  for idx in (select a.*, a.rowid from awf_node a where id_process = l_id_process) loop
    if l_proc_rec.exists(idx.id_proc_rec) then
      null;
    else 
      l_node_del(l_loop1) := idx.rowid;
      l_loop1 := l_loop1 + 1;
    end if;
  end loop;

  forall idx in 1..l_node_del.count
  delete from awf_node
  where rowid = l_node_del(idx);

  -- merge the link data
  forall idx in 1..l_ext_link.count
  merge into awf_node_link an
  using (select l_ext_link(idx).id_process id_process
               ,l_ext_link(idx).id_proc_rec id_proc_rec
               ,l_ext_link(idx).id_sequence id_sequence
               ,l_ext_link(idx).id_parent_node id_parent_node
               ,l_ext_link(idx).id_child_node id_child_node
               ,l_ext_link(idx).ind_is_positive ind_is_positive
         from dual) d
    on (an.id_process = d.id_process and an.id_proc_rec = d.id_proc_rec)
  when matched then 
    update set id_parent_node = d.id_parent_node
              ,id_child_node = d.id_child_node
              ,ind_is_positive = d.ind_is_positive
              ,sequence = d.id_sequence
  when not matched then
    insert (id_process, id_proc_rec, id_parent_node, id_child_node, ind_is_positive, sequence, id_record, id_check_stamp)
    values (d.id_process, d.id_proc_rec, d.id_parent_node, d.id_child_node, d.ind_is_positive, d.id_sequence, relay_p_workflow.f_an_main, relay_p_workflow.f_an_stamp);

  -- delete links if required
  l_loop1 := 1;
  for idx in (select a.*, a.rowid from awf_node_link a where id_process = l_id_process) loop
    if l_proc_rec.exists(idx.id_proc_rec) then
      null;
    else 
      l_link_del(l_loop1) := idx.rowid;
      l_loop1 := l_loop1 + 1;
    end if;
  end loop;

  forall idx in 1..l_link_del.count
  delete from awf_node_link
  where rowid = l_link_del(idx);

  -- merge the vertex data
  forall idx in 1..l_ext_link_vertex.count
  merge into awf_node_link_vertex an
  using (select l_ext_link_vertex(idx).id_process id_process
               ,l_ext_link_vertex(idx).id_proc_rec id_proc_rec
               ,l_ext_link_vertex(idx).id_sequence id_sequence
               ,l_ext_link_vertex(idx).x_val x_val
               ,l_ext_link_vertex(idx).y_val y_val
         from dual) d
    on (an.id_process = d.id_process 
        and an.id_proc_rec = d.id_proc_rec
        and an.vertex_seq = d.id_sequence)
  when matched then 
    update set x_pos = d.x_val
              ,y_pos = d.y_val
  when not matched then
    insert (id_process, id_proc_rec, vertex_seq, x_pos, y_pos, id_record, id_check_stamp)
    values (d.id_process, d.id_proc_rec, d.id_sequence, d.x_val, d.y_val, relay_p_workflow.f_an_main, relay_p_workflow.f_an_stamp);

  -- delete vertex if required 
  forall idx in 1..l_ext_link.count
  delete from awf_node_link_vertex
  where id_process = l_ext_link(idx).id_process
    and id_proc_rec = l_ext_link(idx).id_proc_rec
    and vertex_seq > l_ext_link(idx).vertex_amt;

exception
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
function f_get_d2d_node
(p_node_type in awf_node.node_type%type
,p_node_id in awf_node.id_proc_rec%type
,p_image_path in varchar2)
return clob as

  l_json  clob;
  l_shape_type varchar2(50) := p_node_type;
  l_shape_id  number := p_node_id;
  l_awf_d2d_shape vw_new_node_d2d%rowtype;
  g_hash varchar2(100) := '#HASH#';

begin

  apex_json.initialize_clob_output;

  select  * 
  into    l_awf_d2d_shape
  from    vw_new_node_d2d
  where   shape_type = l_shape_type;

  l_awf_d2d_shape.id := l_shape_id;

  apex_json.open_object(); -- open node object

    apex_json.write('type',l_awf_d2d_shape.type);
    apex_json.write('id',l_awf_d2d_shape.id);
    apex_json.write('x',l_awf_d2d_shape.x);
    apex_json.write('y',l_awf_d2d_shape.y);
    apex_json.write('width',l_awf_d2d_shape.width);
    apex_json.write('height',l_awf_d2d_shape.height);
    apex_json.write('alpha',l_awf_d2d_shape.alpha);
    apex_json.open_object('userData'); -- open userData object
    -- left blank (for now)
    apex_json.close_object(); -- close userData array
    apex_json.write('cssClass',l_awf_d2d_shape.cssclass);
    apex_json.open_array('ports'); -- open ports array
      for idx2 in (select * 
                   from   vw_new_node_ports_d2d 
                   where  shape_type = l_shape_type) loop
        apex_json.open_object();
          apex_json.write('type',idx2.type);
          apex_json.write('id',idx2.id);
          apex_json.write('width',idx2.alpha);
          apex_json.write('height',idx2.alpha);
          apex_json.write('alpha',idx2.alpha);
          apex_json.write('angle',idx2.angle);
          apex_json.open_object('userData'); -- open userData array
          -- left blank (for now)
          apex_json.close_object(); -- close userData array
          apex_json.write('cssClass',idx2.cssclass);
          apex_json.write('bgColor',idx2.bgcolor);
          apex_json.write('color',idx2.color);
          apex_json.write('stroke',idx2.stroke);
          apex_json.write('dashArray',idx2.dasharray);
          apex_json.write('maxFanOut',idx2.maxfanout);
          apex_json.write('name',idx2.name);
          apex_json.write('port',idx2.port);
          apex_json.write('locator',idx2.locator);
        apex_json.close_object();

      end loop;
    -- TODO: Add ports loop
    apex_json.close_array(); -- close ports array
    apex_json.write('path', p_image_path || '/' || lower(l_awf_d2d_shape.shape_type) || '.png');
    apex_json.open_array('labels'); -- open labels array
      apex_json.open_object(); -- open label object
        apex_json.write('id',l_awf_d2d_shape.id||'-'||0);
        apex_json.write('label',l_awf_d2d_shape.shape_type||l_awf_d2d_shape.id);
        apex_json.write('locator','draw2d.layout.locator.BottomLocator');
      apex_json.close_object(); -- close label object
    apex_json.close_array(); -- close labels array

  apex_json.close_object(); -- close node object

  l_json := apex_json.get_clob_output;
  l_json := replace(l_json,chr(10),'');

  apex_json.free_output;

  return l_json;
exception 
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
function f_get_d2d_process
(p_id_process in awf_process.id_record%type
,p_image_path in varchar2)
return clob
as
  l_json  clob;
  l_id_process number := p_id_process;

begin

  apex_json.initialize_clob_output;

  apex_json.open_array(); -- open main array

  -- loop to generate the nodes and ports  
  for idx1 in (select * from vw_node_d2d where id_process = l_id_process) loop

    apex_json.open_object(); -- open node object

      apex_json.write('type',idx1.type);
      apex_json.write('id',idx1.id);
      apex_json.write('x',idx1.x);
      apex_json.write('y',idx1.y);
      apex_json.write('width',idx1.width);
      apex_json.write('height',idx1.height);
      apex_json.write('alpha',1); -- static value
      apex_json.write('angle',0); -- static value
      apex_json.open_object('userData'); -- open userData object
        apex_json.write('idprocrec',idx1.id);
        apex_json.write('nodetype',idx1.node_type);
        apex_json.write('nodename',idx1.node_name);
        apex_json.write('description',nvl(idx1.description,''));
      apex_json.close_object(); -- close userData array
      apex_json.write('cssClass',idx1.cssclass);
      apex_json.open_array('ports'); -- open ports array
        for idx2 in (select * 
                     from   vw_node_port_d2d 
                     where  id_process = l_id_process
                      and   node_id = idx1.id) loop
          apex_json.open_object();
            apex_json.write('type',idx2.type);
            apex_json.write('id',idx2.id);
            apex_json.write('width',idx2.width);
            apex_json.write('height',idx2.height);
            apex_json.write('alpha',1); -- static value
            apex_json.write('angle',0); -- static value
            apex_json.open_object('userData'); -- open userData array
            -- left blank (for now)
            apex_json.close_object(); -- close userData array
            apex_json.write('cssClass',idx2.cssclass);
            apex_json.write('bgColor',idx2.bgcolor);
            apex_json.write('color',idx2.color);
            apex_json.write('stroke',idx2.stroke);
            apex_json.write('dashArray',idx2.dasharray);
            apex_json.write('maxFanOut',idx2.maxfanout);
            apex_json.write('name',idx2.name);
            apex_json.write('port',idx2.port);
            apex_json.write('locator',idx2.locator);
          apex_json.close_object();

        end loop;
      -- TODO: Add ports loop
      apex_json.close_array(); -- close ports array
      apex_json.write('path',p_image_path || '/' || lower(idx1.shape_type) || '.png');
      apex_json.write('resizeable',false);
      apex_json.open_array('labels'); -- open labels array
        apex_json.open_object(); -- open label object
          apex_json.write('type','draw2d.shape.basic.Label');
          apex_json.write('id',idx1.id||'-'||0);
          apex_json.write('text',idx1.label);
          apex_json.write('fontSize',12);
          apex_json.write('locator','draw2d.layout.locator.BottomLocator');
        apex_json.close_object(); -- close label object
      apex_json.close_array(); -- close labels array

    apex_json.close_object(); -- close node object

  end loop;
  -- loop to generate the connections between nodes
  for idx3 in (select * from vw_node_link_d2d where id_process = l_id_process) loop

    apex_json.open_object(); -- open connection object
      apex_json.write('type',idx3.type);
      apex_json.write('id',idx3.id);
      apex_json.write('alpha',1); -- static value
      apex_json.write('angle',0); -- static value
      apex_json.open_object('userData'); -- open userData array
      -- left blank (for now)
        apex_json.write('type','node');
        apex_json.write('id',idx3.id);
      apex_json.close_object(); -- close userData array
      apex_json.write('cssClass',idx3.cssclass);
      apex_json.write('stroke',idx3.stroke);
      apex_json.write('color',idx3.color);
      apex_json.write('outlineStroke',idx3.outlineStroke);
      apex_json.write('outlineColor',idx3.outlineColor);
      apex_json.write('policy',idx3.policy);
      apex_json.open_array('vertex'); -- open vertex array
        for idx4 in (select * 
                     from   awf_node_link_vertex 
                     where  id_process = l_id_process
                      and   id_proc_rec = idx3.id
                     order by vertex_seq) loop
          apex_json.open_object();
            apex_json.write('x',idx4.x_pos);
            apex_json.write('y',idx4.y_pos);
          apex_json.close_object();    
        end loop;
      apex_json.close_array(); -- close vertex array
      apex_json.write('router','draw2d.layout.connection.InteractiveManhattanConnectionRouter'); -- static value
      apex_json.write('radius',idx3.radius);
      apex_json.open_object('routingMetaData');
        apex_json.write('routedByUserInteraction',false); -- static value
        apex_json.write('fromDir',1); -- static value
        apex_json.write('toDir',3); -- static value
      apex_json.close_object();
      apex_json.open_object('source'); -- open source object
        apex_json.write('node',idx3.source_id);
        apex_json.write('port',idx3.source_name);
      apex_json.close_object(); -- close source object
      apex_json.open_object('target'); -- open target object
        apex_json.write('node',idx3.target_id);
        apex_json.write('port',idx3.target_name);
      apex_json.close_object(); -- close target object

    apex_json.close_object(); -- close connection object

  end loop;

  apex_json.close_array(); -- close main array

  l_json := apex_json.get_clob_output;
  l_json := replace(l_json,chr(10),'');

  apex_json.free_output;

  return l_json;
exception 
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
end ;

/
