/* Prohibited_Athlet_Item_List_Function */
create or replace FUNCTION GET_PHBT_ATHLET_ITEM_LIST_FN RETURN SYS_REFCURSOR AS
        P_VALUE SYS_REFCURSOR;
BEGIN
    OPEN P_VALUE FOR
    select trim(ltrim(rtrim(c.t_lang2_name)))phbt_cat_desc,trim(ltrim(rtrim(g.t_lang2_name)))Gen_desc,
    trim(ltrim(rtrim(p.t_warning_desc2)))warning_desc,trim(ltrim(rtrim(g.t_gen_code)))||''||trim(ltrim(rtrim(p.t_phbt_cat_code))) phbt_cat_code
    from t30004 g,t30318 p,t30317 c
    where g.t_gen_code=p.t_gen_code
    and c.t_phbt_cat_code=p.t_phbt_cat_code
    and p.t_phbt_cat_code='01';
    RETURN P_VALUE;

exception when no_data_found then
    OPEN P_VALUE FOR SELECT 'No Data Found!' from dual;
    RETURN P_VALUE;
END;
/*
select get_phbt_athlet_item_list_fn from dual;
*/
/* Result */
/*
select get_phbt_athlet_item_list_fn from dual;
*/
/*
{<PHBT_CAT_DESC=Athlete,GEN_DESC=BETAXOLOL,WARNING_DESC=null,PHBT_CAT_CODE=213501>,<PHBT_CAT_DESC=Athlete,GEN_DESC=PETHIDINE HCL,WARNING_DESC=null,PHBT_CAT_CODE=179501>,<PHBT_CAT_DESC=Athlete,GEN_DESC=ACEBUTOLOL,WARNING_DESC=null,PHBT_CAT_CODE=100201>,<PHBT_CAT_DESC=Athlete,GEN_DESC=BISOPROLOL,WARNING_DESC=null,PHBT_CAT_CODE=111801>,<PHBT_CAT_DESC=Athlete,GEN_DESC=CARVEDILOL,WARNING_DESC=null,PHBT_CAT_CODE=117401>,<PHBT_CAT_DESC=Athlete,GEN_DESC=EPOETIN ALFA,WARNING_DESC=null,PHBT_CAT_CODE=136601>,<PHBT_CAT_DESC=Athlete,GEN_DESC=MORPHINE SULPHATE,WARNING_DESC=null,PHBT_CAT_CODE=168601>,<PHBT_CAT_DESC=Athlete,GEN_DESC=ESMOLOL,WARNING_DESC=null,PHBT_CAT_CODE=342301>,<PHBT_CAT_DESC=Athlete,GEN_DESC=AMPHETAMINE,WARNING_DESC=null,PHBT_CAT_CODE=245601>,<PHBT_CAT_DESC=Athlete,GEN_DESC=DANAZOL,WARNING_DESC=null,PHBT_CAT_CODE=345401>,<PHBT_CAT_DESC=Athlete,GEN_DESC=LETROZOLE,WARNING_DESC=null,PHBT_CAT_CODE=323101>,<PHBT_CAT_DESC=Athlete,GEN_DESC=DARBEPOETIN ALFA,WARNING_DESC=null,PHBT_CAT_CODE=353401>,<PHBT_CAT_DESC=Athlete,GEN_DESC=MORPHINE,WARNING_DESC=null,PHBT_CAT_CODE=299801>,<PHBT_CAT_DESC=Athlete,GEN_DESC=NANDROLONE DECANOATE,WARNING_DESC=null,PHBT_CAT_CODE=310901>,}
*/
