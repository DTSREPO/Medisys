/* Price_evaluation_procedure */
create or replace procedure get_price_evaluation_proc(p_data_set varchar2,p_type out varchar2, p_lang out varchar2,p_value1 OUT SYS_REFCURSOR,p_value2 OUT SYS_REFCURSOR,p_value3 OUT SYS_REFCURSOR) AS
  v_data varchar2(300):=p_data_set;
  type firstarray IS VARRAY(500) OF VARCHAR2(1000);
  array1 firstarray:=firstarray();
  type secondarray IS VARRAY(500) OF VARCHAR2(1000); 
  array2 secondarray:=secondarray();
  type thirdarray IS VARRAY(500) OF VARCHAR2(1000); 
  array3 thirdarray:=thirdarray();
  cnt number :=0;
  cnt1 number :=0;
  cnt3 number :=0;
  c_value bulk_data:=bulk_data();
  c_value2 bulk_data:=bulk_data();
  c_value3 bulk_data:=bulk_data();
  v_result varchar2(4000);
  v_result_max varchar2(4000);
  v_result_min varchar2(4000);
  v_gen varchar2(4);
  v_form varchar2(2);
  v_route varchar2(2);
  v_strength varchar2(100);
  v_gen_desc varchar2(200);
  v_product_desc varchar2(300);
  v_manuf_desc varchar2(300);
begin
  for i in (select regexp_substr(v_data,'[^$]+', 1, level) as val from dual connect by regexp_substr(v_data, '[^$]+', 1, level) is not null) loop
    cnt:=cnt+1;
    array1.extend;
    array1(cnt):=i.val;
  end loop;
  cnt:=0;
  for j in (select regexp_substr(array1(3),'[^!]+', 1, level) as val from dual connect by regexp_substr(array1(3), '[^!]+', 1, level) is not null) loop
    cnt:=cnt+1;
    array2.extend;
    array2(cnt):=j.val;
  end loop;
  cnt :=0;
  for k in 1..array2.count loop
    begin
      select TRIM(LTRIM(RTRIM(SUBSTR(array2(k),1,4)))), TRIM(LTRIM(RTRIM(SUBSTR(array2(k),5,2)))), TRIM(LTRIM(RTRIM(SUBSTR(array2(k),7,2)))),
      LOWER(TRIM(LTRIM(RTRIM(SUBSTR(array2(k),9,100))))) into v_gen, v_route, v_form, v_strength from dual;
      select t_lang2_name into v_gen_desc from t30004 where t_gen_code=v_gen;

       for a in (select gen_desc, gen_code, product_desc, strength, route_code, form_code, moh_price, sut_price, MANUF_DESC, item_code
                from v30001 where gen_code=v_gen and route_code=v_route and form_code=v_form
                and lower(trim(ltrim(rtrim(replace(strength,' ','')))))=lower(trim(ltrim(rtrim(replace(v_strength,' ','')))))
                ORDER BY trim(ltrim(rtrim(product_desc)))
       ) loop

            v_result:=a.gen_desc||'|'||a.product_desc||'|'||a.moh_price||'|'||a.sut_price||'|'||a.MANUF_DESC||'|'||a.item_code;
            cnt:=cnt+1;
            c_value.extend;
            c_value(cnt):=v_result;
        end loop;

        for b in (select item_code,product_desc,moh_price,sut_price from v30001 where gen_code=v_gen and form_code=v_form and route_code=v_route
                  and moh_price=(select max(moh_price) from v30001 where gen_code=v_gen and form_code=v_form and route_code=v_route)
                  and rownum=(select min(rownum) from v30001 where gen_code=v_gen and form_code=v_form and route_code=v_route)) loop
            v_result_max:=b.product_desc||'|'||b.moh_price||'|'||b.sut_price||'|'||b.item_code;
            cnt1:=cnt1+1;
            c_value2.extend;
            c_value2(cnt1):=v_result_max;
        end loop;
        for c in (select item_code,product_desc,moh_price,sut_price from v30001 where gen_code=v_gen and form_code=v_form and route_code=v_route
                  and moh_price=(select min(moh_price) from v30001 where gen_code=v_gen and form_code=v_form and route_code=v_route)
                  and rownum=(select min(rownum) from v30001 where gen_code=v_gen and form_code=v_form and route_code=v_route)) loop
            v_result_min:=c.product_desc||'|'||c.moh_price||'|'||c.sut_price||'|'||c.item_code;
            cnt3:=cnt3+1;
            c_value3.extend;
            c_value3(cnt3):=v_result_min;
        end loop;
      exception when no_data_found then null;
    end;
  end loop;
    if v_result is not null then
        OPEN p_value1 FOR select * from table(cast (c_value  as bulk_data));
    else
        OPEN p_value1 FOR select 'No Data Found!' from dual;
    end if;
    if v_result_max is not null then
        OPEN p_value2 FOR select * from table(cast (c_value2  as bulk_data));
    else
        OPEN p_value2 FOR select 'No Data Found!' from dual;
    end if;
    if v_result_min is not null then
        OPEN p_value3 FOR select * from table(cast (c_value3  as bulk_data));
    else
        OPEN p_value3 FOR select 'No Data Found!' from dual;
    end if;
    exception when no_data_found then
        OPEN p_value1 FOR select 'No Data Found!' from dual;
