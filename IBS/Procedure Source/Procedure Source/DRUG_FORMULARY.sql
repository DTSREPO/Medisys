/* Drug Formulary */
create or replace procedure get_df_proc (p_data_set varchar2, p_type out varchar2, p_lang out varchar2, p_value OUT SYS_REFCURSOR) as
    v1 varchar2(100):=p_data_set;
    type firstarray IS VARRAY(50) OF VARCHAR2(30000); 
    array1 firstarray:=firstarray();
    type secondarray IS VARRAY(50) OF VARCHAR2(30000); 
    array2 secondarray:=secondarray();
    c_value bulk_data:=bulk_data();
    pm_gen_set varchar2(100);
    total number:=0;
    total2 number:=0;
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
            FOR c in (SELECT  A.T_FORMULA_NOTES FM_NOTES, c.T_LANG2_NAME FORMU_DESC, B.T_LANG2_NAME GEN_DESC, A.T_GEN_CODE, A.T_FORMULA_CODE
                FROM T30026 A, T30004 B ,T30027 C WHERE A.T_GEN_CODE=B.T_GEN_CODE and a.t_formula_code=c.t_frmlry_code
                AND A.T_GEN_CODE=ARRAY2(I) order by B.T_LANG2_NAME) loop
                v_result:=c.gen_desc||' | '||c.formu_desc||' | '||C.FM_NOTES ||' | '||c.T_GEN_CODE||c.T_FORMULA_CODE;
                total:=total+1;
                c_value.extend;
                c_value(total):=v_result;
            end loop;
        end loop;
        
        OPEN p_value FOR select * from table(cast (c_value  as bulk_data));
    else
       OPEN p_value FOR select 'No Data Found!' from dual;
    end if;
exception when others then
   OPEN p_value FOR select 'No Data Found!' from dual;
end;

/*
set serveroutput on;
declare
    df_cursor SYS_REFCURSOR;
    v_type varchar2(3);
    v_lang varchar2(3);
    l_rec varchar2(30000);
BEGIN
    GET_DF_PROC (
        p_data_set  =>'1-2-146016001828',           -- in parameter
        p_type      =>v_type,                       -- out parameter for type
        p_lang      =>v_lang,                       -- out parameter for language
        p_value     =>df_cursor                     -- generic set it will store in array then fetch by loop
    );
    
    DBMS_OUTPUT.PUT_LINE('Type : '||v_type);
    DBMS_OUTPUT.PUT_LINE('Lang : '||v_lang);

    LOOP
        FETCH df_cursor INTO l_rec;
        EXIT WHEN df_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(l_rec);
    END LOOP;
    CLOSE df_cursor;
    exception when OTHERS then
    DBMS_OUTPUT.PUT_LINE('-----'|| sqlerrm  || '-------');
END;
*/

