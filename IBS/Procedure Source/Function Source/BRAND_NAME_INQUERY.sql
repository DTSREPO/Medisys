/* Brand_Name_Inquery */
create or replace function get_brand_name_fn(p_item_code in VARCHAR2, p_bar_code in varchar2, p_sgk_code in varchar2) return sys_refcursor as
p_value sys_refcursor;
begin
    open p_value for
    select trim(ltrim(rtrim(i.t_lang2_name))) product_desc,trim(ltrim(rtrim(m.t_product_barcode))) barcode,
    trim(ltrim(rtrim(m.t_sgk_code))) Sgk_code,trim(ltrim(rtrim(i.t_item_code))) item_code
    from t30006 m,t30008 i
    where m.t_drug_master_code=i.t_drug_master_code
    and i.t_item_code=nvl(p_item_code,i.t_item_code)
    and m.t_product_barcode=nvl(p_bar_code,m.t_product_barcode)
    and m.t_sgk_code=nvl(p_sgk_code,m.t_sgk_code)
    and m.t_active_flag='1';
    return p_value;
exception when no_data_found then
    OPEN P_VALUE FOR SELECT 'No Data Found!' from dual;
    RETURN P_VALUE;
end;
/*
select get_brand_name_fn('','','') from dual;
*/
/* Result */
/*
{<PRODUCT_DESC=HEPATAMINE(R)   INJECTION 8 %,BARCODE=3005,SGK_CODE=9855,ITEM_CODE=502510>,<PRODUCT_DESC=JOHNSON'S BABY HAIR SHAMPOO 300 ML,BARCODE=2545,SGK_CODE=2568,ITEM_CODE=506567>,<PRODUCT_DESC=500mg ORAL TABLET 1,BARCODE=425,SGK_CODE=23,ITEM_CODE=507390>,<PRODUCT_DESC=665mg ORAL BEXICAP 02,BARCODE=89000,SGK_CODE=9000,ITEM_CODE=507322>,<PRODUCT_DESC=NAPA EXTEND 30mg DISPERSABLE Accuhaler(DPI) Z2,BARCODE=56000,SGK_CODE=234,ITEM_CODE=511629>,}
*/
/*
select get_brand_name_fn('507390','','') from dual;
*/
/* Result */
/*
{<PRODUCT_DESC=500mg ORAL TABLET 1,BARCODE=425,SGK_CODE=23,ITEM_CODE=507390>,}
*/
/*
select get_brand_name_fn('','425','') from dual;
*/
/* Result */
/*
{<PRODUCT_DESC=500mg ORAL TABLET 1,BARCODE=425,SGK_CODE=23,ITEM_CODE=507390>,}
*/
/*
select get_brand_name_fn('','','23') from dual;
*/
/* Result */
/*
{<PRODUCT_DESC=500mg ORAL TABLET 1,BARCODE=425,SGK_CODE=23,ITEM_CODE=507390>,}
*/


