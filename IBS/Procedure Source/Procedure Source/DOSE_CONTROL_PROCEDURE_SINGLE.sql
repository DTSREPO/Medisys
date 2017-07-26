/* Dose_Control_Procedure_Single */
create or replace PROCEDURE GET_GEN_DOSE_CONTROL_PROC (P_GEN_CODE in varchar2, 
                                                        P_DOSE_CONTROL OUT VARCHAR2)
AS
BEGIN
    FOR I IN (SELECT T30026.T_GEN_CODE, T30004.T_LANG2_NAME GEN_DESC, T30026.T_FORMULA_CODE, T_FORMULA_NOTES FROM T30026, T30004
            WHERE T30026.T_GEN_CODE=T30004.T_GEN_CODE AND T30026.T_FORMULA_CODE='1025' AND T30026.T_GEN_CODE=P_GEN_CODE) LOOP

            P_DOSE_CONTROL:=I.GEN_DESC||'|'||I.T_FORMULA_NOTES||'|'||I.T_GEN_CODE||''||I.T_FORMULA_CODE;
    END LOOP;
    if P_DOSE_CONTROL is null then
        P_DOSE_CONTROL:=('No Data Found');
    end if;
    exception when no_data_found then 
    P_DOSE_CONTROL:=('No Data Found');
END;
/*
declare
v_num varchar2(2000);
begin 
GET_GEN_DOSE_CONTROL_PROC('1299',v_num);
dbms_output.put_line(v_num);
end;
*/
/* Result */
/*
DEXTROMETHORPHAN +PHENYLEPHRINE +CHORPHENIRAMINE|Dose Control Test Information|12991025


PL/SQL procedure successfully completed.
*/
/* Wrong Parameter Value */
/*
declare
v_num varchar2(2000);
begin 
GET_GEN_DOSE_CONTROL_PROC('129',v_num);
dbms_output.put_line(v_num);
end;
*/
/* Result */
/*
No Data Found


PL/SQL procedure successfully completed.
*/
