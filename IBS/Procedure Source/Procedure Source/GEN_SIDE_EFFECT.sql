/* Side Effects of product */
create or replace procedure get_gen_side_effect_proc (p_data_set varchar2, p_value OUT SYS_REFCURSOR) as
    v1 varchar2(100):=p_data_set;
    type firstarray IS VARRAY(50) OF VARCHAR2(30000); 
    array1 firstarray:=firstarray();
    type secondarray IS VARRAY(50) OF VARCHAR2(30000); 
    array2 secondarray:=secondarray();
    c_value bulk_data:=bulk_data();
    pm_gen_set varchar2(100);
    total number:=0;
    v_start NUMBER:=1;
    v_end number:=4;
    v_end_loop number;
    v_result varchar2(30000);
begin
    for i in (select regexp_substr(v1,'[^-]+', 1, level) as val from dual connect by regexp_substr(v1, '[^-]+', 1, level) is not null) loop
        total:=total+1;
        array1.extend;
        array1(total):=i.val;
    end loop;
    for i in array1.first..array1.last loop
       pm_gen_set:=array1(3);
    end loop;

    --p_type:=array1(1);
    --p_lang:=array1(2);

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
    for i in 1..array2.count loop
            FOR c in (select A.T_GEN_CODE GEN_CODE, B.T_LANG2_NAME GEN_DESC, A.T_FORMULA_CODE FRM_CODE, C.T_LANG2_NAME FORMULA_DESC, A.T_FORMULA_NOTES NOTES
                      from T30026 A, T30004 B, T30027 C
                      WHERE T_FORMULA_CODE='1005' AND A.T_FORMULA_CODE=C.T_FRMLRY_CODE AND A.T_GEN_CODE=B.T_GEN_CODE AND A.T_GEN_CODE=ARRAY2(I)
            ) loop
                v_result:=c.GEN_DESC||'|'||c.NOTES ||'|'||c.GEN_CODE||c.FRM_CODE;
                total:=total+1;
                c_value.extend;
                c_value(total):=v_result;
            end loop;
    end loop;
    if v_result is null then
        OPEN p_value FOR select 'No Data Found!' from dual;
    else
        OPEN p_value FOR select * from table(cast (c_value  as bulk_data));
    end if;

else
    OPEN p_value FOR select 'No Data Found!' from dual;
end if;
   exception when others then
    OPEN p_value FOR select 'No Data Found!' from dual;
end;

/*
set serveroutput on;
declare
    effect_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    v_gen_desc varchar2(20000);
BEGIN
    get_gen_side_effect_proc (
        p_data_set   =>'1-2-1460',      -- in parameter
        p_value      =>effect_cursor     -- generic set it will store in array then fetch by loop
    );
    LOOP
        FETCH effect_cursor INTO v_gen_desc;
        EXIT WHEN effect_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_gen_desc);
    END LOOP;
    CLOSE effect_cursor;
    
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
GENTAMICIN|No Side Effect|14601005


PL/SQL procedure successfully completed.
*/
/* Wrong Parameter Value */
/*
set serveroutput on;
declare
    effect_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    v_gen_desc varchar2(20000);
BEGIN
    get_gen_side_effect_proc (
        p_data_set   =>'1-2-146',      -- in parameter
        p_value      =>effect_cursor     -- generic set it will store in array then fetch by loop
    );
    LOOP
        FETCH effect_cursor INTO v_gen_desc;
        EXIT WHEN effect_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_gen_desc);
    END LOOP;
    CLOSE effect_cursor;
    
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
No Data Found!


PL/SQL procedure successfully completed.
*/
