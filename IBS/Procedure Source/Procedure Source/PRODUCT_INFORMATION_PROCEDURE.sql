/* Product_Information_Procedure */
create or replace procedure get_product_info_proc(
                                                    p_item_code in varchar2,
                                                    p_gen_desc out varchar2,
                                                    p_prod_info out varchar2, 
                                                    p_gen_use out varchar2,
                                                    p_usual_dose out varchar2,
                                                    p_lab_side_effect out varchar2,
                                                    p_symptom out varchar2,
                                                    p_fdi_value out sys_refcursor,
                                                    p_ddi_value out sys_refcursor,
                                                    p_dis_drug_value out sys_refcursor
                                                )
as
    c_value1 bulk_data:=bulk_data();
    c_value2 bulk_data:=bulk_data();
    c_value3 bulk_data:=bulk_data();
    cnt number:=0;
    v_gen_code varchar2(10);
    v_product_info varchar2(3000);
    v_fdi_desc varchar2(6000);
    v_ddi_desc varchar2(6000);
    v_dis_drug_desc varchar2(6000);
begin

    /* Product Information */
    for i in (select ITEM_CODE, NVL(PRODUCT_DESC,'N/A') PRODUCT_DESC, NVL(FORM_DESC,'N/A') FORM_DESC, GEN_CODE, NVL(GEN_DESC,'N/A') GEN_DESC, NVL(SGK_CODE,'N/A') SGK_CODE,
                NVL(MOH_PRICE,'0') MOH_PRICE, NVL(SUT_PRICE,'0') SUT_PRICE, NVL(PREGNENCY_CAT,'N/A') PREGNENCY_CAT, NVL(PREGNENCY_DESC,'N/A') PREGNENCY_DESC, NVL(STORAGE_CONDITION,'N/A') STORAGE_CONDITION, 
                NVL(WARNING_DESC,'N/A')WARNING_DESC, NVL(MANUF_DESC,'N/A')MANUF_DESC, NVL(SUT_DESC,'N/A') SUT_DESC,NVL(PAY_MODE_DESC,'N/A') PAY_MODE_DESC, NVL(CONDITION_DESC,'N/A') CONDITION_DESC, 
                NVL(CIRCUM_DESC,'N/A') CIRCUM_DESC, NVL(ATC_CODE,'N/A') ATC_CODE, NVL(ATC_DESC1,'N/A') ATC_DESC1, NVL(ATC_DESC2,'N/A') ATC_DESC2, NVL(COUNTRY_DESC,'N/A') COUNTRY_DESC  from v30001 where item_code=p_item_code
                order by item_code) loop

        p_prod_info:=I.PRODUCT_DESC||'|'||I.SGK_CODE||'|'||I.MOH_PRICE||'|'||I.SUT_PRICE||'|'||I.PREGNENCY_CAT||'|'||
                     i.PREGNENCY_DESC||'|'||I.STORAGE_CONDITION||'|'||I.WARNING_DESC||'|'||I.MANUF_DESC||'|'||I.SUT_DESC||'|'||I.PAY_MODE_DESC||'|'||
                     I.CONDITION_DESC||'|'||I.CIRCUM_DESC||'|'||i.ATC_CODE||'|'||i.ATC_DESC1||'|'||i.ATC_DESC2||'|'||i.ITEM_CODE||'|'||i.COUNTRY_DESC;
        v_gen_code:=i.gen_code;
        p_gen_desc:=i.gen_desc||'|'||i.GEN_CODE;
    end loop;
        --dbms_output.put_line('Generic : '||v_gen_code);

    /* Generic Use */
    begin
        select T_FORMULA_NOTES||'|'||T_FORMULA_CODE into p_gen_use from t30026 where T_FORMULA_CODE='1001' AND T_GEN_CODE=V_GEN_CODE;
    exception when no_data_found then
        p_gen_use:='No Data Found!';
    end;

    /* Generic Usual Dose */
    begin
        select T_FORMULA_NOTES||'|'||T_FORMULA_CODE into p_usual_dose from t30026 where T_FORMULA_CODE='1016' AND T_GEN_CODE=V_GEN_CODE;
    exception when no_data_found then
        p_usual_dose:='No Data Found!';
    end;

    /* Generic Effect of Lab Result */
    begin
        select T_FORMULA_NOTES||'|'||T_FORMULA_CODE into p_lab_side_effect from t30026 where T_FORMULA_CODE='1023' AND T_GEN_CODE=V_GEN_CODE;
    exception when no_data_found then
        p_lab_side_effect:='No Data Found!';
    end;

    /* Symptom */
    begin
        select T_FORMULA_NOTES||'|'||T_FORMULA_CODE into p_Symptom from t30026 where T_FORMULA_CODE='1024' AND T_GEN_CODE=V_GEN_CODE;
    exception when no_data_found then
        p_Symptom:='No Data Found!';
    end;

    /* Food Drug Intraction */
    begin
    FOR J IN (SELECT TRIM(LTRIM(RTRIM(C.T_LANG2_NAME))) GEN_DESC, TRIM(LTRIM(RTRIM(a.T_GEN_CODE))) gen_code, 
    TRIM(LTRIM(RTRIM(a.T_FOOD_CODE))) food_code, TRIM(LTRIM(RTRIM(B.T_FOOD_DESC2))) FOOD_DESC, TRIM(LTRIM(RTRIM(A.T_FOOD_EFFECT))) FOOD_EFFECT
              FROM T30303 A, T30302 B, T30004 C
              WHERE A.T_GEN_CODE=C.T_GEN_CODE 
              AND A.T_FOOD_CODE=B.T_FOOD_CODE 
              AND A.t_gen_code=v_gen_code
              order by a.t_gen_code) LOOP
        v_fdi_desc:=J.GEN_DESC||'|'||J.FOOD_DESC||'|'||J.FOOD_EFFECT||'|'||J.gen_code||J.food_code;

        cnt:=cnt+1;
        c_value1.extend;
        c_value1(cnt):=v_fdi_desc;
    END LOOP;

    if v_fdi_desc is not null then
        OPEN p_fdi_value FOR select * from table(cast (c_value1  as bulk_data));
    else
        OPEN p_fdi_value FOR select 'No Data Found!' from dual;
    end if;
    exception when others then
        OPEN p_fdi_value FOR select 'No Data Found!' from dual;
    end;

    /* Drug Drug Intraction */
    cnt:=0;
    begin
        FOR X IN (
            SELECT GEN_DESC FROM (
                SELECT distinct
                    B.GEN_DESC ||'|'||
                    C.T_LANG2_NAME ||'|'||--SIGNIF_DESC,
                    D.T_LANG2_NAME ||'|'||--ONSET_DESC,
                    E.T_LANG2_NAME ||'|'||--SEVERITY_DESC,
                    F.T_LANG2_NAME ||'|'||--DOC_DESC,
                    A.t_ddi_comm  ||'|'|| --EFFECT
                    A.T_GEN_GEN_DDI GEN_DESC
                FROM
                    T30041 A, (SELECT INITCAP(T_LANG2_NAME) GEN_DESC, T_GEN_CODE FROM T30004 ) B,
                    T30032 C, T30030 D, T30031 E, T30029 F
                WHERE
                    A.T_SIGNIF_CODE = C.T_SIGNIF_CODE(+) AND
                    A.T_ONSET_CODE = D.T_ONSET_CODE(+) AND
                    A.T_SEVERITY_CODE = E.T_SEVERITY_CODE(+) AND
                    A.T_DOCUM_CODE = F.T_DOCUM_CODE(+) AND
                    A.T_GEN_GEN_DDI = B.T_GEN_CODE AND A.T_GEN_CODE = V_GEN_CODE
                UNION
                SELECT distinct
                    B.GEN_DESC ||'|'||
                    C.T_LANG2_NAME ||'|'||--SIGNIF_DESC,
                    D.T_LANG2_NAME ||'|'||--ONSET_DESC,
                    E.T_LANG2_NAME ||'|'||--SEVERITY_DESC,
                    F.T_LANG2_NAME ||'|'||--DOC_DESC,
                    A.t_ddi_comm ||'|'|| --EFFECT
                    A.T_GEN_CODE GEN_DESC
                FROM
                    T30041 A, (SELECT INITCAP(T_LANG2_NAME) GEN_DESC, T_GEN_CODE FROM T30004 ) B,
                    T30032 C, T30030 D, T30031 E, T30029 F
                WHERE
                    A.T_SIGNIF_CODE = C.T_SIGNIF_CODE(+) AND
                    A.T_ONSET_CODE = D.T_ONSET_CODE(+) AND
                    A.T_SEVERITY_CODE = E.T_SEVERITY_CODE(+) AND
                    A.T_DOCUM_CODE = F.T_DOCUM_CODE(+) AND
                    A.T_GEN_CODE = B.T_GEN_CODE AND A.T_GEN_GEN_DDI = V_GEN_CODE
                )
                ORDER BY GEN_DESC
            ) LOOP
            v_ddi_desc:=x.gen_desc;

            cnt:=cnt+1;
            c_value2.extend;
            c_value2(cnt):=v_ddi_desc;
        END LOOP;
        if v_ddi_desc is not null then
            OPEN p_ddi_value FOR select * from table(cast (c_value2  as bulk_data));
        else
            OPEN p_ddi_value FOR select 'No Data Found!' from dual;
        end if;
        exception when others then
            OPEN p_ddi_value FOR select 'No Data Found!' from dual;
    end;

    /* Diseases interaction     */
    cnt:=0;
    begin
        FOR z IN (SELECT A.T_ICD10_CODE, INITCAP(B.T_ICD10_LONG_DESC) ICD10_DESC, A.T_DI_EFFECT FROM T30310 A, T06301 B WHERE (B.T_ICD10_MAIN_CODE||''||B.T_ICD10_SUB_CODE)=
             A.T_ICD10_CODE AND A.T_GEN_CODE=V_GEN_CODE
             order by a.t_icd10_code) LOOP
             v_dis_drug_desc:=z.ICD10_DESC||'|'||z.T_DI_EFFECT||'|'||z.T_ICD10_CODE;

            cnt:=cnt+1;
            c_value3.extend;
            c_value3(cnt):=v_dis_drug_desc;
    END LOOP;
    if v_dis_drug_desc is not null then
        OPEN p_dis_drug_value FOR select * from table(cast (c_value3  as bulk_data));
    else
        OPEN p_dis_drug_value FOR select 'No Data Found!' from dual;
    end if;
    exception when others then
        OPEN p_dis_drug_value FOR select 'No Data Found!' from dual;
    end;

