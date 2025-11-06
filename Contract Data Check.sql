SELECT RECORD_NO,
       BRANCH_CODE,
       CASE
           WHEN BRANCH_CODE IS NULL
           THEN
               'Branch Code is empty in Contract Data.'
           WHEN LENGTH (BRANCH_CODE) = 12
           THEN
               NULL
           ELSE
               'Branch Code length limit exceeded in Contract Data.'
       END
           AS COMMENT_BRANCH_CODE,
       MEMBERID,
       CASE
           WHEN MEMBERID IS NULL
           THEN
               'Brrower Code/Customer ID/Member ID is empty in Contract Data.'
           WHEN LENGTH (MEMBERID) > 20
           THEN
               'Brrower Code/Customer ID/Member ID  length limit exceeded in Contract Data.'
                  WHEN MEMBERID IN
                    (SELECT DISTINCT a.C_MEMBER
                       FROM (  SELECT C.MEMBERID     AS C_MEMBER,
                                      S.MEMBERID     AS S_MEMBER
                                 FROM CIB_CONTRACT_DATA C, CIB_SUBJECT_DATA S
                                WHERE     C.MEMBERID = S.MEMBERID(+)
                                      AND C.MFICODE = :P4_MFI_CODE   
                             ) a
                      WHERE a.S_MEMBER IS NULL)   
            THEN 'Subject Data not found for this member'                     
                      ELSE
               NULL
       END
           AS COMMENT_MEMBERID,
       LOAN_CODE,
       CASE
           WHEN LOAN_CODE IS NULL
           THEN
               'LOAN CODE is empty in Contract Data.'
           WHEN LENGTH (LOAN_CODE) > 21
           THEN
               'LOAN CODE  length limit exceeded in Contract Data.'
           WHEN LOAN_CODE IN (  SELECT LOAN_CODE
                                  FROM CIB_CONTRACT_DATA
                              GROUP BY LOAN_CODE
                                HAVING COUNT (*) > 1)
           THEN
               'Duplicate LOAN CODE in Contract Data.'
           ELSE
               NULL
       END
           AS COMMENT_LOAN_CODE,
       LOAN_TYPE,
       CASE
           WHEN LOAN_TYPE IS NULL OR LOAN_TYPE = ''
           THEN
               'LOAN TYPE is empty in Contract Data'
           WHEN LOAN_TYPE NOT IN ('S',
                                  'M',
                                  'SS',
                                  'SM') --S Single Installment, M Multiple Installment, SS Seasonal Single, SM Seasonal Multiple
           THEN
               'LOAN_TYPE not in "LOAN TYPE" domain table (See the Loan Type Table)'
           ELSE
               NULL
       END
           AS COMMENT_LOAN_TYPE,
       LOAN_DISBURSEMENT_DATE,
       CASE
           WHEN LOAN_DISBURSEMENT_DATE IS NULL OR LOAN_DISBURSEMENT_DATE = ''
           THEN
               'LOAN DISBURSEMENT DATE is empty in Contract Data'
           WHEN LENGTH (LOAN_DISBURSEMENT_DATE) != 8
           THEN
               'LOAN DISBURSEMENT DATE length must be 8 in Contract Data'
           WHEN     LENGTH (LOAN_DISBURSEMENT_DATE) = 8
                AND (   NOT REGEXP_LIKE (
                                SUBSTR (LOAN_DISBURSEMENT_DATE, 1, 2),
                                '^(0[1-9]|[12][0-9]|3[01])$')
                     OR NOT REGEXP_LIKE (
                                SUBSTR (LOAN_DISBURSEMENT_DATE, 3, 2),
                                '^(0[1-9]|1[0-2])$')
                     OR NOT REGEXP_LIKE (
                                SUBSTR (LOAN_DISBURSEMENT_DATE, 5, 4),
                                '^[0-9]{4}$'))
           THEN
               'Loan Disbursement date format is Invalid in Contract/Loan Account Data. (Format:DDMMYYYY)'
           ELSE
               NULL
       END
           AS COMMENT_LOAN_DISBURSEMENT_DATE,
       END_DATE_CONTRACT,
       CASE
           WHEN END_DATE_CONTRACT IS NULL OR END_DATE_CONTRACT = ''
           THEN
               'END DATE CONTRACT is empty in Contract Data'
           WHEN LENGTH (END_DATE_CONTRACT) != 8
           THEN
               'END DATE CONTRACT length must be 8 in Contract Data'
           WHEN     LENGTH (END_DATE_CONTRACT) = 8
                AND (   NOT REGEXP_LIKE (SUBSTR (END_DATE_CONTRACT, 1, 2),
                                         '^(0[1-9]|[12][0-9]|3[01])$')
                     OR NOT REGEXP_LIKE (SUBSTR (END_DATE_CONTRACT, 3, 2),
                                         '^(0[1-9]|1[0-2])$')
                     OR NOT REGEXP_LIKE (SUBSTR (END_DATE_CONTRACT, 5, 4),
                                         '^[0-9]{4}$'))
           THEN
               'END DATE CONTRACT format is Invalid  in Contract Data (Format:DDMMYYYY)'
           ELSE
               NULL
       END
           AS COMMENT_END_DATE_CONTRACT,
       -------------------------------------------------
       CASE
           WHEN     (    END_DATE_CONTRACT IS NOT NULL
                     AND END_DATE_CONTRACT != ''
                     AND LOAN_DISBURSEMENT_DATE IS NOT NULL
                     AND LOAN_DISBURSEMENT_DATE != '')
                AND (TO_DATE (
                            SUBSTR (END_DATE_CONTRACT, 1, 2)
                         || '-'
                         || SUBSTR (END_DATE_CONTRACT, 3, 2)
                         || '-'
                         || SUBSTR (END_DATE_CONTRACT, 5, 4),
                         'DD-MM-YYYY') <
                     TO_DATE (
                            SUBSTR (LOAN_DISBURSEMENT_DATE, 1, 2)
                         || '-'
                         || SUBSTR (LOAN_DISBURSEMENT_DATE, 3, 2)
                         || '-'
                         || SUBSTR (LOAN_DISBURSEMENT_DATE, 5, 4),
                         'DD-MM-YYYY'))
           THEN
               'END DATE CONTRACT is before LOAN DISBURSEMENT DATE'
           ELSE
               NULL
       END
           AS COMMENT_DATE_ORDER,
       --------------------------------------------------
       LAST_INSTALLMENT_PAID_DATE,
       CASE
           WHEN LENGTH (LAST_INSTALLMENT_PAID_DATE) != 8
           THEN
               'END DATE CONTRACT length must be 8 in Contract Data'
           WHEN     LENGTH (LAST_INSTALLMENT_PAID_DATE) = 8
                AND (   NOT REGEXP_LIKE (
                                SUBSTR (LAST_INSTALLMENT_PAID_DATE, 1, 2),
                                '^(0[1-9]|[12][0-9]|3[01])$')
                     OR NOT REGEXP_LIKE (
                                SUBSTR (LAST_INSTALLMENT_PAID_DATE, 3, 2),
                                '^(0[1-9]|1[0-2])$')
                     OR NOT REGEXP_LIKE (
                                SUBSTR (LAST_INSTALLMENT_PAID_DATE, 5, 4),
                                '^[0-9]{4}$'))
           THEN
               'END DATE CONTRACT format is Invalid  in Contract Data (Format:DDMMYYYY)'
           ELSE
               NULL
       END
           AS COMMENT_LAST_INSTALLMENT_PAID_DATE,
       DISBURSED_AMOUNT,
       CASE
           WHEN DISBURSED_AMOUNT IS NULL OR DISBURSED_AMOUNT =0
           THEN
               'Disbursed Amount  Empty in Contract/Loan Account Data'
           WHEN DISBURSED_AMOUNT < 0 OR DISBURSED_AMOUNT > 9999999
           THEN
               'Disbursed Amount is NOT in NUMERIC or length limit exceeded in Contract Data.'
           ELSE
               NULL
       END
           AS COMMENT_DISBURSED_AMOUNT,
       TOTAL_OUTSTANDING_AMT,
       CASE
           WHEN TOTAL_OUTSTANDING_AMT IS NULL OR TOTAL_OUTSTANDING_AMT = 0
           THEN
               'Total Outstanding Amount Empty in Contract/Loan Account Data'
           WHEN TOTAL_OUTSTANDING_AMT < 0 OR TOTAL_OUTSTANDING_AMT > 9999999
           THEN
               'Total Outstanding Amount is NOT in NUMERIC or numeric or length limit exceeded in Contract Data.'
           ELSE
               NULL
       END
           AS COMMENT_TOTAL_OUTSTANDING_AMT,
       PERIODICITY_PAYMENT,
       CASE
           WHEN PERIODICITY_PAYMENT IS NULL OR PERIODICITY_PAYMENT = ''
           THEN
               'Periodicity of Payment  Empty in Contract/Loan Account Data'
           WHEN PERIODICITY_PAYMENT NOT IN ('W',
                                            'F',
                                            'M',
                                            'B',
                                            'Q',
                                            'T',
                                            'C',
                                            'S',
                                            'Y',
                                            'I',
                                            'O')
           THEN
               'Periodicity of Payment (Table Periodicity of Payment) Not in domain (See Table Periodicity of Payment)'
           ELSE
               NULL
       END
           AS COMMENT_PERIODICITY_PAYMENT,
       TOTAL_NUM_INSTALLMENT,
       CASE
           WHEN TOTAL_NUM_INSTALLMENT IS NULL OR TOTAL_NUM_INSTALLMENT=0
           THEN
               'Total Number of Installments  Empty in Contract/Loan Account Data'
           WHEN TOTAL_NUM_INSTALLMENT < 0 OR TOTAL_NUM_INSTALLMENT > 999
           THEN
               'Total Number of Installments  is NOT in NUMERIC or length limit exceeded in Contract/Loan Account Data'
           ELSE
               NULL
       END
           AS COMMENT_TOTAL_NUM_INSTALLMENT,
       INSTALLMENT_AMT,
       CASE
           WHEN INSTALLMENT_AMT IS NULL OR INSTALLMENT_AMT = 0
           THEN
               'Installment Amount  Empty in Contract/Loan Account Data.'
           WHEN INSTALLMENT_AMT < 0 OR INSTALLMENT_AMT > 99999999
           THEN
               'Installment Amount is NOT in NUMERIC or length limit exceeded in Contract Data.'
           ELSE
               NULL
       END
           AS COMMENT_INSTALLMENT_AMT,
       NUM_REMAINING_INSTALLMENT,
       CASE
           WHEN CONTRACT_PHASE = 'LV' AND NUM_REMAINING_INSTALLMENT IS NULL
           THEN
               'The field is mandatory if contract Phase is living.'
           WHEN     (   NUM_REMAINING_INSTALLMENT IS NULL
                     OR NUM_REMAINING_INSTALLMENT = '')
                AND LOAN_STATUS = 'R'
           THEN
               'Number of remaining Installments  Empty but loan status is Regular in Contract/Loan Account Data.'
           WHEN    NUM_REMAINING_INSTALLMENT < 0 OR NUM_REMAINING_INSTALLMENT > 999
           THEN
               'Number of remaining installments is NOT in NUMERIC or length limit exceeded in Contract/Loan Account Data.'
           WHEN NUM_REMAINING_INSTALLMENT > TOTAL_NUM_INSTALLMENT
           THEN
               'Number of remaining installments exceeds the total number of installments in Contract/Loan Account Data.'
           ELSE
               NULL
       END
           AS COMMENT_NUM_REMAINING_INSTALLMENT,
       NUM_OVERDUE_INSTALLMENT,
       CASE
           WHEN     (OVERDUE_AMT IS NOT NULL OR OVERDUE_AMT != 0)
                AND (   NUM_OVERDUE_INSTALLMENT IS NULL
                     OR NUM_OVERDUE_INSTALLMENT = 0)
           THEN
               'The field is Mandatory if there is Overdue Amount in Contract/Loan Account Data.'
           WHEN     (   NUM_OVERDUE_INSTALLMENT IS NULL
                     OR NUM_OVERDUE_INSTALLMENT = 0)
                AND LOAN_STATUS IN ('W',
                                    'SS',
                                    'D',
                                    'BL',
                                    'WO')
           THEN
               'Number of Overdue Installment  Empty but loan status is [W,SS,D,BL,W] in Contract/Loan Account Data.'
           WHEN NUM_OVERDUE_INSTALLMENT < 0 OR NUM_OVERDUE_INSTALLMENT > 999
           THEN
               'Number of Overdue Installment  NOT in NUMERIC or length limit exceeded in Contract/Loan Account Data'
           WHEN NUM_OVERDUE_INSTALLMENT > TOTAL_NUM_INSTALLMENT
           THEN
               'Number of Overdue Installment exceeds the total number of installments in Contract/Loan Account Data.'
           ELSE
               NULL
       END
           AS COMMENT_NUM_OVERDUE_INSTALLMENT,
       OVERDUE_AMT,
       ---------------------------------------------------
       CASE
           WHEN     (   NUM_OVERDUE_INSTALLMENT IS NOT NULL
                     OR NUM_OVERDUE_INSTALLMENT != 0)
                AND (OVERDUE_AMT IS NULL OR OVERDUE_AMT = 0)
           THEN
               'The field is Mandatory in case there are Overdue Installment'
           WHEN     (OVERDUE_AMT IS NULL OR OVERDUE_AMT = '')
                AND LOAN_STATUS IN ('W',
                                    'SS',
                                    'D',
                                    'BL',
                                    'WO')
           THEN
               'Overdue Amount  Empty but loan status is [W,SS,D,BL,W] in Contract/Loan Account Data.'
           WHEN OVERDUE_AMT < 0 OR OVERDUE_AMT > 9999999
           THEN
               'Overdue Amount NOT in NUMERIC or length limit exceeded in Contract/Loan Account Data'
           WHEN OVERDUE_AMT > TOTAL_OUTSTANDING_AMT
           THEN
               'Overdue Amount exceeds the total Outstanding Amount in Contract/Loan Account Data.'
           ELSE
               NULL
       END
           AS COMMENT_OVERDUE_AMT,
       -----------------------------------------------------------

       LOAN_STATUS,
       CASE
           WHEN LOAN_STATUS IS NULL OR LOAN_STATUS = ''
           THEN
               'Loan Status  Empty in Contract/Loan Account Data'
           WHEN LOAN_STATUS NOT IN ('R',
                                    'W',
                                    'SS',
                                    'D',
                                    'BL',
                                    'WO')
           THEN
               'Loan Status (Table Loan Status) Not in domain (See Table Loan Status).'
           ELSE
               NULL
       END
           AS COMMENT_LOAN_STATUS,
       RESCHEDULE_NO,
       CASE
           WHEN     (   LAST_RESCHEDULE_DATE IS NOT NULL
                     OR LAST_RESCHEDULE_DATE != '')
                AND (RESCHEDULE_NO IS NULL OR RESCHEDULE_NO = '')
           THEN
               'The field is Mandatory,  in case there are Date of Last Rescheduling.'
           WHEN OVERDUE_AMT < 0 OR OVERDUE_AMT > 99
           THEN
               'No. of time(s) rescheduling is NOT in NUMERIC or length limit exceeded in Contract/Loan Account Data.'
           ELSE
               NULL
       END
           AS COMMENT_RESCHEDULE_NO,
       LAST_RESCHEDULE_DATE,
       CASE
           WHEN     (RESCHEDULE_NO IS NOT NULL OR RESCHEDULE_NO != 0)
                AND (   LAST_RESCHEDULE_DATE IS NULL
                     OR LAST_RESCHEDULE_DATE = '')
           THEN
               'The field is Mandatory, in case there are Reschedul No.'
           WHEN LENGTH (LAST_RESCHEDULE_DATE) != 8
           THEN
               'END DATE CONTRACT length must be 8 in Contract Data'
           WHEN     LENGTH (LAST_RESCHEDULE_DATE) = 8
                AND (   NOT REGEXP_LIKE (SUBSTR (LAST_RESCHEDULE_DATE, 1, 2),
                                         '^(0[1-9]|[12][0-9]|3[01])$')
                     OR NOT REGEXP_LIKE (SUBSTR (LAST_RESCHEDULE_DATE, 3, 2),
                                         '^(0[1-9]|1[0-2])$')
                     OR NOT REGEXP_LIKE (SUBSTR (LAST_RESCHEDULE_DATE, 5, 4),
                                         '^[0-9]{4}$'))
           THEN
               'Date of Last Rescheduling of the contract  INVALID date in Contract/Loan Account Data. (Format:DDMMYYYY)'
           ELSE
               NULL
       END
           AS COMMENT_LAST_RESCHEDULE_DATE,
       WRITE_OFF_AMT,
       CASE
           WHEN     LOAN_STATUS = 'WO' AND (WRITE_OFF_AMT IS NULL OR WRITE_OFF_AMT = 0)
           THEN
               'The field is Mandatory in case of “Loan Status” is write off (WO).'
           WHEN WRITE_OFF_AMT < 0 OR WRITE_OFF_AMT > 9999999
           THEN
               'Write Off Amount (Taka) is NOT in NUMERIC or length limit exceeded in Contract/Loan Account Data.'
           ELSE
               NULL
       END
           AS COMMENT_WRITE_OFF_AMT,
       WRITE_OFF_DATE,
       CASE
           WHEN LOAN_STATUS = 'WO' AND (WRITE_OFF_DATE IS NULL OR WRITE_OFF_DATE = '')
           THEN
               'The field is Mandatory in case of “Loan Status” is write off (WO).'
           WHEN LENGTH (WRITE_OFF_DATE) != 8
           THEN
               'Write-Off-Date length must be 8 in Contract Data'
           WHEN     LENGTH (WRITE_OFF_DATE) = 8
                AND (   NOT REGEXP_LIKE (SUBSTR (WRITE_OFF_DATE, 1, 2),
                                         '^(0[1-9]|[12][0-9]|3[01])$')
                     OR NOT REGEXP_LIKE (SUBSTR (WRITE_OFF_DATE, 3, 2),
                                         '^(0[1-9]|1[0-2])$')
                     OR NOT REGEXP_LIKE (SUBSTR (WRITE_OFF_DATE, 5, 4),
                                         '^[0-9]{4}$'))
           THEN
               'Write-Off-Date is INVALID in Contract/Loan Account Data. (Format:DDMMYYYY)'
           ELSE
               NULL
       END
           AS COMMENT_WRITE_OFF_DATE,

       CONTRACT_PHASE,
       CASE
           WHEN CONTRACT_PHASE IS NULL OR CONTRACT_PHASE = ''
           THEN
               'Contract Phase  Empty  in Contract/Loan Account Data.'
           WHEN CONTRACT_PHASE NOT IN ('RQ',
                                       'RN',
                                       'RF',
                                       'LV',
                                       'TM',
                                       'TT',
                                       'TA')
           THEN
               'Contract Phase (Table contract Phases) Not in domain (Table contract Phases).'
           ELSE
               NULL
       END
           AS COMMENT_CONTRACT_PHASE,

       LOAN_DURATION,
       CASE
            WHEN LOAN_DURATION IS NULL OR LOAN_DURATION=0
            THEN 'Loan Duration  Empty  in Contract/Loan Account Data'
            WHEN LOAN_DURATION<0 OR LOAN_DURATION>999
            THEN 'Loan Duration is NOT NUMERIC or length limit exceeded in Contract/Loan Account Data.'
            ELSE NULL
        END AS COMMENT_LOAN_DURATION,
       ACTUAL_END_DATE_CONTRACT,
       CASE
           WHEN CONTRACT_PHASE IN('TM','TA') AND (ACTUAL_END_DATE_CONTRACT IS NULL OR ACTUAL_END_DATE_CONTRACT = '')
           THEN 'Actual End Date of the contract  Empty but Table contract Phases is [TM,TA] in Contract/Loan Account Data.'
           WHEN LENGTH (ACTUAL_END_DATE_CONTRACT) != 8
           THEN
               'Actual End Date length must be 8 in Contract Data'
           WHEN     LENGTH (ACTUAL_END_DATE_CONTRACT) = 8
                AND (   NOT REGEXP_LIKE (SUBSTR (ACTUAL_END_DATE_CONTRACT, 1, 2),
                                         '^(0[1-9]|[12][0-9]|3[01])$')
                     OR NOT REGEXP_LIKE (SUBSTR (ACTUAL_END_DATE_CONTRACT, 3, 2),
                                         '^(0[1-9]|1[0-2])$')
                     OR NOT REGEXP_LIKE (SUBSTR (ACTUAL_END_DATE_CONTRACT, 5, 4),
                                         '^[0-9]{4}$'))
           THEN
               'Actual End Date of the contract is INVALID in Contract/Loan Account Data.(Format:DDMMYYYY)'
              WHEN TO_DATE(ACTUAL_END_DATE_CONTRACT, 'DDMMYYYY')< TO_DATE(LOAN_DISBURSEMENT_DATE, 'DDMMYYYY')
              THEN 'Actual End Date of the contract < Loan Disbursement Date in Contract/Loan Account Data.'
           ELSE
               NULL
       END
           AS COMMENT_ACTUAL_END_DATE_CONTRACT,
       ECONOMIC_PURPOSE_CODE,
       CASE
       WHEN ECONOMIC_PURPOSE_CODE IS NULL OR ECONOMIC_PURPOSE_CODE =''
           THEN
               'Economic purpose code  Empty  in Contract/Loan Account Data.'
       WHEN ECONOMIC_PURPOSE_CODE NOT IN(SELECT EP_CODE from CIB_ECONOMIC_PURPOSES_CODE)
       THEN 'Economic purpose code (Economic purpose code) Not in domain (See Economic purpose code)'
       ELSE
       NULL
       END AS COMMENT_ECONOMIC_PURPOSE_CODE,
       COMPULSORY_SAVING_AMT,
       CASE
           WHEN COMPULSORY_SAVING_AMT IS NULL OR COMPULSORY_SAVING_AMT = 0
           THEN
               'Amount Compulsory Savings (Taka) is Empty  in Contract/Loan Account Data.'
           WHEN COMPULSORY_SAVING_AMT < 0 OR COMPULSORY_SAVING_AMT > 9999999
           THEN
               'Amount Voluntary Savings (Taka) is NOT NUMERIC or length limit exceeded in Contract/Loan Account Data.'
           ELSE
               NULL
       END
           AS COMMENT_COMPULSORY_SAVING_AMT,

       VOLUNTARY_SAVING_AMT,
       CASE
            WHEN VOLUNTARY_SAVING_AMT < 0 OR VOLUNTARY_SAVING_AMT > 9999999
           THEN
               'Amount Voluntary Savings (Taka) is NOT NUMERIC or length limit exceeded  in Contract/Loan Account Data.'
           ELSE
               NULL
       END
           AS COMMENT_VOLUNTARY_SAVING_AMT,
       TERM_SAVING_AMT,
       CASE
            WHEN TERM_SAVING_AMT < 0 OR TERM_SAVING_AMT > 9999999
           THEN
               'Amount Term Savings (Taka) is NOT NUMERIC or length limit exceeded in Contract/Loan Account Data.'
           ELSE
               NULL
       END
           AS COMMENT_TERM_SAVING_AMT,

       SUBSIDIZED_CREDIT_FLAG,
       CASE
           WHEN SUBSIDIZED_CREDIT_FLAG IS NULL OR SUBSIDIZED_CREDIT_FLAG = ''
           THEN
               'Flag Subsidized Credit Empty  in Contract/Loan Account Data.'
           WHEN SUBSIDIZED_CREDIT_FLAG NOT IN ('Y', 'N')
           THEN
               'Flag Subsidized Credit (Flag Subsidized Credit) Not in domain (See Flag Subsidized Credit).'
           ELSE
               NULL
       END
           AS COMMENT_SUBSIDIZED_CREDIT_FLAG,
       SERVICE_CHARGE_RATE,
        CASE
           WHEN SERVICE_CHARGE_RATE IS NULL  OR SERVICE_CHARGE_RATE=0
           THEN
               'Service Charge Rate is Empty  in Contract/Loan Account Data.'
           WHEN SERVICE_CHARGE_RATE<0 OR SERVICE_CHARGE_RATE>99999
           THEN 'Service Charge Rate NOT in NUMERIC or length limit exceeded in Contract/Loan Account Data.'

           ELSE
               NULL
       END
           AS COMMENT_SERVICE_CHARGE_RATE,

       PAYMENT_MODE,
       CASE
           WHEN PAYMENT_MODE NOT IN ('CAS',
                                     'CHQ',
                                     'MFS',
                                     'BAR',
                                     'DIR',
                                     'MUL',
                                     'OTH')
           THEN
               'Mode of Payment (Table Subsidized Credit) Not in domain (See Table Subsidized Credit).'
           ELSE
               NULL
       END
           AS COMMENT_PAYMENT_MODE,
       ADVANCE_PAYMENT_AMT,
       CASE
           WHEN     CONTRACT_PHASE = 'TA'
                AND (ADVANCE_PAYMENT_AMT IS NULL OR ADVANCE_PAYMENT_AMT = 0)
           THEN
               'The field is Mandatory in case there are Contract Phase is TA.'
           WHEN ADVANCE_PAYMENT_AMT < 0 OR ADVANCE_PAYMENT_AMT > 9999999
           THEN
               'Advance payment amount NOT in NUMERIC or length limit exceeded in Contract/Loan Account Data.'
           ELSE
               NULL
       END
           AS COMMENT_ADVANCE_PAYMENT_AMT,
       LAW_SUIT,
       CASE
           WHEN LAW_SUIT IS NULL OR LAW_SUIT = ''
           THEN
               'Law suit Empty  in Contract/Loan Account Data .'
           WHEN LAW_SUIT NOT IN ('Y', 'N')
           THEN
               'Law suit Not in domain (See Table Loan Status).'
           ELSE
               NULL
       END
           AS COMMENT_LAW_SUIT,
       ME,
       CASE
           WHEN ME IS NULL OR ME = ''
           THEN
               'ME Empty  in Contract/Loan Account Data.'
           WHEN ME NOT IN ('Y', 'N')
           THEN
               'ME Not in domain (See Table Loan Status).'
           ELSE
               NULL
       END
           AS COMMENT_ME,
       MEMBER_WELFARE_FUND,
       CASE
           WHEN MEMBER_WELFARE_FUND IS NULL OR MEMBER_WELFARE_FUND = ''
           THEN
               'Member Welfare Fund Coverage Empty  in Contract/Loan Account Data.'
           WHEN MEMBER_WELFARE_FUND NOT IN ('Y', 'N')
           THEN
               'Member Welfare Fund Coverage Not in domain (See Table Loan Status).'
           ELSE
               NULL
       END
           AS COMMENT_MEMBER_WELFARE_FUND,
       INSURANCE_COVERAGE,
       CASE
           WHEN INSURANCE_COVERAGE IS NULL OR INSURANCE_COVERAGE = ''
           THEN
               'Insurance Coverage Empty  in Contract/Loan Account Data.'
           WHEN INSURANCE_COVERAGE NOT IN ('Y', 'N')
           THEN
               'Insurance Coverage Not in domain (See Table Loan Status).'
           ELSE
               NULL
       END
           AS COMMENT_INSURANCE_COVERAGE
  FROM CIB_CONTRACT_DATA
 WHERE MFICODE=:P4_MFI_CODE 
                                 
    and ACCOUNTINGDATE   = TO_CHAR(TO_DATE(:P4_ACCOUNTING_DATE, 'MM/DD/YYYY'), 'DDMMYYYY')

    and PRODUCTIONDATE  =TO_CHAR(TO_DATE(:P4_PRODUCTION_DATE, 'MM/DD/YYYY'), 'DDMMYYYY')
   