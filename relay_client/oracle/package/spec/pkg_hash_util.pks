
  CREATE OR REPLACE EDITIONABLE PACKAGE "RLY_DEV02"."PKG_HASH_UTIL" as

  subtype sha1_checksum_raw is raw(20);
  subtype sha1_checksum_vc2 is varchar2(500);

function f_get_version
return varchar2;

  -- VC2 version
  function sha1_vc(p_buffer in varchar2) 
  return sha1_checksum_vc2;

  -- Raw versions. Max p_buffer length - 16384 bytes
  function sha1(p_buffer in raw) return sha1_checksum_raw;

  -- Blob versions.
  function sha1(p_buffer in blob) return sha1_checksum_raw;

end ;


