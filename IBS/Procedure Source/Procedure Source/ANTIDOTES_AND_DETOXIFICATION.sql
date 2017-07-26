/* Antidotes_and_Detoxification Procedure */
create or replace PROCEDURE get_anti_detox_proc (P_GEN_CODE in varchar2, 
                                                    p_anti_detox OUT VARCHAR2)
AS
BEGIN
    FOR I IN (SELECT T30026.T_GEN_CODE, T30004.T_LANG2_NAME GEN_DESC, T30026.T_FORMULA_CODE, T_FORMULA_NOTES FROM T30026, T30004
            WHERE T30026.T_GEN_CODE=T30004.T_GEN_CODE AND T30026.T_FORMULA_CODE='1026' AND T30026.T_GEN_CODE=P_GEN_CODE) LOOP

            p_anti_detox:=I.GEN_DESC||'|'||I.T_FORMULA_NOTES||'|'||I.T_GEN_CODE||''||I.T_FORMULA_CODE;
    END LOOP;
    if p_anti_detox is null then 
    p_anti_detox:=('No Data Found!');
    end if;

    exception when no_data_found then 
    p_anti_detox:='No Data Found!';
END;
/*
declare
v_num varchar2(2000);
begin 
GET_ANTI_DETOX_PROC('1299',v_num);
dbms_output.put_line(v_num);
end;
*/
/* Result */
/*
DEXTROMETHORPHAN +PHENYLEPHRINE +CHORPHENIRAMINE|Dextromethorphan hydrobromide is a synthetic morphinan derivative which has a potent antitussive activity nearly equal to that of codeine, but has no . analgesic or, other central depressing action addictive properties or side-effects of codeine such as constipation Phenylepbrinee hydrochloride is a sympathomirnetic  amine .It .causes relaxation of the bronchial muscle.  At the same time it constricts the smaller vessels and reduces congestion'?nd sweIling of the mucous membraneof the respiratory tract. It has a remdrkabl? benefit in the presence of bronchoconstirction. Chlorpheniramine produces a central depressant effect upon the cough center. At the same time, it produces relaxation of the bronchial muscle and antagonizes the effects of histamine on the vascular tree in allergic conditions.|12991026


PL/SQL procedure successfully completed.
*/
/* Wrong Parameter Value */
/*
declare
v_num varchar2(2000);
begin 
GET_ANTI_DETOX_PROC('129',v_num);
dbms_output.put_line(v_num);
end;
*/
/* Result */
/*
No Data Found!


PL/SQL procedure successfully completed.
*/


