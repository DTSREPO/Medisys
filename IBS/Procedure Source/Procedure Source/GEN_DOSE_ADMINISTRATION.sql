/* Dose of Administration */
create or replace procedure get_gen_dose_proc (p_data_set varchar2, p_value OUT SYS_REFCURSOR) as
    v1 varchar2(100):=p_data_set;
    type firstarray IS VARRAY(50) OF VARCHAR2(30000); 
    array1 firstarray:=firstarray();
    type secondarray IS VARRAY(50) OF VARCHAR2(30000); 
    array2 secondarray:=secondarray();
    c_value bulk_data:=bulk_data();
    pm_gen_set varchar2(100);
    total number:=0;
    v_start NUMBER:=1;
    v_end number:=4;
    v_end_loop number;
    v_result varchar2(30000);
begin
    for i in (select regexp_substr(v1,'[^-]+', 1, level) as val from dual connect by regexp_substr(v1, '[^-]+', 1, level) is not null) loop
        total:=total+1;
        array1.extend;
        array1(total):=i.val;
    end loop;
    for i in array1.first..array1.last loop
       pm_gen_set:=array1(3);
    end loop;

    --p_type:=array1(1);
    --p_lang:=array1(2);

    v_end_loop:=length(pm_gen_set)/4;
    if mod(length(pm_gen_set),4)=0 then
        total:=0;
        FOR I IN 1..v_end_loop LOOP
            total:=total+1;
            array2.extend;
            array2(total):=SUBSTR(pm_gen_set,v_start,v_end);
            v_start:=v_start+4;
        end loop;
    end if;
    total:=0;
if array2.count>0 then
    for i in 1..array2.count loop
            FOR c in (select A.T_GEN_CODE GEN_CODE, B.T_LANG2_NAME GEN_DESC, A.T_FORMULA_CODE FRM_CODE, C.T_LANG2_NAME FORMULA_DESC, A.T_FORMULA_NOTES NOTES
                      from T30026 A, T30004 B, T30027 C
                      WHERE T_FORMULA_CODE='1016' AND A.T_FORMULA_CODE=C.T_FRMLRY_CODE AND A.T_GEN_CODE=B.T_GEN_CODE AND A.T_GEN_CODE=ARRAY2(I)
            ) loop
                v_result:=c.GEN_DESC||'|'||c.NOTES ||'|'||c.GEN_CODE||c.FRM_CODE;
                total:=total+1;
                c_value.extend;
                c_value(total):=v_result;
            end loop;
    end loop;
    if v_result is null then
        OPEN p_value FOR select 'No Data Found!' from dual;
    else
        OPEN p_value FOR select * from table(cast (c_value  as bulk_data));
    end if;

else
    OPEN p_value FOR select 'No Data Found!' from dual;
end if;
   exception when others then
    OPEN p_value FOR select 'No Data Found!' from dual;
end;

/*

set serveroutput on;
declare
    dose_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    v_gen_desc varchar2(20000);
BEGIN
    get_gen_dose_proc (
        p_data_set   =>'1-2-1460',      -- in parameter
        p_value      =>dose_cursor     -- generic set it will store in array then fetch by loop
    );
    LOOP
        FETCH dose_cursor INTO v_gen_desc;
        EXIT WHEN dose_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_gen_desc);
    END LOOP;
    CLOSE dose_cursor;
    
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;

*/

/* Result */
/*
GENTAMICIN|lndividualization is critical because of the low therapeutic index 
Use of ideal body weight (IBW) for determining the mg/kg/dose appears to be more accurate than dosing on the basis of total body weight (TBW). In morbid obesity, dosage requirement may best be estimated using a dosing weight of IBW + 0.4 (TBW - IBW). Initial and periodic peak and trough plasma drug levels should be determined particularly in critically ill patients with serious infections or in disease states known to significantly alter aminoglycoside pharmacokinetics (eg, cystic fibrosis, burns, or major surgery) Once daily dosing: Higher peak serum drug concentration to MIC ratios, demonstrated aminoglycoside postantibiotic effect, decreased renal cortex drug uptake, and improved cost-time efficiency are supportive reasons for the use of once daily dosing regimens for aminoglycosides Current research indicates these regimens to be as effective for non life-threatening infections, with no
higher incidence of nephrotoxicity, than those requiring multiple daily doses. Doses are determined by calculating the entire day&#39;s dose via usual multiple dose calculation techniques and administering this quantity as a single dose. Doses are then adjusted to maintain mean serum concentrations above the MIC(s) of the causative organism(s) (Example: 4.0-4.5 mg/kg as a single dose; expected Cpmax: 
10-20 mcg/mL and Cpmin: &lt;1 mcg/mL). Further researth is needed for universal recommendation in all patient populations and gram-negative disease; exceptions may include those with known high clearance (eg, children, patients with cystic fibrosis, bacterial endocarditis, or bums who may require shorter dosage intervals) and patients with renal function impairment for whom longer than conventional dosage intervals are usually required. Neonates: 
l.M., I.V.: 0-4 weeks: &lt;1200 g: 2.5 mg/kg/dose every 18-24 hours. 1200-2000 g,-0-4 weeks: 2.5 mg/kg/dose every 12-18 hours.
&gt;2000 g: 2.5 mg/kg/dose every 12 hours. Postnatal age &gt;7 days: 1200-2000 9: 2.5 mg/kg/dose every 8-12 hours. &#39;2000 g: 2.5 mg/kg/dose every 8 hours. lnfantsand Children &lt;5 years: l.M., IV.: 
2.5 mg/kg/dose every 8 hours Cystic fibrosis: 2.5 mg/kg/dose every 6 hours 
Children &gt;5 years: l.M., IV.: 1.5-2.5 mg/kg/dose every 8 hours. Some patients may require larger or more frequent doses (eg, every 6 hours) if serum levels document the need (ie, cystic fibrosis or febrile granulocytopenic patients). Intrathecal: &gt;3 months: 1-2 mg/day. Adults: 
l.M., IV.: Severe life-threatening infections: 2-2.5 mg/kg/dose. Urinary tract infections: 1.5 mg/kg/dose. Synergy (for grarTi-positive infections): 1 mg/kg/dose 
Children and Adults: Intrathecal: 4-8 mg/day. Ophthalmic: Ontment: Instill 1/2&#39; (1.25 cm) 2-3 times/dayto every 3-4 hours. Solution: Instill 1-2 drops every 2-4 hours, up to 2 drops every hour for severe infections. Topical: Apply 3-4 times/day to
affected area. Nebulization: doses vary; 20-80 mg 2 times/day have been used in clinical trials. 

|14601016


PL/SQL procedure successfully completed.
*/

/* Wrong Parameter VALUE*/
/*
declare
    dose_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    v_gen_desc varchar2(20000);
BEGIN
    get_gen_dose_proc (
        p_data_set   =>'1-2-146',      -- in parameter
        p_value      =>dose_cursor     -- generic set it will store in array then fetch by loop
    );
    LOOP
        FETCH dose_cursor INTO v_gen_desc;
        EXIT WHEN dose_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_gen_desc);
    END LOOP;
    CLOSE dose_cursor;
    
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/

/*Result*/

/*
No Data Found!


PL/SQL procedure successfully completed.
*/