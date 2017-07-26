/* Drug_Allergy_Procedure */
create or replace procedure get_drug_allergy_proc (p_data_set varchar2, p_type out varchar2, p_lang out varchar2, p_value OUT SYS_REFCURSOR) as
    v1 varchar2(1000):=p_data_set;
    type firstarray IS VARRAY(500) OF VARCHAR2(1000); 
    array1 firstarray:=firstarray();
    type secondarray IS VARRAY(500) OF VARCHAR2(1000); 
    array2 secondarray:=secondarray();
    c_value bulk_data:=bulk_data();
    pm_gen_set varchar2(100);
    cnt number:=0;
    v_start NUMBER:=1;
    v_end number:=4;
    v_end_loop number;
    v_comp_value varchar2(4000);
    v_result varchar2(4000);
    v_gen_code_desc varchar2(200);

begin
    for i in (select regexp_substr(v1,'[^-]+', 1, level) as val from dual connect by regexp_substr(v1, '[^-]+', 1, level) is not null) loop
        cnt:=cnt+1;
        array1.extend;
        array1(cnt):=i.val;
    end loop;
    for i in array1.first..array1.last loop
       pm_gen_set:=array1(3);
    end loop;

    --p_type:=array1(1);
    --p_lang:=array1(2);

    v_end_loop:=length(pm_gen_set)/4;
    if mod(length(pm_gen_set),4)=0 then
        cnt:=0;
        FOR I IN 1..v_end_loop LOOP
            cnt:=cnt+1;
            array2.extend;
            array2(cnt):=SUBSTR(pm_gen_set,v_start,v_end);
            v_start:=v_start+4;
        end loop;
    end if;
    cnt:=0;
    for i in 1..array2.count loop
        for j in (select trim(ltrim(rtrim(a.t_lang1_allergy))) Turkey,trim(ltrim(rtrim(a.t_lang2_allergy))) allergy_desc,trim(ltrim(rtrim(g.t_gen_code))) gen_code, trim(ltrim(rtrim(g.t_lang2_name))) gen_desc from t30311 a,t30004 g 
        where a.t_gen_code=g.t_gen_code and g.t_gen_code=array2(i)) loop
             v_result:=(j.gen_desc||'|'||j.allergy_desc||'|'||j.gen_code);
             cnt:=cnt+1;
             c_value.extend;
             c_value(cnt):=v_result;
        end loop;
    end loop;
    if v_result is not null then
        OPEN p_value FOR select * from table(cast (c_value  as bulk_data));
    else
        OPEN p_value FOR select 'No Data Found!' from dual;
    end if;
exception when others then
    OPEN p_value FOR select 'No Data Found! Exception' from dual;
   --dbms_output.put_line(sqlerrm);

end;
/*
set serveroutput on;
declare
    drug_allergy_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    l_rec varchar2(30000);
BEGIN
    get_drug_allergy_proc (
        p_data_set  =>'1-2-124012251054',           -- in parameter
        p_type      =>v_type,                       -- out parameter for type
        p_lang      =>v_lang,                       -- out parameter for language
        p_value     =>drug_allergy_cursor         -- generic set it will store in array then fetch by loop
    );

    LOOP
        FETCH drug_allergy_cursor INTO l_rec;
        EXIT WHEN drug_allergy_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE drug_allergy_cursor;
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
FLUTICASONE FUROATE|YYY|1240
FLUTICASONE FUROATE|TEST ENGLISH 555|1240
PERMETHRINE+CROMATIN|TEST ENGLISH 123|1225
ANTI-HEPATITIS B SURFACE ANTIGEN|TEST ENGLISH 321|1054


PL/SQL procedure successfully completed.
*/
/* Wrong Parameter Value */
/*
set serveroutput on;
declare
    drug_allergy_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    l_rec varchar2(30000);
BEGIN
    get_drug_allergy_proc (
        p_data_set  =>'1-2-12401225105',           -- in parameter
        p_type      =>v_type,                       -- out parameter for type
        p_lang      =>v_lang,                       -- out parameter for language
        p_value     =>drug_allergy_cursor         -- generic set it will store in array then fetch by loop
    );

    LOOP
        FETCH drug_allergy_cursor INTO l_rec;
        EXIT WHEN drug_allergy_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE drug_allergy_cursor;
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
No Data Found!


PL/SQL procedure successfully completed.
*/
