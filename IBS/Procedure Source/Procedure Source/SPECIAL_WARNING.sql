create or replace procedure get_special_warning_proc (p_data_set varchar2, p_type out varchar2, p_lang out varchar2, p_value OUT SYS_REFCURSOR) as
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

    p_type:=array1(1);
    p_lang:=array1(2);

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
            FOR c in (SELECT A.T_LANG2_NAME GEN_DESC, B.T_LANG2_NAME WARNING_DESC, A.T_GEN_CODE, B.T_WARNING_CODE FROM T30004 A, T30323 B WHERE A.T_WARNING_CODE=B.T_WARNING_CODE AND A.T_GEN_CODE=ARRAY2(I)) loop
                v_result:=c.GEN_DESC||' | '||c.WARNING_DESC||' | '||c.T_GEN_CODE||c.T_WARNING_CODE;
                total:=total+1;
                c_value.extend;
                c_value(total):=v_result;
            end loop;
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
    sw_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    l_rec varchar2(30000);
BEGIN
    GET_SPECIAL_WARNING_PROC (
        p_data_set  =>'1-2-146016001828',           -- in parameter
        p_type      =>v_type,                       -- out parameter for type
        p_lang      =>v_lang,                       -- out parameter for language
        p_value     =>sw_cursor                     -- generic set it will store in array then fetch by loop
    );
    
    DBMS_OUTPUT.PUT_LINE('Type : '||v_type);
    DBMS_OUTPUT.PUT_LINE('Lang : '||v_lang);

    LOOP
        FETCH sw_cursor INTO l_rec;
        EXIT WHEN sw_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE sw_cursor;
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
Type : 1
Lang : 2
GENTAMICIN|N/A|1460
LITHIUM CARBONATE|N/A|1600
PIROXICAM|N/A|1828


PL/SQL procedure successfully completed.
*/
/* Wrong Parameter Value */
/*
set serveroutput on;
declare
    sw_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    l_rec varchar2(30000);
BEGIN
    GET_SPECIAL_WARNING_PROC (
        p_data_set  =>'1-2-14601600182',           -- in parameter
        p_type      =>v_type,                       -- out parameter for type
        p_lang      =>v_lang,                       -- out parameter for language
        p_value     =>sw_cursor                     -- generic set it will store in array then fetch by loop
    );
    
    DBMS_OUTPUT.PUT_LINE('Type : '||v_type);
    DBMS_OUTPUT.PUT_LINE('Lang : '||v_lang);

    LOOP
        FETCH sw_cursor INTO l_rec;
        EXIT WHEN sw_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE sw_cursor;
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
Type : 1
Lang : 2
No Data Found!


PL/SQL procedure successfully completed.
*/
