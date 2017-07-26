/* Price_comparision_list */
create or replace PROCEDURE get_com_price_proc (
    p_data_set      VARCHAR2,
    p_com_product out varchar2,
    p_value out sys_refcursor
) IS
    TYPE comn_type IS TABLE OF VARCHAR2 (1000);
    array1   comn_type := comn_type ();
    array2   comn_type := comn_type ();
    c_value bulk_data:=bulk_data();
    v_result VARCHAR2(1000);
    cnt number:=0;
    cnt1 number:=0;
    v_gen_code           VARCHAR2(10);
    v_drug_master_code   VARCHAR2(10);
    v_lang2_name         VARCHAR2(200);
    v_turkey_name        VARCHAR2(200);
    v_item_code          varchar2(8);
    v_strength           VARCHAR2(10);
    v_drug_form_code     VARCHAR2(10);
    v_route_code         VARCHAR2(10);
    v_moh_cost           NUMBER(10,2);
    v_moh_price          NUMBER(10,2);
BEGIN
    for x in (select regexp_substr(P_DATA_SET,'[^-]+', 1, level) as val from dual connect by regexp_substr(P_DATA_SET, '[^-]+', 1, level) is not null) loop
        cnt1:=cnt1+1;
        array1.extend;
        array1(cnt1):=x.val;
    end loop;
    
    SELECT
        g.t_gen_code,i.t_lang2_name,nvl(i.t_lang1_name,'N/A') turkey_name
    INTO
        v_gen_code,v_lang2_name,v_turkey_name
    FROM
        t30008 i,
        t30006 m,
        t30005 t,
        t30004 g
    WHERE (
        i.t_drug_master_code = m.t_drug_master_code
    ) AND (
        m.t_trade_code = t.t_trade_code
    ) AND (
        t.t_gen_code = g.t_gen_code
    ) AND
        i.t_item_code = array1(3);

    SELECT
        m.t_drug_master_code
    INTO
        v_drug_master_code
    FROM
        t30008 i,
        t30006 m,
        t30005 t,
        t30004 g
    WHERE (
        i.t_drug_master_code = m.t_drug_master_code
    ) AND (
        m.t_trade_code = t.t_trade_code
    ) AND (
        t.t_gen_code = g.t_gen_code
    ) AND
        i.t_item_code = array1(3);

    SELECT
        m.t_strength
    INTO
        v_strength
    FROM
        t30008 i,
        t30006 m,
        t30005 t,
        t30004 g
    WHERE (
        i.t_drug_master_code = m.t_drug_master_code
    ) AND (
        m.t_trade_code = t.t_trade_code
    ) AND (
        t.t_gen_code = g.t_gen_code
    ) AND
        i.t_item_code = array1(3);

    SELECT
        m.t_drug_form_code
    INTO
        v_drug_form_code
    FROM
        t30008 i,
        t30006 m,
        t30005 t,
        t30004 g
    WHERE (
        i.t_drug_master_code = m.t_drug_master_code
    ) AND (
        m.t_trade_code = t.t_trade_code
    ) AND (
        t.t_gen_code = g.t_gen_code
    ) AND
        i.t_item_code = array1(3);

    SELECT
        m.t_route_code
    INTO
        v_route_code
    FROM
        t30008 i,
        t30006 m,
        t30005 t,
        t30004 g
    WHERE (
        i.t_drug_master_code = m.t_drug_master_code
    ) AND (
        m.t_trade_code = t.t_trade_code
    ) AND (
        t.t_gen_code = g.t_gen_code
    ) AND
        i.t_item_code = array1(3);

    SELECT
        NVL(m.t_moh_cost,0)
    INTO
        v_moh_cost
    FROM
        t30008 i,
        t30006 m,
        t30005 t,
        t30004 g
    WHERE (
        i.t_drug_master_code = m.t_drug_master_code
    ) AND (
        m.t_trade_code = t.t_trade_code
    ) AND (
        t.t_gen_code = g.t_gen_code
    ) AND
        i.t_item_code = array1(3);

    SELECT
        NVL(m.t_moh_price,0)
    INTO
        v_moh_price
    FROM
        t30008 i,
        t30006 m,
        t30005 t,
        t30004 g
    WHERE (
        i.t_drug_master_code = m.t_drug_master_code
    ) AND (
        m.t_trade_code = t.t_trade_code
    ) AND (
        t.t_gen_code = g.t_gen_code
    ) AND
        i.t_item_code = array1(3);
    IF array1(2)='2' THEN 
        p_com_product:=(v_lang2_name||'|'||v_moh_price||'|'||array1(3));
    ELSE
         p_com_product:=(v_turkey_name||'|'||v_moh_price||'|'||array1(3));
    END IF;
    --dbms_output.put_line(v_lang2_name||' Moh Cost: '||v_moh_cost);
    --dbms_output.put_line('-------------Compare Difference Cost------------');

    FOR x IN (
        SELECT
            trim(ltrim(rtrim(t.t_gen_code))) gen_code,
            trim(ltrim(rtrim(t.t_trade_code )))trade_code,
            trim(ltrim(rtrim(m.t_drug_master_code))) master_code,
            trim(ltrim(rtrim(i.t_item_code))) item_code,
            trim(ltrim(rtrim(i.t_lang2_name))) item_name,
            nvl(trim(ltrim(rtrim(i.t_lang1_name))),'N/A') item_name_turkey,
            trim(ltrim(rtrim(nvl(m.t_moh_price,0)))) moh_price,
            trim(ltrim(rtrim(nvl(v_moh_price,0) - nvl(m.t_moh_price,0)))) difference_cost
        FROM
            t30005 t,
            t30006 m,
            t30008 i
        WHERE
            m.t_drug_master_code = i.t_drug_master_code
        AND
            t.t_trade_code = m.t_trade_code
        AND
            t.t_gen_code = v_gen_code
        AND m.t_drug_master_code<>v_drug_master_code
        AND
            m.t_strength = v_strength
        AND
            m.t_drug_form_code = v_drug_form_code
        AND
            m.t_route_code = v_route_code
            ORDER BY difference_cost DESC 
    ) LOOP
        if array1(2)='2' then 
             v_result:=(x.item_name||'|'||x.moh_price||'|'||v_moh_price||'|'||x.difference_cost||'|'||X.ITEM_CODE);
        else
             v_result:=(x.item_name_turkey||'|'||x.moh_price||'|'||v_moh_price||'|'||x.difference_cost||'|'||X.ITEM_CODE);
        end if;
             cnt:=cnt+1;
             c_value.extend;
             c_value(cnt):=v_result;
    END LOOP;
    if v_result is not null then
        OPEN p_value FOR select * from table(cast (c_value  as bulk_data));
    else
       OPEN p_value FOR select 'No Data Found!' from dual;
    end if;
    exception when others then
        OPEN p_value FOR select 'No Data Found!' from dual;

END;
/*
set serveroutput on;
declare
    com_prod_cursor SYS_REFCURSOR;
    v_product_info varchar2(200);
    v_com_product varchar2(1000);
begin
    get_com_price_proc (
        p_data_set  =>'1-1-506987',
        p_com_product =>v_product_info,
        p_value =>com_prod_cursor
    );
    dbms_output.put_line(v_product_info);
    dbms_output.put_line('-------------------------------');
    LOOP
        FETCH com_prod_cursor INTO v_com_product;
        EXIT WHEN com_prod_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_com_product);
    END LOOP;
    CLOSE com_prod_cursor;
end;
*/
/* Result */
/*
XPA ORAL TABLET 500mg|1.2|506987
-------------------------------
FAST ORAL TABLET 500mg|0|1.2|1.2|508629
RENOVA ORAL TABLET 500mg|0|1.2|1.2|510159
TAMEN ORAL TABLET 500mg|1.8|1.2|-.6|506560
PARAPYROL ORAL TABLET 500mg|1.5|1.2|-.3|501441
ZERIN ORAL TABLET 500mg|1.5|1.2|-.3|508627


PL/SQL procedure successfully completed.



