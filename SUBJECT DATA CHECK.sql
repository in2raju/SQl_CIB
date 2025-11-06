/* Formatted on 8/19/2024 9:47:24 PM (QP5 v5.326) */
  SELECT RECORD_NO,
         BRANCH_CODE,
         CASE
             WHEN BRANCH_CODE IS NULL
             THEN
                 'Branch Code is empty in Subject Data.'
             WHEN LENGTH (BRANCH_CODE) = 12
             THEN
                 NULL
             ELSE
                 'Branch Code length limit exceeded in Subject Data.'
         END
             AS COMMENT_BRANCH_CODE,
         MEMBERID,
         CASE
             WHEN MEMBERID IS NULL
             THEN
                 'Brrower Code/Customer ID/Member ID is empty in Subject Data.'
             WHEN LENGTH (MEMBERID) > 20
             THEN
                 'Brrower Code/Customer ID/Member ID  length limit exceeded in Subject Data.'
             WHEN MEMBERID IN (  SELECT MEMBERID
                                   FROM CIB_SUBJECT_DATA
                               GROUP BY MEMBERID
                                 HAVING COUNT (*) > 1)
             THEN
                 'Duplicate Brrower Code/Customer ID/Member ID in Subject Data.'
             ELSE
                 NULL
         END
             AS COMMENT_MEMBERID,