/* Result

Type : 
Lang : 
Gentamicin|Piroxicam|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|SUSPECTED|PLASMA AMINOGLYCOSIDE CONCENTRATIONS MAY BE ELEVATED IN PREMATURE INFANTS.|14601828
Lithium Carbonate|Piroxicam|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|SUSPECTED|SERUM LITHIUM LEVELS MAY BE INCREASED, RESULTING IN AN INCREASE IN THE PHARMACOLOGIC AND TOXIC EFFECTS OF LITHIUM.|16001828
Lithium Carbonate|Guaifenesin|MODIRATE/MAJOR|DELAYED|MODIRATE/MAJOR|SUSPECTED|LITHIUM WITH IODIDES MAY ACT SYNERGISTICALLY TO MORE READILY PRODUCE HYPOTHYROIDISM.|16002290


PL/SQL procedure successfully completed.

Type : 
Lang : 
GENTAMICIN|Use|Treatment of susceptible bacterial infections, normally gram-negative organisms including Pseudomonas. Proteus, Serratia , and gram-positive Staphylococcus; treatment of bone infections, respiratory tract infections, skin and soft tissue infections, as well as abdominal and urinary tract infections, endocarditis, and septicemia; used topically to treat superficial infections of the skin or ophthalmic infections caused by susceptible bacteria; nebulized for suppressive therapy of cystic fibrosis (no Form B required.|14601001
GENTAMICIN|Usual Dose|lndividualization is critical because of the low therapeutic index 
Use of ideal body weight (IBW) for determining the mg/kg/dose appears to be more accurate than dosing on the basis of total body weight (TBW). In morbid obesity, dosage requirement may best be estimated using a dosing weight of IBW + 0.4 (TBW - IBW). Initial and periodic peak and trough plasma drug levels should be determined
particularly in critically ill patients with serious infections or in disease states known to significantly alter aminoglycoside pharmacokinetics (eg, cystic fibrosis, burns, or major surgery) Once daily dosing: Higher peak serum drug concentration to MIC ratios, demonstrated aminoglycoside postantibiotic effect, decreased renal cortex drug uptake, and improved cost-time efficiency are supportive reasons for the use of once daily dosing regimens for aminoglycosides Current research indicates these regimens to be as effective for non life-threatening infections, with no higher incidence of nephrotoxicity, than those requiring multiple daily doses. Doses are determined by calculating the entire day&#39;s dose via usual multiple dose calculation techniques and administering this quantity as a single dose. Doses are then adjusted to maintain mean serum concentrations above the MIC(s) of the causative organism(s) (Example: 4.0-4.5 mg/kg as a single dose; expected Cpmax: 
10-20
mcg/mL and Cpmin: &lt;1 mcg/mL). Further researth is needed for universal recommendation in all patient populations and gram-negative disease; exceptions may include those with known high clearance (eg, children, patients with cystic fibrosis, bacterial endocarditis, or bums who may require shorter dosage intervals) and patients with renal function impairment for whom longer than conventional dosage intervals are usually required. Neonates: 
l.M., I.V.: 0-4 weeks: &lt;1200 g: 2.5 mg/kg/dose every 18-24 hours. 1200-2000 g,-0-4 weeks: 2.5 mg/kg/dose every 12-18 hours. &gt;2000 g: 2.5 mg/kg/dose every 12 hours. Postnatal age &gt;7 days: 1200-2000 9: 2.5 mg/kg/dose every 8-12 hours. &#39;2000 g: 2.5 mg/kg/dose every 8 hours. lnfantsand Children &lt;5 years: l.M., IV.: 
2.5 mg/kg/dose every 8 hours Cystic fibrosis: 2.5 mg/kg/dose every 6 hours 
Children &gt;5 years: l.M., IV.: 1.5-2.5 mg/kg/dose every 8 hours. Some patients may require larger or more frequent doses (eg, every
6 hours) if serum levels document the need (ie, cystic fibrosis or febrile granulocytopenic patients). Intrathecal: &gt;3 months: 1-2 mg/day. Adults: 
l.M., IV.: Severe life-threatening infections: 2-2.5 mg/kg/dose. Urinary tract infections: 1.5 mg/kg/dose. Synergy (for grarTi-positive infections): 1 mg/kg/dose 
Children and Adults: Intrathecal: 4-8 mg/day. Ophthalmic: Ontment: Instill 1/2&#39; (1.25 cm) 2-3 times/dayto every 3-4 hours. Solution: Instill 1-2 drops every 2-4 hours, up to 2 drops every hour for severe infections. Topical: Apply 3-4 times/day to affected area. Nebulization: doses vary; 20-80 mg 2 times/day have been used in clinical trials. 

|14601016
GENTAMICIN|Warning / Precautions|Not intended for long-term therapy due to toxic hazards associated with extended administration; pre-existing renal insufficiency, vestibular or cochlear impairment myasthenia gravis, hypocalcemia conditions- -which- depress neuromuscular transmission. Par nteral
aminoglycosides have been associated with significant nephrotoxicity or ototoxicity; the ototoxicity may be directly proportional to the amount of drug given and the duration of treatment; tinnitus or vertigo are indications of vestibular injury and impending hearing loss; renal damage is usually reversible.|14601017
GENTAMICIN|Side Effect|No Side Effect|14601005
GENTAMICIN|Patient Information|Report any dizziness or sensations of ringing or fullness in ears; do not touch ophthalmics to eye; use no other eye drops within 5-10 minutes of instilling ophthalmic|14601006
GENTAMICIN|Route of Administration|Oral|14601022
GENTAMICIN|Mechanism of Action|Interferes with bacterial protein synthesis by binding to 30S and 50S ribosomal subunits resulting- in a defective bacterial cell membrane.|14601002
LITHIUM CARBONATE|Use|LITHIUM is a monovalent cation with antimanic, antipsychotic, and. antidepressant activity. LITHIUM  is effective In the treatment of acute manic and hypomanic
episodes and in the prophylaxis of recurrent mania in Bipolar Types I and II affective disorder. Additional indications for LITHIUM include augmentation for acute treatment of major depressive disorder, prevention of recurrent major depression, empirical treatment of leukopenias, and the treatment of cluster headaches.|16001001
LITHIUM CARBONATE|Warning / Precautions|Lithium toxicity is closely related to serum lithium levels but can also occur at doses dose to therapeutic levels. At levels less than 1.5 milliosmoles/liter (mmol/L) (milliequivalents/liter (mEq/L)), nausea vomiting; diarrhea, polyuria polydipsia; tremor, weight gain, leukocytosis, thrombocytosis, hypercalcemia, and hyperkalemia have been reported: At levels l.5 to 2 mmol/L(mEq/L), more. Severe GI  effects And neurotoxic effects (drowsiness, tremors; hypertonicity; slurred speech) have occurred. At levels greater than 2 mmol/L (mEq/L); cardiovascular effects (arrhythmias AV block bradycardia, myocarditis),
convulsions, coma, and death have resulted. Chronic use adverse effects. include hypothyroidism and, less frequently, renal tubular necrosis.|16001017
LITHIUM CARBONATE|Usual Dose|In acute mania, 1800 milligrams daily in divided doses usually produces an optimal patient response. Maintenance doses range from 900 milligrams to 1200 milligrams daily in divided doses. Dose reductions are required in the elderly and. in patients with renal dysfunction. 
|16001016
PIROXICAM|Use|Management of inflammatory disorders; symptomatic treatment of acute and chronic rheumatoid arthritis. osteoarthritis,and ankylosing spndylitis; also used to treat sunburn.|18281001
PIROXICAM|Side Effect|Like naproxen|18281005
PIROXICAM|Pharmacokinetics|Onset of analgesia: oral: 1 hour - Pb: 99%. Peak effect: 3-5 hours - Metab: liver, t? : 45-50 hours - Elimination: unchanged (5%)Metabolites.In urine feces.|18281014
PIROXICAM|Pregnancy|Category B|18281007
PIROXICAM|Contra-Indications|Like
naptoxen.|18281011
PIROXICAM|Mechanism of Action|Inhibits prostaglandin synthesis, acts on the hypothalamus heat-regulating center to reduce fever, blocks prostaglandin synthetase action which prevents formation of the platelet aggregating substance thromboxane A2; decreases pain receptor Sensitivity. Other proposed mechanisms of action for slicylate anti-inflammatory action are lysosomal stabilization, kinin and leukotriene production, alteration of themotactic factor and inhibition of neutrophil activation. This latter mechanism may be the most
significant pharmacologic action to reduce inflammation.|18281002
PIROXICAM|Patient Information|Take with food milk to reduce Gl irritation.May cause drowsiness or dizziness, photosensitivity.|18281006
PIROXICAM|Usual Dose|Oral: Children 0.2-0.3 mg/kg/day once daily; maximum dose: 15 mg/day 
Adults: 10-20 mg/day once daily; although associated with increase in 01 adverse effects, doses >20 mg/day have been used (ie, 30-40
mg/day). 
|18281016
PIROXICAM|Warning / Precautions|Use with caution in patients with impaired cardiac function, hypertension, impaired renal function, GI disease (bleeding or ulcers) and patients receiving anticoagulants; elderly have Increased risk for adverse reactions to NSAIOs|18281017


PL/SQL procedure successfully completed.
*/

/* Wrong Parameter 
Type : 
Lang : 
No Data Found!


PL/SQL procedure successfully completed.
*/