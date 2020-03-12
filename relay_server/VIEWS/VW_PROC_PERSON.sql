--------------------------------------------------------
--  DDL for View VW_PROC_PERSON
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROC_PERSON" ("ID_PROCESS", "ROLE_TYPE", "ID_ROLE", "ID_PERSON", "IND_BROADCAST", "MEMBER_SEQUENCE", "IND_GROUP_DEFAULT", "ID_DELEGATE_OF", "PERSON_CODE", "EMAIL_ADDRESS") AS 
  select 
     r.id_process
    ,p."ROLE_TYPE",p."ID_ROLE",p."ID_PERSON",p."IND_BROADCAST",p."MEMBER_SEQUENCE",p."IND_GROUP_DEFAULT",p."ID_DELEGATE_OF",p."PERSON_CODE",p.email_address
from vw_process_roles r
    ,(select
        'ROLE-PERSON' role_type,
        b.id_record id_role,
        a.id_record id_person,
        b.ind_broadcast,
        1 member_sequence,
        1 ind_group_default,
        0 id_delegate_of,
        a.person_code,
        a.email_address
      from
        awf_person a,
        awf_roles b
      where
        b.role_type = 'PERSON'
        and 
      --    /*
          case 
          when b.ind_rel_data = 1 then 
            relay_p_vars.f_get_rel_role(b.value)
          else b.value end = to_char(a.id_record)
      --    */
      --    b.value = to_char(a.id_record)
      union all
      select
        'ROLE-GROUP' role_type,
        b.id_record id_role,
        a.id_record id_person,
        b.ind_broadcast,
        d.member_sequence,
        d.ind_group_default,
        d.id_delegate_of,
        a.person_code,
        a.email_address
      from
        awf_person a,
        awf_roles b,
        awf_person_group c,
        awf_group_members d
      where
        b.role_type = 'GROUP'
        and 
      --    /*
          case 
          when b.ind_rel_data = 1 then 
            relay_p_vars.f_get_rel_role(b.value)
          else b.value end  = to_char(c.id_record)
      --    */
      --    b.value = to_char(c.id_record)
        and d.id_person_group = c.id_record
        and a.id_record = d.id_group_member) p
where p.id_role = r.id_role
union all
select 
     t.id_process,
    p."ROLE_TYPE",p."ID_ROLE",p."ID_PERSON",p."IND_BROADCAST",p."MEMBER_SEQUENCE",p."IND_GROUP_DEFAULT",p."ID_DELEGATE_OF",p."PERSON_CODE",p.email_address
from vw_proc_comm t,
  (
   select
    'PERSON' role_type,
    a.id_record id_role,
    a.id_record id_person,
    null ind_broadcast,
    1 member_sequence,
    1 ind_group_default,
    0 id_delegate_of,
    a.person_code,
    a.email_address,
    b.id_template
  from
    awf_person a,
    awf_comm_send_to b
  where 1=1
    and b.send_to_type = 'PERSON'
    and a.id_record = b.send_to

  union all

  select
    'GROUP' role_type,
    c.id_record id_role,
    a.id_record id_person,
    null ind_broadcast,
    d.member_sequence,
    d.ind_group_default,
    d.id_delegate_of,
    a.person_code,
    a.email_address,
    b.id_template
  from
    awf_person a,
    awf_comm_send_to b,
    awf_person_group c,
    awf_group_members d
  where 1=1
    and b.send_to_type = 'GROUP'
    and c.id_record = b.send_to
    and d.id_person_group = c.id_record
    and a.id_record = d.id_group_member

) p
where p.id_template = t.id_record
;