end;
/*
set serveroutput on;
declare
    price_eval_cursor SYS_REFCURSOR;
    max_price_cursor sys_refcursor;
    min_price_cursor sys_refcursor;
    v_type varchar2(3);
    v_lang varchar2(3);
    l_rec varchar2(30000);
    max_price varchar2(30000);
    min_price varchar2(30000);
BEGIN
    get_price_evaluation_proc (
        p_data_set  =>'1$2$17640401500mg!12370402300mg',        -- in parameter
        p_type      =>v_type,                                   -- out parameter for type
        p_lang      =>v_lang,                                   -- out parameter for language
        p_value1    =>price_eval_cursor,                        
        p_value2    =>max_price_cursor,
        p_value3    =>min_price_cursor 
    );
dbms_output.put_line('... Generic Wise All Trade ...');

    LOOP
        FETCH price_eval_cursor INTO l_rec;
        EXIT WHEN price_eval_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE price_eval_cursor;


dbms_output.put_line('... Generic Wise All Trade Only Max Price ...');

    LOOP
        FETCH max_price_cursor INTO max_price;
        EXIT WHEN max_price_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(max_price);
    END LOOP;
    CLOSE max_price_cursor;
    
dbms_output.put_line('... Generic Wise All Trade Only Min Price ...');

    LOOP
        FETCH min_price_cursor INTO min_price;
        EXIT WHEN min_price_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(min_price);
    END LOOP;
    CLOSE min_price_cursor;

    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
... Generic Wise All Trade ...
PARACETAMOL|FAST ORAL TABLET 500mg|0|0|ACME LABORATORIES LTD|508629
PARACETAMOL|PARAPYROL ORAL TABLET 500mg|1.5|0|GLAXO SMITH KLINE|501441
PARACETAMOL|RENOVA ORAL TABLET 500mg|0|0|OPSONIN PHARMA|510159
PARACETAMOL|TAMEN ORAL TABLET 500mg|1.8|0|SK+F|506560
PARACETAMOL|XPA ORAL TABLET 500mg|1.2|0|ARISTOPHARMA LTD|506987
PARACETAMOL|ZERIN ORAL TABLET 500mg|1.5|0|JAYSON   PHARMA|508627
CLINDAMYCIN|CLIMYCIN ORAL CAPSUL 300mg|0|0|SQUARE PHARMA|510187
CLINDAMYCIN|CLINDACIN ORAL CAPSUL 300mg|0|0|INCEPTA  PHARMA|508883
CLINDAMYCIN|CLINDAX ORAL CAPSUL 300mg|0|0|OPSONIN PHARMA|507729
CLINDAMYCIN|CLINEX ORAL CAPSUL 300mg|57.8|0|ARISTOPHARMA LTD|505876
CLINDAMYCIN|QCIN ORAL CAPSUL 300mg|0|0|RENATA LTD.|510590
... Generic Wise All Trade Only Max Price ...
LONGPARA ORAL TABLET 665mg|2|0|506102
CLINEX ORAL CAPSUL 300mg|57.8|0|505876
... Generic Wise All Trade Only Min Price ...
FAST ORAL TABLET 500mg|0|0|508629
CLIMYCIN ORAL CAPSUL 150mg|0|0|510982


PL/SQL procedure successfully completed.
*/
/* Wrong Paramater Value */
/*
set serveroutput on;
declare
    price_eval_cursor SYS_REFCURSOR;
    max_price_cursor sys_refcursor;
    min_price_cursor sys_refcursor;
    v_type varchar2(3);
    v_lang varchar2(3);
    l_rec varchar2(30000);
    max_price varchar2(30000);
    min_price varchar2(30000);
BEGIN
    get_price_evaluation_proc (
        p_data_set  =>'1$2$1764040',        -- in parameter
        p_type      =>v_type,                                   -- out parameter for type
        p_lang      =>v_lang,                                   -- out parameter for language
        p_value1    =>price_eval_cursor,                        
        p_value2    =>max_price_cursor,
        p_value3    =>min_price_cursor 
    );
dbms_output.put_line('... Generic Wise All Trade ...');

    LOOP
        FETCH price_eval_cursor INTO l_rec;
        EXIT WHEN price_eval_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE price_eval_cursor;


dbms_output.put_line('... Generic Wise All Trade Only Max Price ...');

    LOOP
        FETCH max_price_cursor INTO max_price;
        EXIT WHEN max_price_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(max_price);
    END LOOP;
    CLOSE max_price_cursor;
    
dbms_output.put_line('... Generic Wise All Trade Only Min Price ...');

    LOOP
        FETCH min_price_cursor INTO min_price;
        EXIT WHEN min_price_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(min_price);
    END LOOP;
    CLOSE min_price_cursor;

    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
... Generic Wise All Trade ...
No Data Found!
... Generic Wise All Trade Only Max Price ...
No Data Found!
... Generic Wise All Trade Only Min Price ...
No Data Found!


PL/SQL procedure successfully completed.
*/