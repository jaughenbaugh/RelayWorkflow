--------------------------------------------------------
--  DDL for Package Body PKG_HASH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_HASH_UTIL" 
as

  type ta_number is table of number index by binary_integer;

  type tr_ctx is record (
    h ta_number,
    total_length number,
    leftover_buffer raw(256),
    leftover_buffer_length number,
    words_array ta_number
  );

  m_ctx tr_ctx;
  m_k ta_number;
  m_result ta_number;

  -- Constants for message padding
  c_bits_00 raw(1) := hextoraw('00');
  c_bits_80 raw(1) := hextoraw('80');

  -- Constant for 32bit bitwise operations
  c_bits_80000000 number := to_number('80000000','xxxxxxxx');
  c_bits_ffffffc0 number := to_number('FFFFFFC0','xxxxxxxx');
  c_bits_ffffffff number := to_number('FFFFFFFF','xxxxxxxx');

  -- Constant for 64bit bitwise operations
  c_bits_8000000000000000 number := to_number('8000000000000000','xxxxxxxxxxxxxxxx');
  c_bits_ffffffffffffff80 number := to_number('FFFFFFFFFFFFFF80','xxxxxxxxxxxxxxxx');
  c_bits_ffffffffffffffff number := to_number('FFFFFFFFFFFFFFFF','xxxxxxxxxxxxxxxx');

g_version varchar2(100) := '#VERSION#';
--PROGRAMS----------------------------------------------------------------------
function f_get_version
return varchar2
as
begin
  return g_version;
