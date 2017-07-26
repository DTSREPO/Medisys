/* Diseases_interaction */
create or replace procedure get_di_proc (p_data_set varchar2, p_type out varchar2, p_lang out varchar2, p_value OUT SYS_REFCURSOR) as
    v1 varchar2(1000):=p_data_set;
    type firstarray IS VARRAY(500) OF VARCHAR2(1000); 
    array1 firstarray:=firstarray();
    type secondarray IS VARRAY(500) OF VARCHAR2(1000); 
    array2 secondarray:=secondarray();
    c_value bulk_data:=bulk_data();
    pm_gen_set varchar2(100);
    total number:=0;
    v_start NUMBER:=1;
    v_end number:=4;
    v_dis_drug_desc varchar2(4000);
    v_end_loop number;
    V_ICD_CODE VARCHAR2(10);
    V_ICD_DESC VARCHAR2(1000);
    V_DI_EFFECT VARCHAR2(2000);
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
            --dbms_output.put_line(array2(total));
        end loop;
    end if;

    /* Diseases interaction  */

        FOR I IN 1..ARRAY2.COUNT LOOP
            for j in (
                        select b.T_ICD10_LONG_DESC ICD10_DESC, A.T_DI_EFFECT, A.T_ICD10_CODE ICD_CODE
                        from T30310 a, T06301 B
                        where a.T_ICD10_CODE=(B.T_ICD10_MAIN_CODE||''||B.T_ICD10_SUB_CODE) and A.T_SYMPTOM_FLAG is null and A.T_GEN_CODE=array2(i)
            ) loop
                v_dis_drug_desc:=j.ICD10_DESC||'|'||j.T_DI_EFFECT||'|'||j.ICD_CODE;

                c_value.extend;
                c_value(i):=v_dis_drug_desc;
            end loop;
        END LOOP;
        if v_dis_drug_desc is not null then
            OPEN p_value FOR select * from table(cast (c_value  as bulk_data));
        else
            OPEN p_value FOR select 'No Data Found!' from dual;
        end if;

END;
/*
set serveroutput on;
declare
    di_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    l_rec varchar2(30000);
BEGIN
    get_di_proc (
        p_data_set  =>'1-2-14601101',               -- in parameter
        p_type      =>v_type,                       -- out parameter for type
        p_lang      =>v_lang,                       -- out parameter for language
        p_value     =>di_cursor                     -- generic set it will store in array then fetch by loop
    );

    LOOP
        FETCH di_cursor INTO l_rec;
        EXIT WHEN di_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE di_cursor;
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
Car occupant injured in collision with heavy transport vehicle or bus, passenger, nontraffic accident, passenger van|Test Intraction Here Dummy2  English|V4413


PL/SQL procedure successfully completed.
*/
/* Wrong Parameter Value */
/*
set serveroutput on;
declare
    di_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    l_rec varchar2(30000);
BEGIN
    get_di_proc (
        p_data_set  =>'1-2-1460110',               -- in parameter
        p_type      =>v_type,                       -- out parameter for type
        p_lang      =>v_lang,                       -- out parameter for language
        p_value     =>di_cursor                     -- generic set it will store in array then fetch by loop
    );

    LOOP
        FETCH di_cursor INTO l_rec;
        EXIT WHEN di_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE di_cursor;
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
No Data Found!


PL/SQL procedure successfully completed.
*/
