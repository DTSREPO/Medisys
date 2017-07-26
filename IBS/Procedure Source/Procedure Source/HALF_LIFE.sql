/* Half_life */
create or replace PROCEDURE get_drug_half_life_proc (
    p_item_code   VARCHAR2,
    p_product_desc out varchar2,
    p_value out sys_refcursor
) IS
    c_value bulk_data:=bulk_data();
    v_result VARCHAR2(1000);
    cnt number:=0;
    v_gen_code           VARCHAR2(10);
    v_drug_master_code   VARCHAR2(10);
    v_lang2_name         VARCHAR2(200);
    v_item_code          varchar2(8);
BEGIN

    /*
    select m.T_drug_half_life Half_life,i.t_lang2_name Product_Desc,i.t_item_code Product_code,t.t_gen_code
    from t30006 m,t30008 i, t30005 t
    where m.t_drug_master_code=i.t_drug_master_code
    and t.t_trade_code=m.t_trade_code
    and t.t_gen_code='1007';
    */

    FOR x IN (select nvl(m.T_drug_half_life,'n/a') half_life, i.t_lang2_name item_desc ,i.t_item_code item_code
             from t30006 m,t30008 i where m.t_drug_master_code=i.t_drug_master_code and i.t_item_code=p_item_code) LOOP

             v_result:=(x.item_desc||'|'||x.half_life||'|'||x.item_code);
             cnt:=cnt+1;
             c_value.extend;
             c_value(cnt):=v_result;
             p_product_desc:=x.item_desc;
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
    half_life_cursor SYS_REFCURSOR;
    v_product_desc varchar2(200);
    v_lang varchar2(3);
    l_rec varchar2(30000);
BEGIN
    get_drug_half_life_proc (
        p_item_code         =>'505360',
        p_product_desc      =>v_product_desc,
        p_value             =>half_life_cursor
    );

    dbms_output.put_line('Target Product : '||v_product_desc);

    LOOP
        FETCH half_life_cursor INTO l_rec;
        EXIT WHEN half_life_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE half_life_cursor;
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
Target Product : CAL ORAL TABLET 500 mg(Elemental Calcium)
CAL ORAL TABLET 500 mg(Elemental Calcium)|n/a|505360


PL/SQL procedure successfully completed.
*/
/* Wrong Parameter Value */
/*
set serveroutput on;
declare
    half_life_cursor SYS_REFCURSOR;
    v_product_desc varchar2(200);
    v_lang varchar2(3);
    l_rec varchar2(30000);
BEGIN
    get_drug_half_life_proc (
        p_item_code         =>'50536',
        p_product_desc      =>v_product_desc,
        p_value             =>half_life_cursor
    );

    dbms_output.put_line('Target Product : '||v_product_desc);

    LOOP
        FETCH half_life_cursor INTO l_rec;
        EXIT WHEN half_life_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE half_life_cursor;
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
Target Product : 
No Data Found!


PL/SQL procedure successfully completed.
*/