end;

/*
set serveroutput on;
declare
    fdi_cursor SYS_REFCURSOR;
    ddi_cursor SYS_REFCURSOR;
    dis_drug_cursor SYS_REFCURSOR;
    v_gen_desc varchar2(200);
    v_prod_info varchar2(30000);
    v_gen_use varchar2(30000);
    v_usual_dose varchar2(30000);
    v_lab_side_effect varchar2(30000);
    v_symptom varchar2(30000);
    v_fdi_desc varchar2(30000);
    v_ddi_desc varchar2(30000);
    v_dis_drug_desc varchar2(30000);
BEGIN
get_product_info_proc(
                    p_item_code       =>'508078',
                    p_gen_desc        =>v_gen_desc,
                    p_prod_info       =>v_prod_info, 
                    p_gen_use         =>v_gen_use,
                    p_usual_dose      =>v_usual_dose,
                    p_lab_side_effect =>v_lab_side_effect,
                    p_symptom         =>v_symptom,
                    p_fdi_value       =>fdi_cursor,
                    p_ddi_value       =>ddi_cursor,
                    p_dis_drug_value  =>dis_drug_cursor
                );

    
    DBMS_OUTPUT.PUT_LINE('-----Product Information-------');  
    dbms_output.put_line('Product : '||v_prod_info);
    
    DBMS_OUTPUT.PUT_LINE('-----Drug Formulary-------');
    dbms_output.put_line('Generic Use : '||v_gen_use);
    dbms_output.put_line('Usual Dose : '||v_usual_dose);
    dbms_output.put_line('Lab Side Effect : '||v_lab_side_effect);
    dbms_output.put_line('Symptom : '||v_symptom);
    
    DBMS_OUTPUT.PUT_LINE('-----Generic-------');  
    dbms_output.put_line('Generic : '||v_gen_desc);
    DBMS_OUTPUT.PUT_LINE('-----Drug Drug Interaction-------');
    LOOP
        FETCH ddi_cursor INTO v_ddi_desc;
        EXIT WHEN ddi_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_ddi_desc);
    END LOOP;
    CLOSE ddi_cursor;
    
    DBMS_OUTPUT.PUT_LINE('-----Food Interaction-------');
    LOOP
        FETCH fdi_cursor INTO v_fdi_desc;
        EXIT WHEN fdi_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_fdi_desc);
    END LOOP;
    CLOSE fdi_cursor;
    
    DBMS_OUTPUT.PUT_LINE('-----Diseases Interaction-------');
    LOOP
        FETCH dis_drug_cursor INTO v_dis_drug_desc;
        EXIT WHEN dis_drug_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_dis_drug_desc);
    END LOOP;
    CLOSE dis_drug_cursor;
    
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
-----Product Information-------
Product : A-FENAC ORAL TABLET 25mg|N/A|0|0|N/A|N/A|N/A|N/A|ACME LABORATORIES LTD|N/A|N/A|N/A|N/A|508078
-----Drug Formulary-------
Generic Use : Acute treatment of mild to moderate pain; acute and chronic treatment of rheumatoid arthritis, ankylosing spondylitis, and osteoarthritis used for juvenile rheumatoid arthritis, gout, dysmenorrhea|1001
Usual Dose : Oral: Analgesia: Starting dose: 25-50 mg 3 times/day, Rheumatoid arthritis: 150-200 mg/day in 2-4 divided doses (100 mg/day of sustained release product) Osteoarthritis: 100-150 mg/day in 2-3 divided doses (100-200 mg/day of sustained release product). Ankylosing spondylitis: 100-125 mg/day in 4-5 divided doses. l,M.: Postoperative pain: 75 mg once daily (twice daily in severe cases) for a maximum of 2 days. Renal colic: 75 mg then a further 75 mg after several hours if necessary. Rectal: 100 mg/day or twice daily.|1016
Lab Side Effect : No Data Found!
Symptom : No Data
Found!
-----Generic-------
Generic : DICLOFENAC SODIUM|1310
-----Drug Drug Interaction-------
Alendronate|MODIRATE/MINOR|DELAYED|MODIRATE/MAJOR|POSSIBLE|THE RISK OF GASTRIC ULCERATION MAY BE INCREASED.|1017
Amikacin Sulphate|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|SUSPECTED|PLASMA AMINOGLYCOSIDE CONCENTRATIONS MAY BE ELEVATED IN PREMATURE INFANTS.|1029
Anisindione|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|PROPABLE|NSAIDS MAY INCREASE BLEEDING RISK OF ORAL ANTICOAGULANTS. THE HYPOPROTHROMBINEMIC EFFECT OF ANTICOAGULANTS MAY BE INCREASED.|2461
Aspirin|MINOR|DELAYED|MODIRATE|POSSIBLE|PHARMACOLOGIC EFFECTS OF CERTAIN NSAIDS MAY BE DECREASED. THESE AGENTS ARE ALSO GASTRIC IRRITANTS.|2320
Cholestyramine|MODIRATE|DELAYED|MODIRATE|PROPABLE|THE PHARMACOLOGIC EFFECTS OF THE NSAID MAY BE DECREASED.|1220
Cyclosporine|MODIRATE/MINOR|RAPID|MODIRATE/MAJOR|POSSIBLE|THE NEPHROTOXICITY OF BOTH THE AGENTS MAY BE INCREASED.|1272
Dicumarol|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|PROPABLE|NSAIDS MAY
INCREASE BLEEDING RISK OF ORAL ANTICOAGULANTS. THE HYPOPROTHROMBINEMIC EFFECT OF ANTICOAGULANTS MAY BE INCREASED.|2437
Disodium Pamidronate|MODIRATE/MINOR|DELAYED|MODIRATE/MAJOR|POSSIBLE|THE RISK OF GASTRIC ULCERATION MAY BE INCREASED.|1336
Etidronate|MODIRATE/MINOR|DELAYED|MODIRATE/MAJOR|POSSIBLE|THE RISK OF GASTRIC ULCERATION MAY BE INCREASED.|2581
Gentamicin|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|SUSPECTED|PLASMA AMINOGLYCOSIDE CONCENTRATIONS MAY BE ELEVATED IN PREMATURE INFANTS.|1460
Inositol Niacinate|MODIRATE|DELAYED|MODIRATE|PROPABLE|THE PHARMACOLOGIC EFFECTS OF THE NSAID MAY BE DECREASED.|1260
Kanamycin Sulphate|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|SUSPECTED|PLASMA AMINOGLYCOSIDE CONCENTRATIONS MAY BE ELEVATED IN PREMATURE INFANTS.|1568
Lithium Carbonate|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|SUSPECTED|SERUM LITHIUM LEVELS MAY BE INCREASED, RESULTING IN AN INCREASE IN THE PHARMACOLOGIC AND TOXIC EFFECTS OF
LITHIUM.|1600
Methotrexate|MAJOR|DELAYED|MAJOR|SUSPECTED|METHOTREXATE (MTX) TOXICITY MAY BE INCREASED. THIS IS LESS LIKELY TO OCCUR WITH WEEKLY LOW-DOSE MTX REGIMENS FOE RHEUMATOID ARTHRITIS AND OTHER INFLAMMATORY DISEASES.|1654
Netilmicin Sulphate|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|SUSPECTED|PLASMA AMINOGLYCOSIDE CONCENTRATIONS MAY BE ELEVATED IN PREMATURE INFANTS.|1713
Probenecid|MINOR|DELAYED|MODIRATE|POSSIBLE|TOXICITY OF NSAIDS MAY BE ENHANCED.|2345
Rabiprazole|MODIRATE|DELAYED|MODIRATE|SUSPECTED|THE PHARMACOLOGIC EFFECTS OF DICLOFENAC MAY BE DECREASED.|1959
Risperidone|MODIRATE/MINOR|DELAYED|MODIRATE/MAJOR|POSSIBLE|THE RISK OF GASTRIC ULCERATION MAY BE INCREASED.|1897
Streptomycin|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|SUSPECTED|PLASMA AMINOGLYCOSIDE CONCENTRATIONS MAY BE ELEVATED IN PREMATURE INFANTS.|1957
Tiludronate|MODIRATE/MINOR|DELAYED|MODIRATE/MAJOR|POSSIBLE|THE RISK OF GASTRIC ULCERATION MAY BE
INCREASED.|2582
Triamterene|MODIRATE/MINOR|RAPID|MODIRATE/MAJOR|POSSIBLE|ACUTE RENAL FAILURE MAY OCCUR.|2533
Warfarin Sodium|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|PROPABLE|NSAIDS MAY INCREASE BLEEDING RISK OF ORAL ANTICOAGULANTS. THE HYPOPROTHROMBINEMIC EFFECT OF ANTICOAGULANTS MAY BE INCREASED.|2086
-----Food Interaction-------
DICLOFENAC SODIUM | Furanocoumarins/Grape fruits | Diclofenac is broken down by the liver and the by-products are excreted from the body by the kidneys. 
Furanocoumarin may decrease how quickly the liver breaks down diclofenac. According to Mayo Clinic, this can lead to the accumulation of the drug in the body which may develop diclofenac toxicity symptoms.
 | 13100003
-----Diseases Interaction-------
No Data Found!
*/
/* Worng Parameter Value */
/*
set serveroutput on;
declare
    fdi_cursor SYS_REFCURSOR;
    ddi_cursor SYS_REFCURSOR;
    dis_drug_cursor SYS_REFCURSOR;
    v_gen_desc varchar2(200);
    v_prod_info varchar2(30000);
    v_gen_use varchar2(30000);
    v_usual_dose varchar2(30000);
    v_lab_side_effect varchar2(30000);
    v_symptom varchar2(30000);
    v_fdi_desc varchar2(30000);
    v_ddi_desc varchar2(30000);
    v_dis_drug_desc varchar2(30000);
BEGIN
get_product_info_proc(
                    p_item_code       =>'508',
                    p_gen_desc        =>v_gen_desc,
                    p_prod_info       =>v_prod_info, 
                    p_gen_use         =>v_gen_use,
                    p_usual_dose      =>v_usual_dose,
                    p_lab_side_effect =>v_lab_side_effect,
                    p_symptom         =>v_symptom,
                    p_fdi_value       =>fdi_cursor,
                    p_ddi_value       =>ddi_cursor,
                    p_dis_drug_value  =>dis_drug_cursor
                );

    
    DBMS_OUTPUT.PUT_LINE('-----Product Information-------');  
    dbms_output.put_line('Product : '||v_prod_info);
    
    DBMS_OUTPUT.PUT_LINE('-----Drug Formulary-------');
    dbms_output.put_line('Generic Use : '||v_gen_use);
    dbms_output.put_line('Usual Dose : '||v_usual_dose);
    dbms_output.put_line('Lab Side Effect : '||v_lab_side_effect);
    dbms_output.put_line('Symptom : '||v_symptom);
    
    DBMS_OUTPUT.PUT_LINE('-----Generic-------');  
    dbms_output.put_line('Generic : '||v_gen_desc);
    DBMS_OUTPUT.PUT_LINE('-----Drug Drug Interaction-------');
    LOOP
        FETCH ddi_cursor INTO v_ddi_desc;
        EXIT WHEN ddi_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_ddi_desc);
    END LOOP;
    CLOSE ddi_cursor;
    
    DBMS_OUTPUT.PUT_LINE('-----Food Interaction-------');
    LOOP
        FETCH fdi_cursor INTO v_fdi_desc;
        EXIT WHEN fdi_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_fdi_desc);
    END LOOP;
    CLOSE fdi_cursor;
    
    DBMS_OUTPUT.PUT_LINE('-----Diseases Interaction-------');
    LOOP
        FETCH dis_drug_cursor INTO v_dis_drug_desc;
        EXIT WHEN dis_drug_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_dis_drug_desc);
    END LOOP;
    CLOSE dis_drug_cursor;
    
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/
/* Result */
/*
-----Product Information-------
Product : 
-----Drug Formulary-------
Generic Use : No Data Found!
Usual Dose : No Data Found!
Lab Side Effect : No Data Found!
Symptom : No Data Found!
-----Generic-------
Generic : 
-----Drug Drug Interaction-------
No Data Found!
-----Food Interaction-------
No Data Found!
-----Diseases Interaction-------
No Data Found!


PL/SQL procedure successfully completed.
*/



PL/SQL procedure successfully completed.
