--------------------------------------------------------
--  DDL for Function F_GEN_PROC
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "F_GEN_PROC" 
(p_id_process in number ) 
return clob
as 
  l_retvar clob;
  l_js_code_base varchar2(4000) := relay_p_vars.g_ei_set('GEN01').text;

  l_js_code_conn varchar2(4000) := relay_p_vars.g_ei_set('GEN02').text;

  l_js_code_label varchar2(4000) := relay_p_vars.g_ei_set('GEN03').text;

  l_js_code_vertex varchar2(4000) := relay_p_vars.g_ei_set('GEN04').text;

  l_js_code varchar2(4000);
  l_script clob := '';
begin
  -- load up the nodes
  for idx in (select id_process
                    ,id_record
                    ,'N'||id_proc_rec set_var
                    ,1 rec_state
                    ,id_proc_rec node_number
                    ,case node_type
                       when 'START' then 1
                       when 'TASK' then 2
                       when 'SUBPROCESS' then 3
                       when 'ACTION' then 4
                       when 'WAIT' then 5
                       when 'CONDITION' then 6
                       when 'DECISION' then 7
                       when 'MATRIX' then 8
                       when 'STOP' then 9
                       else 0
                     end node_type
                    ,node_name
                    ,layout_column x
                    ,layout_row y
                    ,rowid id_row
                    ,APEX_UTIL.prepare_url
                      (p_url=>'f?p=&APP_ID:10:&SESSION::NO:10:P10_ID_ROW:'||rowid
                      ,p_triggering_element => '$("#openDialogIcon")') t_url
              from    awf_node a
              where id_process = p_id_process
              order by node_number) 
  loop    
    l_js_code := l_js_code_base;
    l_js_code := replace(l_js_code,'#APP_IMAGES#',v('G_APP_IMAGES'));
    l_js_code := replace(l_js_code,'#NODEVAR#',idx.set_var);
    l_js_code := replace(l_js_code,'#NODETYPE#',idx.node_type);
    l_js_code := replace(l_js_code,'#NODEID#',idx.node_number);
    l_js_code := replace(l_js_code,'#NODENAME#',idx.node_name);
    l_js_code := replace(l_js_code,'#IDROW#',idx.id_row);
    l_js_code := replace(l_js_code,'#URL#',idx.t_url);
    l_js_code := replace(l_js_code,'#X_POS#',idx.x);
    l_js_code := replace(l_js_code,'#Y_POS#',idx.y);

    l_script := l_script||' '||l_js_code;

  end loop;
  -- Load up the Connections
  for idx in (SELECT  nl.ID_RECORD,
                      'N'||nl.ID_PARENT_NODE p_node,
                      'N'||nl.ID_CHILD_NODE c_node,
              --        nl.DESCRIPTION,
                      IND_IS_POSITIVE ,
                      case nl.IND_IS_POSITIVE
                        when 0 then 1
                        when 1 then 0
                        else 0 end port_id,
                      nl.SEQUENCE link_label,
              --        AMT_FOR_TRUE,
                      nl.ID_PROCESS,
                      nl.ID_PROC_REC,
                      'L'||nl.ID_PROC_REC link_var,
                      case when pn.node_type in ('MATRIX','DECISION') then 1 else 0 end ind_label
              FROM    AWF_NODE_LINK nl
                     ,AWF_NODE pn
              where   nl.id_process = p_id_process
                and   pn.id_process = nl.id_process
                and   pn.id_proc_rec = nl.id_parent_node
              order by p_node, sequence)
  loop

    l_js_code := l_js_code_conn;
    if idx.ind_label = 1 and idx.ind_is_positive = 1 then 
      l_js_code := replace(l_js_code,'#LINK_LABEL#',l_js_code_label);
    else 
      l_js_code := replace(l_js_code,'#LINK_LABEL#','');
    end if;

    if idx.ind_is_positive = 0 then
      l_js_code := replace(l_js_code,'#LINK_COLOR#','#FF0000');
    else
      l_js_code := replace(l_js_code,'#LINK_COLOR#','#0000FF');
    end if;

    l_js_code := replace(l_js_code,'#LINK_VAR#',idx.link_var);
    l_js_code := replace(l_js_code,'#PN_VAR#',idx.p_node);
    l_js_code := replace(l_js_code,'#CN_VAR#',idx.c_node);
    l_js_code := replace(l_js_code,'#PORT_ID#',idx.port_id);
    l_js_code := replace(l_js_code,'#LABEL#',idx.link_label);
    l_js_code := replace(l_js_code,'#LINK_ID#',idx.id_proc_rec);

    for idx2 in (select  id_process
                        ,'L'||id_proc_rec link_var
                        ,vertex_seq
                        ,nvl2(x_pos,to_char(x_pos),0) x_pos
                        ,nvl2(y_pos,to_char(y_pos),0) y_pos
                 from    awf_node_link_vertex
                 where   1=1
                   and   id_process = idx.id_process
                   and   id_proc_rec = idx.id_proc_rec
                 order by id_process, id_proc_rec, vertex_seq)
    loop

      l_js_code := replace(l_js_code,'#LINK_VERTEX#',l_js_code_vertex||chr(10)||'#LINK_VERTEX#');
      l_js_code := replace(l_js_code,'#LINK_VAR#',idx2.link_var);
      l_js_code := replace(l_js_code,'#VINDEX#',idx2.vertex_seq);
      l_js_code := replace(l_js_code,'#XPOS#',nvl(idx2.x_pos,null));
      l_js_code := replace(l_js_code,'#YPOS#',nvl(idx2.y_pos,null));

    end loop;

    l_js_code := replace(l_js_code,'#LINK_VERTEX#','');

    l_script := l_script||' '||l_js_code;

  end loop;


  l_retvar := l_script; 

  return l_retvar;
/*
exception 
  when others then
    raise;
*/
end f_gen_proc;

/
