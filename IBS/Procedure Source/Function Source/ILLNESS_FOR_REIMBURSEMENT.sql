/* illness_for_reimbursement */
create or replace FUNCTION GET_ILLN_REIMB_FN RETURN SYS_REFCURSOR AS
/* illness for reimbersement */
P_VALUE SYS_REFCURSOR;
BEGIN
    OPEN P_VALUE FOR
    select b.T_ICD10_LONG_DESC ICD10_DESC, A.T_ICD10_CODE ICD_CODE
    from T30316 a, T06301 B
    where a.T_ICD10_CODE=(B.T_ICD10_MAIN_CODE||''||B.T_ICD10_SUB_CODE) and A.T_NOT_INS_SYSTEM_FLAG ='1';
    RETURN P_VALUE;
END;
/*
select get_illn_reimb_fn from dual;
*/
/* Result */
/*
{<ICD10_DESC=Car occupant injured in collision with heavy transport vehicle or bus, while boarding or alighting, other specified car [automobile],ICD_CODE=V4448>,}
*/