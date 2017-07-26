/* Reimbersement_Information */
create or replace procedure get_reimb_info_proc(
                                                    p_item_code in varchar2,
                                                    p_prod_info out varchar2
                                                )
as
begin

    /* Product Information */
    for i in (SELECT TRIM(LTRIM(RTRIM(I.T_ITEM_CODE))) ITEM_CODE,TRIM(LTRIM(RTRIM(I.T_LANG2_NAME))) PRODUCT_DESC,NVL(C.T_PRICE_INFO,0) PRICE_INFO,
              TRIM(LTRIM(RTRIM(C.T_CONDITION_DESC2))) CONDITION_DESC,C.T_START_DATE START_DATE,C.T_END_DATE END_DATE FROM T30008 I,T30313 C
              WHERE I.T_ITEM_CODE=C.T_ITEM_CODE AND C.T_ITEM_CODE=P_ITEM_CODE) loop
            p_prod_info:=(I.PRODUCT_DESC||'|'||I.PRICE_INFO||'|'||I.CONDITION_DESC||'|'||I.START_DATE||'|'||I.END_DATE||'|'||I.ITEM_CODE);
    end loop;

    if p_prod_info is null then
        p_prod_info:=('No Data Found');
    end if;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        p_prod_info:=('No Data Found');

	/*
declare
v_num varchar2(2000);
begin 
get_reimb_info_proc('502149',v_num);
dbms_output.put_line(v_num);
end;
*/
/*Result*/
/*
CEFTRIAXONE|INJECTION INJECTION 250 mg|.1|test english|01-APR-17|30-APR-17|502149


PL/SQL procedure successfully completed.	
*/
/* Wrong Parameter Value */
/*
declare
v_num varchar2(2000);
begin 
get_reimb_info_proc('505',v_num);
dbms_output.put_line(v_num);
end;
*/
/* Result */
/*
No Data Found


PL/SQL procedure successfully completed.
*/