end f_get_version;

  ---
  --- Bitwise operators
  ---

  function bitor(x in number, y in number) return number as
  begin
    return (x + y - bitand(x, y));
  end;

  function bitxor(x in number, y in number) return number as
  begin
    return bitor(x, y) - bitand(x, y);
  end;

  function bitnot32(x in number) return number as
  begin
    return c_bits_ffffffff - x;
  end;

  function leftshift32(x in number, y in number) return number as
    tmp number := x;
  begin
    for idx in 1..y
    loop
      tmp := tmp * 2;
    end loop;
    return bitand(tmp, c_bits_ffffffff);
  end;

  function rightshift32(x in number, y in number) return number as
    tmp number := x;
  begin
    for idx in 1..y
    loop
      tmp := trunc(tmp / 2);
    end loop;
    return bitand(tmp, c_bits_ffffffff);
  end;

  function cyclic32(x in number, y in number) return number as
  begin
    return bitor(rightshift32(x, y), leftshift32(x, 32-y));
  end;

  function bitnot64(x in number) return number as
  begin
    return c_bits_ffffffffffffffff - x;
  end;

  function leftshift64(x in number, y in number) return number as
    tmp number := x;
  begin
    for idx in 1..y
    loop
      tmp := tmp * 2;
    end loop;
    return bitand(tmp, c_bits_ffffffffffffffff);
  end;

  function rightshift64(x in number, y in number) return number as
    tmp number := x;
  begin
    for idx in 1..y
    loop
      tmp := trunc(tmp / 2);
    end loop;
    return bitand(tmp, c_bits_ffffffffffffffff);
  end;

  function cyclic64(x in number, y in number) return number as
  begin
    return bitor(rightshift64(x, y), leftshift64(x, 64-y));
  end;

  ---
  --- Operators defined in FIPS 180-2:4.1.2.
  ---

  function op_maj(x in number, y in number, z in number) return number as
  begin
    return bitxor(bitxor(bitand(x,y), bitand(x,z)), bitand(y,z));
  end;

  function op_ch_32(x in number, y in number, z in number) return number as
  begin
    return bitxor(bitand(x, y), bitand(bitnot32(x), z));
  end;

  function op_s0_32(x in number) return number as
  begin
    return bitxor(bitxor(cyclic32(x, 2), cyclic32(x, 13)), cyclic32(x, 22));
  end;

  function op_s1_32(x in number) return number as
  begin
    return bitxor(bitxor(cyclic32(x, 6), cyclic32(x, 11)), cyclic32(x, 25));
  end;

  function op_r0_32(x in number) return number as
  begin
    return bitxor(bitxor(cyclic32(x, 7), cyclic32(x, 18)), rightshift32(x, 3));
  end;

  function op_r1_32(x in number) return number as
  begin
    return bitxor(bitxor(cyclic32(x, 17), cyclic32(x, 19)), rightshift32(x, 10));
  end;

  function op_ch_64(x in number, y in number, z in number) return number as
  begin
    return bitxor(bitand(x, y), bitand(bitnot64(x), z));
  end;

  function op_s0_64(x in number) return number as
  begin
    return bitxor(bitxor(cyclic64(x, 28), cyclic64(x, 34)), cyclic64(x, 39));
  end;

  function op_s1_64(x in number) return number as
  begin
    return bitxor(bitxor(cyclic64(x, 14), cyclic64(x, 18)), cyclic64(x, 41));
  end;

  function op_r0_64(x in number) return number as
  begin
    return bitxor(bitxor(cyclic64(x, 1), cyclic64(x, 8)), rightshift64(x, 7));
  end;

  function op_r1_64(x in number) return number as
  begin
    return bitxor(bitxor(cyclic64(x, 19), cyclic64(x, 61)), rightshift64(x, 6));
  end;

  --
  -- SHA-1
  --

  procedure sha1_init_ctx
  as
  begin
    m_ctx.h(0) := to_number('67452301', 'xxxxxxxx');
    m_ctx.h(1) := to_number('efcdab89', 'xxxxxxxx');
    m_ctx.h(2) := to_number('98badcfe', 'xxxxxxxx');
    m_ctx.h(3) := to_number('10325476', 'xxxxxxxx');
    m_ctx.h(4) := to_number('c3d2e1f0', 'xxxxxxxx');
    m_ctx.total_length := 0;
    m_ctx.leftover_buffer := null;
    m_ctx.leftover_buffer_length := 0;
    for idx in 0..15 loop
      m_ctx.words_array(idx) := 0;
    end loop;
  end sha1_init_ctx;

  procedure sha1_process_block(p_words_array in ta_number,
                               p_words_count in number)
  as
    l_words_array ta_number := p_words_array;
    l_words_count number := p_words_count;
    l_words_idx number;
    t number;
    a number := m_ctx.h(0);
    b number := m_ctx.h(1);
    c number := m_ctx.h(2);
    d number := m_ctx.h(3);
    e number := m_ctx.h(4);
    w ta_number;
    a_save number;
    b_save number;
    c_save number;
    d_save number;
    e_save number;
    f number;
    k number;
    temp number;
  begin
    -- Process all bytes in the buffer with 64 bytes in each round of the loop.
    l_words_idx := 0;
    while (l_words_count > 0) loop
      a_save := a;
      b_save := b;
      c_save := c;
      d_save := d;
      e_save := e;
      for t in 0..15 loop
        w(t) := l_words_array(l_words_idx);
        l_words_idx := l_words_idx + 1;
      end loop;
      for t in 16..79 loop
        w(t) := cyclic32(bitxor(bitxor(bitxor(w(t-3), w(t-8)), w(t-14)), w(t-16)), 32-1);
      end loop;
      for t in 0..79 loop
        if t between 0 and 19 then
          f := bitor(bitand(b, c), bitand(bitnot32(b), d));
          k := to_number('5a827999', 'xxxxxxxx');
        elsif t between 20 and 39 then
          f := bitxor(bitxor(b, c), d);
          k := to_number('6ed9eba1', 'xxxxxxxx');
        elsif t between 40 and 59 then
          f := bitor(bitor(bitand(b, c), bitand(b, d)), bitand(c, d));
          k := to_number('8f1bbcdc', 'xxxxxxxx');
        elsif t between 60 and 79 then
          f := bitxor(bitxor(b, c), d);
          k := to_number('ca62c1d6', 'xxxxxxxx');
        end if;
        temp := bitand(cyclic32(a, 32-5) + f + e + k + w(t), c_bits_ffffffff);
        e := d;
        d := c;
        c := cyclic32(b, 32-30);
        b := a;
        a := temp;
      end loop;
      a := bitand(a + a_save, c_bits_ffffffff);
      b := bitand(b + b_save, c_bits_ffffffff);
      c := bitand(c + c_save, c_bits_ffffffff);
      d := bitand(d + d_save, c_bits_ffffffff);
      e := bitand(e + e_save, c_bits_ffffffff);
      -- Prepare for the next round.
      l_words_count := l_words_count - 16;
    end loop;
    -- Put checksum in context given as argument.
    m_ctx.h(0) := a;
    m_ctx.h(1) := b;
    m_ctx.h(2) := c;
    m_ctx.h(3) := d;
    m_ctx.h(4) := e;
  end sha1_process_block;

  procedure sha1_process_bytes(p_buffer in raw,
                               p_buffer_length in number)
  as
    l_buffer raw(16640);
    l_buffer_length number;
    l_words_array ta_number;
  begin
    -- First increment the byte count.  FIPS 180-2 specifies the possible
    -- length of the file up to 2^64 bits. Here we only compute the number of
    -- bytes.
    m_ctx.total_length := m_ctx.total_length + nvl(p_buffer_length, 0);
    -- When we already have some bits in our internal buffer concatenate both inputs first.
    if (m_ctx.leftover_buffer_length = 0) then
      l_buffer := p_buffer;
      l_buffer_length := nvl(p_buffer_length, 0);
    else
      l_buffer := m_ctx.leftover_buffer || p_buffer;
      l_buffer_length := m_ctx.leftover_buffer_length + nvl(p_buffer_length, 0);
    end if;
    -- Process available complete blocks.
    if (l_buffer_length >= 64) then
      declare
        l_words_count number := bitand(l_buffer_length, c_bits_ffffffc0) / 4;
        l_max_idx number := l_words_count - 1;
        l_numberraw raw(4);
        l_numberhex varchar(8);
        l_number number;
      begin
        for idx in 0..l_max_idx loop
          l_numberraw := sys.utl_raw.substr(l_buffer, idx * 4 + 1, 4);
          l_numberhex := rawtohex(l_numberraw);
          l_number := to_number(l_numberhex, 'xxxxxxxx');
          l_words_array(idx) := l_number;
        end loop;
        sha1_process_block(l_words_array, l_words_count);
        l_buffer_length := bitand(l_buffer_length, 63);
        if (l_buffer_length > 0) then
          l_buffer := sys.utl_raw.substr(l_buffer, l_words_count * 4 + 1, l_buffer_length);
        end if;
      end;
    end if;
    -- Move remaining bytes into internal buffer.
    if (l_buffer_length > 0) then
      m_ctx.leftover_buffer := l_buffer;
      m_ctx.leftover_buffer_length := l_buffer_length;
    end if;
  end sha1_process_bytes;

  procedure sha1_finish_ctx(p_resultbuf out nocopy ta_number)
  as
    l_filesizeraw raw(8);
  begin
    m_ctx.leftover_buffer := m_ctx.leftover_buffer || c_bits_80;
    m_ctx.leftover_buffer_length := m_ctx.leftover_buffer_length + 1;
    while ((m_ctx.leftover_buffer_length mod 64) <> 56) loop
      m_ctx.leftover_buffer := m_ctx.leftover_buffer || c_bits_00;
      m_ctx.leftover_buffer_length := m_ctx.leftover_buffer_length + 1;
    end loop;
    l_filesizeraw := hextoraw(to_char(m_ctx.total_length * 8, 'FM0xxxxxxxxxxxxxxx'));
    m_ctx.leftover_buffer := m_ctx.leftover_buffer || l_filesizeraw;
    m_ctx.leftover_buffer_length := m_ctx.leftover_buffer_length + 8;
    sha1_process_bytes(null, 0);
    for idx in 0..4 loop
      p_resultbuf(idx) := m_ctx.h(idx);
    end loop;
  end sha1_finish_ctx;

  function sha1(p_buffer in raw) return sha1_checksum_raw
  as
    l_result sha1_checksum_raw;
  begin
    sha1_init_ctx;
    sha1_process_bytes(p_buffer, sys.utl_raw.length(p_buffer));
    sha1_finish_ctx(m_result);
    l_result := hextoraw(
      to_char(m_result(0), 'FM0xxxxxxx') ||
      to_char(m_result(1), 'FM0xxxxxxx') ||
      to_char(m_result(2), 'FM0xxxxxxx') ||
      to_char(m_result(3), 'FM0xxxxxxx') ||
      to_char(m_result(4), 'FM0xxxxxxx')
    );
    return l_result;
  end sha1;

  function sha1(p_buffer in blob) return sha1_checksum_raw
  as
    l_result sha1_checksum_raw;
    l_buffer raw(16384);
    l_amount number := 16384;
    l_offset number := 1;
  begin
    sha1_init_ctx;
    begin
      loop
        sys.dbms_lob.read(p_buffer, l_amount, l_offset, l_buffer);
        sha1_process_bytes(l_buffer, l_amount);
        l_offset := l_offset + l_amount;
        l_amount := 16384;
      end loop;
    exception
      when no_data_found then
        null;
    end;
    sha1_finish_ctx(m_result);
    l_result := hextoraw(
      to_char(m_result(0), 'FM0xxxxxxx') ||
      to_char(m_result(1), 'FM0xxxxxxx') ||
      to_char(m_result(2), 'FM0xxxxxxx') ||
      to_char(m_result(3), 'FM0xxxxxxx') ||
      to_char(m_result(4), 'FM0xxxxxxx')
    );
    return l_result;
  end sha1;

  function sha1_vc(p_buffer in varchar2) 
  return sha1_checksum_vc2
  as
    l_retvar sha1_checksum_vc2;
  begin

    l_retvar := rawtohex(sha1(utl_raw.cast_to_raw(p_buffer)));

    return l_retvar;
  end;

end ;


/