NAME,
         CASE
             WHEN NAME IS NULL OR NAME = '' OR LENGTH (NAME) < 3
             THEN
                 'Name is empty in Subject Data '
             WHEN LENGTH (NAME) > 70
             THEN
                 'Name length limit exceeded in Subject Data.'
             WHEN REGEXP_LIKE (NAME, '[^a-zA-Z .-]')
             THEN
                 'Name has Special Character in Subject Data.'
             ELSE
                 NULL
         END
             AS COMMENT_NAME,
         OCCUPATION,
         CASE
             WHEN OCCUPATION NOT IN ('1',
                                     '2',
                                     '3',
                                     '4',
                                     '5',
                                     '6',
                                     '7',
                                     '8',
                                     '9',
                                     '10')
             THEN
                 'Occupation not in "Occupation Type" domain table (See the Occupation Type Table) '
             WHEN LENGTH (OCCUPATION) > 2
             THEN
                 'Occupation length limit exceeded in Subject Data.'
             ELSE
                 NULL
         END
             AS COMMENT_OCCUPATION,
         FATHERS_NAME,
         CASE
             WHEN    FATHERS_NAME IS NULL
                  OR FATHERS_NAME = ''
                  OR LENGTH (FATHERS_NAME) < 3
             THEN
                 'Father Name is empty in Subject Data'
             WHEN LENGTH (FATHERS_NAME) > 70
             THEN
                 'Father Name length limit exceeded in Subject Data.'
             WHEN REGEXP_LIKE (FATHERS_NAME, '[^a-zA-Z .-]')
             THEN
                 'Father Name has Special Character in Subject Data'
             ELSE
                 NULL
         END
             AS COMMENT_FATHERS_NAME,
         MOTHERS_NAME,
         CASE
             WHEN    MOTHERS_NAME IS NULL
                  OR MOTHERS_NAME = ''
                  OR LENGTH (MOTHERS_NAME) < 3
             THEN
                 'Mother Name is empty in Subject Data'
             WHEN LENGTH (FATHERS_NAME) > 70
             THEN
                 'Mother Name length limit exceeded in Subject Data.'
             WHEN REGEXP_LIKE (MOTHERS_NAME, '[^a-zA-Z .-]')
             THEN
                 'Mother Name has Special Character in Subject Data.'
             ELSE
                 NULL
         END
             AS COMMENT_MOTHERS_NAME,
         MARITAL_STATUS,
         CASE
             WHEN MARITAL_STATUS IS NULL
             THEN
                 'Marital Status is empty in Subject Data'
             WHEN MARITAL_STATUS NOT IN ('1',
                                         '2',
                                         '3',
                                         '4',
                                         '5')
             THEN
                 'Marital Status not in "Marital Status Type" domain table (See the Marital Status Type Table)'
             WHEN LENGTH (MARITAL_STATUS) != 1
             THEN
                 'Marital Status length limit exceeded in Subject Data'
             ELSE
                 NULL
         END
             AS COMMENT_MARITAL_STATUS,
         SPOUSE_NAME,
         CASE
             WHEN     MARITAL_STATUS IN ('1', '3', '4')
                  AND (   SPOUSE_NAME IS NULL
                       OR SPOUSE_NAME = ''
                       OR LENGTH (SPOUSE_NAME) < 3)
             THEN
                 'Spouse Name is empty while Marital Status is 1,3 or 4 in Subject Data.'
             WHEN     MARITAL_STATUS IN ('2', '5')
                  AND (SPOUSE_NAME IS NOT NULL OR SPOUSE_NAME != '')
             THEN
                 'Spouse Name should be empty while Marital Status is 2 or 5 in Subject Data.'
             WHEN LENGTH (SPOUSE_NAME) > 70
             THEN
                 'Spouse Name  length limit exceeded in Subject Data.'
             WHEN REGEXP_LIKE (SPOUSE_NAME, '[^a-zA-Z .-]')
             THEN
                 'Spouse Name has special characters in Subject Data.'
             ELSE
                 NULL
         END
             AS COMMENT_SPOUSE_NAME,
         GENDER,
         CASE
             WHEN GENDER IS NULL OR GENDER = ''
             THEN
                 'Gender is empty in Subject Data'
             WHEN GENDER NOT IN ('F', 'M', 'T')
             THEN
                 'Gender not in "Gender Type" domain table (See the Gender Type Table)'
             WHEN LENGTH (GENDER) > 1
             THEN
                 'Gender length limit exceeded in Subject Data'
             ELSE
                 NULL
         END
             AS COMMENT_GENDER,
         DOB,
         CASE
             WHEN DOB IS NULL OR DOB = ''
             THEN
                 'Date of Birth is empty in Subject Data'
             WHEN LENGTH (DOB) != 8
             THEN
                 'Date of Birth length must be 8 in Subject Data'
             WHEN     LENGTH (DOB) = 8
                  AND (   NOT REGEXP_LIKE (SUBSTR (DOB, 1, 2),
                                           '^(0[1-9]|[12][0-9]|3[01])$')
                       OR NOT REGEXP_LIKE (SUBSTR (DOB, 3, 2),
                                           '^(0[1-9]|1[0-2])$')
                       OR NOT REGEXP_LIKE (SUBSTR (DOB, 5, 4), '^[0-9]{4}$'))
             THEN
                 'Date of Birth  date format is Invalid  in Subject Data (Format:DDMMYYYY)'
             ELSE
                 NULL
         END
             AS COMMENT_DOB,
         NID,
         CASE
             WHEN LENGTH (NID) > 17
             THEN
                 'National ID  length limit exceeded in Subject Data'
             WHEN LENGTH (NID) < 17
             THEN
                 'National ID  length Must be 17 in Subject Data'
             WHEN        LENGTH (NID) = 17
                     AND (NID LIKE '0000%' AND NOT NID LIKE '00000%') -- Exactly 4 zeros at the start
                  OR NID NOT LIKE '0%'              -- Does not start with '0'
                  OR NID IS NULL
             THEN
                 NULL
             ELSE
                 'Invalid NID number in Subject Data.'
         END
             AS COMMENT_NID,
         SMARTCARD_NO,
         CASE
             WHEN LENGTH (SMARTCARD_NO) < 10
             THEN
                 'Smart Card ID  length must be 10 in Subject Data.'
             WHEN (LENGTH (SMARTCARD_NO) = 10 AND SMARTCARD_NO LIKE '0%')
             THEN
                 'Invalid Smart card Number in Subject Data.'
             WHEN    LENGTH (SMARTCARD_NO) IS NULL
                  OR LENGTH (SMARTCARD_NO) = ''
                  OR (LENGTH (SMARTCARD_NO) = 10 AND SMARTCARD_NO NOT LIKE '0%')
             THEN
                 NULL
             ELSE
                 'Smart Card ID  length limit exceeded in Subject Data.'
         END
             AS COMMENT_SMARTCARD_NO,
         BIRTH_CERTIFICATE_NO,
         CASE
             WHEN LENGTH (BIRTH_CERTIFICATE_NO) < 17
             THEN
                 'Birth Certificate no length must be 17 in Subject Data.'
             --WHEN (    LENGTH (BIRTH_CERTIFICATE_NO) = 17
             --    AND BIRTH_CERTIFICATE_NO LIKE '0%')
             --THEN
             --  'Invalid Birth Certificate Number in Subject Data.'
             -- WHEN    LENGTH (BIRTH_CERTIFICATE_NO) IS NULL
             --   OR LENGTH (BIRTH_CERTIFICATE_NO) = ''
             --   OR (    LENGTH (BIRTH_CERTIFICATE_NO) = 17
             --       AND BIRTH_CERTIFICATE_NO NOT LIKE '0%')
             WHEN LENGTH (BIRTH_CERTIFICATE_NO) > 17
             THEN
                 'Birth Certificate no length limit exceeded in Subject Data.'
             ELSE
                 NULL
         END
             AS COMMENT_BIRTH_CERTIFICATE_NO,
         CASE
             -- Check if all fields are NULL or invalid
             WHEN     NID IS NULL
                  AND SMARTCARD_NO IS NULL
                  AND BIRTH_CERTIFICATE_NO IS NULL
             THEN
                 'At least one of NID, SMARTCARD_NO, or BIRTH_CERTIFICATE_NO must be exist in Subject Data'
             -- If at least one field is valid, return NULL
             ELSE
                 NULL
         END
             AS OVERALL_COMMENT,
         TIN,
         CASE
             WHEN TIN IS NOT NULL AND LENGTH (TIN) > 12
             THEN
                 'T.I.N Taxpayer Identification Number length limit exceeded in Subject Data'
             WHEN TIN IS NOT NULL AND LENGTH (TIN) < 12
             THEN
                 'T.I.N Taxpayer Identification Number length must be 12 in Subject Data'
             ELSE
                 NULL
         END
             AS COMMENT_TIN,
         OTHER_ID_TYPE,
         ------------------------------OTHER_ID_TYPE_COMMENT------------------------------
         CASE
             WHEN     OTHER_ID_TYPE IS NOT NULL
                  AND (   OTHER_ID_NO IS NULL
                       OR EXPIRY_DATE IS NULL
                       OR ISSUE_COUNTRY IS NULL)
             THEN
                 'If OTHER_ID_TYPE is provided, OTHER_ID_NO, EXPIRY_DATE, and ISSUE_COUNTRY must also be provided'
             WHEN OTHER_ID_TYPE NOT IN ('1', '2')
             THEN
                 'Other ID Type not in "Other ID Type" domain table (See the Other ID Type Table)'
             --   WHEN LENGTH (OTHER_ID_TYPE) != 1
             --THEN
             --  'Other ID Type length limit exceeded in Subject Data.'

             ELSE
                 NULL
         END
             AS COMMENT_OTHER_ID_TYPE,
         ------------------------------END_OTHER_ID_TYPE_COMMENT------------------------------
         OTHER_ID_NO,
         CASE                                        ----OTHER_ID_NO_COMMENT--
             WHEN LENGTH (OTHER_ID_NO) > 20
             THEN
                 'Other ID No length limit exceeded in Subject Data.'
             WHEN     OTHER_ID_NO IS NOT NULL
                  AND (   OTHER_ID_TYPE IS NULL
                       OR EXPIRY_DATE IS NULL
                       OR ISSUE_COUNTRY IS NULL)
             THEN
                 'If OTHER_ID_NO  is provided, OTHER_ID_TYPE, EXPIRY_DATE, and ISSUE_COUNTRY must also be provided'
             ELSE
                 NULL
         END
             AS COMMENT_OTHER_ID_NO,           ----END_OTHER_ID_NO_COMMENT----
         EXPIRY_DATE,
         ------------------------------EXPIRY_DATE_NO_COMMENT------------------------------
         CASE
             WHEN LENGTH (EXPIRY_DATE) != 8
             THEN
                 'Date of Birth length must be 8 in Subject Data'
             WHEN     LENGTH (EXPIRY_DATE) = 8
                  AND (   NOT REGEXP_LIKE (SUBSTR (EXPIRY_DATE, 1, 2),
                                           '^(0[1-9]|[12][0-9]|3[01])$')
                       OR NOT REGEXP_LIKE (SUBSTR (EXPIRY_DATE, 3, 2),
                                           '^(0[1-9]|1[0-2])$')
                       OR NOT REGEXP_LIKE (SUBSTR (EXPIRY_DATE, 5, 4),
                                           '^[0-9]{4}$'))
             THEN
                 'Date of Birth  date format is Invalid  in Subject Data (Format:DDMMYYYY)'
             WHEN     EXPIRY_DATE IS NOT NULL
                  AND (   OTHER_ID_TYPE IS NULL
                       OR OTHER_ID_NO IS NULL
                       OR ISSUE_COUNTRY IS NULL)
             THEN
                 'If  EXPIRY_DATE is provided, OTHER_ID_TYPE, OTHER_ID_NO and ISSUE_COUNTRY must also be provided'
             ELSE
                 NULL
         END
             AS COMMENT_EXPIRY_DATE,
         ISSUE_COUNTRY,
         CASE
             WHEN ISSUE_COUNTRY != 'BD'
             THEN
                 'ISSUE_COUNTRY must be BD'
             WHEN LENGTH (ISSUE_COUNTRY) != 2
             THEN
                 'Place of Issuing Country length limit exceeded in Subject Data '
             WHEN     ISSUE_COUNTRY IS NOT NULL
                  AND (   OTHER_ID_TYPE IS NULL
                       OR OTHER_ID_NO IS NULL
                       OR EXPIRY_DATE IS NULL)
             THEN
                 'If  ISSUE_COUNTRY  is provided, OTHER_ID_TYPE, OTHER_ID_NO and EXPIRY_DATE must also be provided'
             ELSE
                 NULL
         END
             AS COMMENT_ISSUE_COUNTRY,
         CONTACTNO,
         CASE
             WHEN CONTACTNO IS NULL
             THEN
                 'Contact No is empty in Subject Data'
             WHEN NOT REGEXP_LIKE (CONTACTNO, '^01[3-9][0-9]{8}$')
             THEN
                 'Invalid CONTACTNO'
             WHEN LENGTH (CONTACTNO) > 25
             THEN
                 'Contact No length limit exceeded in Subject Data'
             ELSE
                 NULL
         END
             AS COMMENT_CONTACTNO,
         P_ADDRESS,
         CASE
             WHEN P_ADDRESS IS NULL
             THEN
                 'Permanent Address is empty in Subject Data '
             WHEN LENGTH (P_ADDRESS) > 100
             THEN
                 'Permanent Address length limit exceeded in Subject Data'
             ELSE
                 NULL
         END
             AS COMMENTP_ADDRESS,
         P_THANA,
         CASE
             WHEN P_THANA IS NULL
             THEN
                 'Permanent Address (Thana/Upazilla) is empty in Subject Data File'
             WHEN SUBSTR (P_THANA, 1, 4) != P_DISTRICT
             THEN
                 'P_THANA and P_DISTRICT Code do not match'
             ELSE
                 NULL
         END
             AS COMMENT_P_THANA,
         P_DISTRICT,
         CASE
             WHEN P_DISTRICT IS NULL
             THEN
                 'Permanent Address (District) is empty in Subject Data File '
             WHEN SUBSTR (P_DISTRICT, 1, 4) != SUBSTR (P_THANA, 1, 4)
             THEN
                 'P_THANA and P_DISTRICT Code do not match'
             ELSE
                 NULL
         END
             AS COMMENT_P_DISTRICT,
         P_COUNTRY,
         CASE
             WHEN P_COUNTRY IS NULL
             THEN
                 'Permanent Address  (Country)  is empty in Subject Data File '
             WHEN LENGTH (P_COUNTRY) != 2
             THEN
                 'Permanent Address  (Country)  length limit exceeded in Subject Data'
             WHEN P_COUNTRY != 'BD'
             THEN
                 'P_COUNTRY must be BD'
             ELSE
                 NULL
         END
             AS COMMENT_P_COUNTRY,
         PR_ADDRESS,
         CASE
             WHEN PR_ADDRESS IS NULL
             THEN
                 'Present Address is empty in Subject Data'
             WHEN LENGTH (PR_ADDRESS) > 100
             THEN
                 'Present Address length limit exceeded in Subject Data'
             ELSE
                 NULL
         END
             AS COMMENT_PR_ADDRESS,
         PR_THANA,
         CASE
             WHEN PR_THANA IS NULL
             THEN
                 'Present Address (Thana/Upazilla) is empty in Subject Data File '
             WHEN SUBSTR (PR_THANA, 1, 4) != PR_DISTRICT
             THEN
                 'PR_THANA and PR_DISTRICT Code do not match'
             ELSE
                 NULL
         END
             AS COMMENT_PR_THANA,
         PR_DISTRICT,
         CASE
             WHEN PR_DISTRICT IS NULL
             THEN
                 'Present Address (District) is empty in Subject Data File '
             WHEN SUBSTR (PR_DISTRICT, 1, 4) != SUBSTR (PR_THANA, 1, 4)
             THEN
                 'PR_THANA and PR_DISTRICT Code do not match'
             ELSE
                 NULL
         END
             AS COMMENT_PR_DISTRICT,
         PR_COUNTRY,
         CASE
             WHEN PR_COUNTRY IS NULL
             THEN
                 'Present Address (Country) is empty in Subject Data File '
             WHEN LENGTH (PR_COUNTRY) != 2
             THEN
                 'Present Address (Country) length limit exceeded in Subject Data.'
             WHEN P_COUNTRY != 'BD'
             THEN
                 'PR_COUNTRY must be BD'
             ELSE
                 NULL
         END
             AS COMMENT_PR_COUNTRY,
         ACADEMIC_QUALIFICATION,
         CASE
             WHEN ACADEMIC_QUALIFICATION NOT IN ('1',
                                                 '2',
                                                 '3',
                                                 '4',
                                                 '5',
                                                 '6',
                                                 '7')
             THEN
                 'Academic Qualification not in Education domain table (See the Education Table )'
             --WHEN LENGTH (ACADEMIC_QUALIFICATION) != 1
             --THEN
             --    'Academic Qualification length limit exceeded in Subject Data.'
             ELSE
                 NULL
         END
             AS COMMENT_ACADEMIC_QUALIFICATION
                                   FROM CIB_SUBJECT_DATA
      where MFICODE    =:P5_MFI_CODE      
    --and ACCOUNTINGDATE   = TO_CHAR(TO_DATE(:P5_ACCOUNTING_DATE, 'MM/DD/YYYY'), 'DDMMYYYY')

   -- and PRODUCTIONDATE  =TO_CHAR(TO_DATE(:P5_PRODUCTION_DATE, 'MM/DD/YYYY'), 'DDMMYYYY')
   