/* Get Generic Description */
create or replace procedure get_gen_desc (p_data_set in varchar2,  p_value OUT SYS_REFCURSOR)
as
    v1 varchar2(1000):=p_data_set;
    type firstarray IS VARRAY(500) OF VARCHAR2(1000); 
    array1 firstarray:=firstarray();
    type secondarray IS VARRAY(500) OF VARCHAR2(1000); 
    array2 secondarray:=secondarray();
    c_value bulk_data:=bulk_data();
    pm_gen_set varchar2(100);
    total number:=0;
    v_result varchar2(4000);
    v_start NUMBER:=1;
    v_end number:=4;
    v_end_loop number;
    v_gen_desc varchar2(200);
begin
    for i in (select regexp_substr(v1,'[^-]+', 1, level) as val from dual connect by regexp_substr(v1, '[^-]+', 1, level) is not null) loop
        total:=total+1;
        array1.extend;
        array1(total):=i.val;
    end loop;
    for i in array1.first..array1.last loop
       pm_gen_set:=array1(3);
    end loop;

    v_end_loop:=length(pm_gen_set)/4;
    if mod(length(pm_gen_set),4)=0 then
        total:=0;
        FOR I IN 1..v_end_loop LOOP
            total:=total+1;
            array2.extend;
            array2(total):=SUBSTR(pm_gen_set,v_start,v_end);
            v_start:=v_start+4;
        end loop;
    end if;

    total:=0;
    
if array2.count>0 then
    for j in 1..array2.count loop
        begin
            select t_gen_code ||'|'||t_lang2_name into v_gen_desc from t30004 where t_gen_code=array2(j);
            v_result:=v_gen_desc;
            total:=total+1;
            c_value.extend;
            c_value(total):=v_result;
            exception when no_data_found then null;
        end;
    end loop;

   OPEN p_value FOR select * from table(cast (c_value  as bulk_data));
else
   OPEN p_value FOR select 'No Data Found!' from dual;
end if;
   exception when others then
      OPEN p_value FOR select 'No Data Found!' from dual;
end;

/*
set serveroutput on;
declare
    gen_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    v_gen_desc varchar2(200);
BEGIN
    get_gen_desc (
        p_data_set   =>'1-2-14601600182820992290',   -- in parameter
        p_value      =>gen_cursor                    -- generic set it will store in array then fetch by loop
    );
    LOOP
        FETCH gen_cursor INTO v_gen_desc;
        EXIT WHEN gen_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_gen_desc);
    END LOOP;
    CLOSE gen_cursor;
    
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;

*/