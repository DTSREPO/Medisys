/* Calorie_Information */

create or replace PROCEDURE GET_ITEM_CALORIE_INFO_PROC (P_ITEM_CODE in varchar2,
                                                        P_CALORIE_INFO OUT VARCHAR2)
AS
BEGIN
    FOR I IN (select trim(ltrim(rtrim(i.t_lang2_name))) item_desc,trim(ltrim(rtrim(c.t_grm_amount))) grm_amount, trim(ltrim(rtrim(c.t_calorie_amount))) calorie_amount,trim(ltrim(rtrim(i.t_item_code)))item_code 
                from t30312 c, t30008 i where c.t_item_code=i.t_item_code and c.t_item_code=P_ITEM_CODE) LOOP
            P_CALORIE_INFO:=I.item_desc||'|'||I.grm_amount||'|'||I.calorie_amount||'|'||I.item_code;
    END LOOP;
    if p_calorie_info is null then 
    p_calorie_info:='No Data Found!';
    end if;
    exception when no_data_found then 
    p_calorie_info:=('No Data Found!');
END;
/*
declare
v_num varchar2(2000);
begin 
GET_ITEM_CALORIE_INFO_PROC('505360',v_num);
dbms_output.put_line(v_num);
end;
*/
/* Result */
/*
CAL ORAL TABLET 500 mg(Elemental Calcium)|130|200|505360


PL/SQL procedure successfully completed.
*/
/* Wrong Parameter Value */
/*
declare
v_num varchar2(2000);
begin 
GET_ITEM_CALORIE_INFO_PROC('50536',v_num);
dbms_output.put_line(v_num);
end;
*/
/* Result */
/*
No Data Found!


PL/SQL procedure successfully completed.
*/
