/* List_of_speciality */
create or replace procedure get_spcilty_info_proc(
                                                    p_gen_code in varchar2,
                                                    p_gen_spcilty_desc out varchar2
                                                )
as
begin

    /* Product Information */
    for i in (select trim(ltrim(rtrim(g.t_lang2_name)))gen_desc ,trim(ltrim(rtrim(s.t_lang2_name))) spcilty_desc, trim(ltrim(rtrim(g.t_gen_code))) gen_code
            from t30004 g,t02040 s
            where g.t_speclty_code=s.t_spclty_code
            and g.t_gen_code=p_gen_code) loop
            p_gen_spcilty_desc:=I.gen_desc||'|'||I.spcilty_desc||'|'||I.gen_code;
    end loop;

        if p_gen_spcilty_desc is null then
        p_gen_spcilty_desc:=('No Data Found');
    end if;

    EXCEPTION WHEN NO_DATA_FOUND THEN
   p_gen_spcilty_desc:=('No Data Found');
end;
/*
declare
v_num varchar2(2000);
begin 
get_spcilty_info_proc('1191',v_num);
dbms_output.put_line(v_num);
end;
*/
/* Result */
/*
CEFTRIAXONE|PAEDIATRIC SURGERY|1191


PL/SQL procedure successfully completed.
*/
/* Wrong Parameter Value */
/*
declare
v_num varchar2(2000);
begin 
get_spcilty_info_proc('11',v_num);
dbms_output.put_line(v_num);
end;
*/
/* Result */
/*
No Data Found


PL/SQL procedure successfully completed.
*/
