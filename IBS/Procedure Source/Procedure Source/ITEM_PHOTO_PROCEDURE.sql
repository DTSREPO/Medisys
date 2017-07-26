/* Item_Photo_Procedure */
create or replace PROCEDURE GET_ITEM_PHOTO_PROC (p_item_code in varchar2, ITEM_CODE OUT VARCHAR2, ITEM_PHOTO OUT BLOB)
AS
V_ITEM_CODE VARCHAR2(8):=P_ITEM_CODE;
BEGIN
    SELECT
        t30008.t_item_code,
        t30305.t_item_image item_photo
    INTO ITEM_CODE, ITEM_PHOTO
    FROM
        t30305,
        t30008
    WHERE
        t30008.t_item_code=t30305.t_item_code (+)
        and t30008.t_item_code=V_ITEM_CODE;

    exception when no_data_found then
    NULL;
END;