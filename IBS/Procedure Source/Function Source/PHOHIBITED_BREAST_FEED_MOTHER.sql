/* Prohibited_Breast_feed_mother */
create or replace FUNCTION GET_PHBT_BFEED_ITEM_LIST_FN RETURN SYS_REFCURSOR AS
        P_VALUE SYS_REFCURSOR;
BEGIN
    OPEN P_VALUE FOR
    select trim(ltrim(rtrim(c.t_lang2_name)))phbt_cat_desc, trim(ltrim(rtrim(g.t_lang2_name)))Gen_desc, trim(ltrim(rtrim(g.t_lang2_name))) sp_warning_Desc,
    trim(ltrim(rtrim(p.t_warning_desc2)))warning_desc,trim(ltrim(rtrim(g.t_gen_code))) gen_code--||''||trim(ltrim(rtrim(w.t_warning_code))) sp_warning_code
    from t30004 g,t30318 p,t30317 c--,T30323 w
    where g.t_gen_code=p.t_gen_code
    and c.t_phbt_cat_code=p.t_phbt_cat_code
    --and g.t_warning_code=w.t_warning_code
    and p.t_phbt_cat_code='03';
    RETURN P_VALUE;

exception when no_data_found then
    OPEN P_VALUE FOR SELECT 'No Data Found!' from dual;
    RETURN P_VALUE;
END;
/*
select get_phbt_bfeed_item_list_fn from dual;
*/
/* Result */
/*
{<PHBT_CAT_DESC=.,GEN_DESC=ATENOLOL,SP_WARNING_DESC=ATENOLOL,WARNING_DESC=null,GEN_CODE=1070>,}
*/

