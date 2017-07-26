/* Drug Drgu Interaction */
create or replace procedure get_ddi_proc (p_data_set varchar2, p_type out varchar2, p_lang out varchar2, p_value OUT SYS_REFCURSOR) as
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
    v_end_loop number;
    v_comp_value varchar2(4000);
    v_result varchar2(4000);
    v_gen_code_desc varchar2(200);
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

if array2.count>0 then
    total:=0;
    for i in 1..array2.count loop
        for j in i..array2.count loop
            if j>i then
                BEGIN
                    SELECT
                    INITCAP(B.T_LANG2_NAME) ||'|'||
                    (SELECT INITCAP(T_LANG2_NAME) FROM T30004 WHERE T_GEN_CODE = A.T_GEN_GEN_DDI) ||'|'||--GEN_DESC_DDI,
                    C.T_LANG2_NAME ||'|'||--SIGNIF_DESC,
                    D.T_LANG2_NAME ||'|'||--ONSET_DESC,
                    E.T_LANG2_NAME ||'|'||--SEVERITY_DESC,
                    F.T_LANG2_NAME ||'|'||--DOC_DESC,
                    A.t_ddi_comm ||'|'|| --EFFECT
                    A.T_GEN_CODE||(SELECT T_GEN_CODE FROM T30004 WHERE T_GEN_CODE = A.T_GEN_GEN_DDI)
                INTO v_comp_value --V_UNIQ, V_GEN_DESC, V_GEN_DDI, V_SIGNIF_DESC, V_ONSET_DESC, V_SEVERITY_DESC, V_DOC_DESC, V_EFFECT
                FROM
                    T30041 A
                    LEFT JOIN T30004 B ON A.T_GEN_CODE=B.T_GEN_CODE
                    LEFT JOIN T30032 C ON A.T_SIGNIF_CODE = C.T_SIGNIF_CODE
                    LEFT JOIN T30030 D ON A.T_ONSET_CODE = D.T_ONSET_CODE
                    LEFT JOIN T30031 E ON A.T_SEVERITY_CODE = E.T_SEVERITY_CODE
                    LEFT JOIN T30029 F ON A.T_DOCUM_CODE = F.T_DOCUM_CODE
                WHERE
                    A.T_GEN_CODE = array2(i) AND A.T_GEN_GEN_DDI = array2(j); --or A.T_GEN_CODE = array2(j) AND A.T_GEN_GEN_DDI = array2(i);
                    
                    v_result:=v_comp_value; --V_UNIQ||'|'||V_GEN_DESC||'|'||V_GEN_DDI||'|'||V_SIGNIF_DESC||'|'||V_ONSET_DESC||'|'||V_SEVERITY_DESC||'|'||V_DOC_DESC||'|'||V_EFFECT;
                    total:=total+1;
                    c_value.extend;
                    c_value(total):=v_result;
                    
                    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
                END;
            end if;
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
    ddi_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    l_rec varchar2(4000);
BEGIN
    get_ddi_proc (
        p_data_set  =>'1-2-14601600182820992290',   -- in parameter
        p_type      =>v_type,                       -- out parameter for type
        p_lang      =>v_lang,                       -- out parameter for language
        p_value     =>ddi_cursor                    -- generic set it will store in array then fetch by loop
    );
    DBMS_OUTPUT.PUT_LINE('Type : '||v_type);
    DBMS_OUTPUT.PUT_LINE('Lang : '||v_lang);
    LOOP
        FETCH ddi_cursor INTO l_rec;
        EXIT WHEN ddi_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE ddi_cursor;
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/