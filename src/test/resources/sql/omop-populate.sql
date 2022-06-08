CREATE TABLE care_site
(
    care_site_id                  int4         NOT NULL,
    care_site_name                varchar(255) NULL,
    place_of_service_concept_id   int4         NULL,
    location_id                   int4         NULL,
    care_site_source_value        varchar(50)  NULL,
    place_of_service_source_value varchar(50)  NULL
);

CREATE TABLE location
(
    location_id           int4        NOT NULL,
    address_1             varchar(50) NULL,
    address_2             varchar(50) NULL,
    city                  varchar(50) NULL,
    state                 varchar(2)  NULL,
    zip                   varchar(9)  NULL,
    county                varchar(20) NULL,
    location_source_value varchar(50) NULL,
    country_concept_id    int4        NULL,
    country_source_value  varchar(80) NULL,
    latitude              numeric     NULL,
    longitude             numeric     NULL
);

CREATE TABLE concept
(
    concept_id       int4         NOT NULL,
    concept_name     varchar(255) NOT NULL,
    domain_id        varchar(20)  NOT NULL,
    vocabulary_id    varchar(20)  NOT NULL,
    concept_class_id varchar(20)  NOT NULL,
    standard_concept varchar(1)   NULL,
    concept_code     varchar(50)  NOT NULL,
    valid_start_date date         NOT NULL,
    valid_end_date   date         NOT NULL,
    invalid_reason   varchar(1)   NULL
);

CREATE TABLE procedure_occurrence
(
    procedure_occurrence_id     int4        NOT NULL,
    person_id                   int4        NOT NULL,
    procedure_concept_id        int4        NOT NULL,
    procedure_date              date        NOT NULL,
    procedure_datetime          timestamp   NULL,
    procedure_end_date          date        NULL,
    procedure_end_datetime      timestamp   NULL,
    procedure_type_concept_id   int4        NOT NULL,
    modifier_concept_id         int4        NULL,
    quantity                    int4        NULL,
    provider_id                 int4        NULL,
    visit_occurrence_id         int4        NULL,
    visit_detail_id             int4        NULL,
    procedure_source_value      varchar(50) NULL,
    procedure_source_concept_id int4        NULL,
    modifier_source_value       varchar(50) NULL
);

CREATE TABLE provider
(
    provider_id                 int4         NOT NULL,
    provider_name               varchar(255) NULL,
    npi                         varchar(20)  NULL,
    dea                         varchar(20)  NULL,
    specialty_concept_id        int4         NULL,
    care_site_id                int4         NULL,
    year_of_birth               int4         NULL,
    gender_concept_id           int4         NULL,
    provider_source_value       varchar(50)  NULL,
    specialty_source_value      varchar(50)  NULL,
    specialty_source_concept_id int4         NULL,
    gender_source_value         varchar(50)  NULL,
    gender_source_concept_id    int4         NULL
);

CREATE TABLE person
(
    person_id                   int4        NOT NULL,
    gender_concept_id           int4        NOT NULL,
    year_of_birth               int4        NOT NULL,
    month_of_birth              int4        NULL,
    day_of_birth                int4        NULL,
    birth_datetime              timestamp   NULL,
    race_concept_id             int4        NOT NULL,
    ethnicity_concept_id        int4        NOT NULL,
    location_id                 int4        NULL,
    provider_id                 int4        NULL,
    care_site_id                int4        NULL,
    person_source_value         varchar(50) NULL,
    gender_source_value         varchar(50) NULL,
    gender_source_concept_id    int4        NULL,
    race_source_value           varchar(50) NULL,
    race_source_concept_id      int4        NULL,
    ethnicity_source_value      varchar(50) NULL,
    ethnicity_source_concept_id int4        NULL
);


CREATE TABLE visit_occurrence
(
    visit_occurrence_id           int4        NOT NULL,
    person_id                     int4        NOT NULL,
    visit_concept_id              int4        NOT NULL,
    visit_start_date              date        NOT NULL,
    visit_start_datetime          timestamp   NULL,
    visit_end_date                date        NOT NULL,
    visit_end_datetime            timestamp   NULL,
    visit_type_concept_id         int4        NOT NULL,
    provider_id                   int4        NULL,
    care_site_id                  int4        NULL,
    visit_source_value            varchar(50) NULL,
    visit_source_concept_id       int4        NULL,
    admitted_from_concept_id      int4        NULL,
    admitted_from_source_value    varchar(50) NULL,
    discharged_to_concept_id      int4        NULL,
    discharged_to_source_value    varchar(50) NULL,
    preceding_visit_occurrence_id int4        NULL
);

CREATE TABLE condition_occurrence
(
    condition_occurrence_id       int4        NOT NULL,
    person_id                     int4        NOT NULL,
    condition_concept_id          int4        NOT NULL,
    condition_start_date          date        NOT NULL,
    condition_start_datetime      timestamp   NULL,
    condition_end_date            date        NULL,
    condition_end_datetime        timestamp   NULL,
    condition_type_concept_id     int4        NOT NULL,
    condition_status_concept_id   int4        NULL,
    stop_reason                   varchar(20) NULL,
    provider_id                   int4        NULL,
    visit_occurrence_id           int4        NULL,
    visit_detail_id               int4        NULL,
    condition_source_value        varchar(50) NULL,
    condition_source_concept_id   int4        NULL,
    condition_status_source_value varchar(50) NULL
);

CREATE TABLE device_exposure
(
    device_exposure_id             int4         NOT NULL,
    person_id                      int4         NOT NULL,
    device_concept_id              int4         NOT NULL,
    device_exposure_start_date     date         NOT NULL,
    device_exposure_start_datetime timestamp    NULL,
    device_exposure_end_date       date         NULL,
    device_exposure_end_datetime   timestamp    NULL,
    device_type_concept_id         int4         NOT NULL,
    unique_device_id               varchar(255) NULL,
    production_id                  varchar(255) NULL,
    quantity                       int4         NULL,
    provider_id                    int4         NULL,
    visit_occurrence_id            int4         NULL,
    visit_detail_id                int4         NULL,
    device_source_value            varchar(50)  NULL,
    device_source_concept_id       int4         NULL,
    unit_concept_id                int4         NULL,
    unit_source_value              varchar(50)  NULL,
    unit_source_concept_id         int4         NULL
);

CREATE TABLE specimen
(
    specimen_id                 int4        NOT NULL,
    person_id                   int4        NOT NULL,
    specimen_concept_id         int4        NOT NULL,
    specimen_type_concept_id    int4        NOT NULL,
    specimen_date               date        NOT NULL,
    specimen_datetime           timestamp   NULL,
    quantity                    numeric     NULL,
    unit_concept_id             int4        NULL,
    anatomic_site_concept_id    int4        NULL,
    disease_status_concept_id   int4        NULL,
    specimen_source_id          varchar(50) NULL,
    specimen_source_value       varchar(50) NULL,
    unit_source_value           varchar(50) NULL,
    anatomic_site_source_value  varchar(50) NULL,
    disease_status_source_value varchar(50) NULL
);

CREATE TABLE observation
(
    observation_id                int4        NOT NULL,
    person_id                     int4        NOT NULL,
    observation_concept_id        int4        NOT NULL,
    observation_date              date        NOT NULL,
    observation_datetime          timestamp   NULL,
    observation_type_concept_id   int4        NOT NULL,
    value_as_number               numeric     NULL,
    value_as_string               varchar(60) NULL,
    value_as_concept_id           int4        NULL,
    qualifier_concept_id          int4        NULL,
    unit_concept_id               int4        NULL,
    provider_id                   int4        NULL,
    visit_occurrence_id           int4        NULL,
    visit_detail_id               int4        NULL,
    observation_source_value      varchar(50) NULL,
    observation_source_concept_id int4        NULL,
    unit_source_value             varchar(50) NULL,
    qualifier_source_value        varchar(50) NULL,
    value_source_value            varchar(50) NULL,
    observation_event_id          int8        NULL,
    obs_event_field_concept_id    int4        NULL
);


CREATE TABLE measurement
(
    measurement_id                int4        NOT NULL,
    person_id                     int4        NOT NULL,
    measurement_concept_id        int4        NOT NULL,
    measurement_date              date        NOT NULL,
    measurement_datetime          timestamp   NULL,
    measurement_time              varchar(10) NULL,
    measurement_type_concept_id   int4        NOT NULL,
    operator_concept_id           int4        NULL,
    value_as_number               numeric     NULL,
    value_as_concept_id           int4        NULL,
    unit_concept_id               int4        NULL,
    range_low                     numeric     NULL,
    range_high                    numeric     NULL,
    provider_id                   int4        NULL,
    visit_occurrence_id           int4        NULL,
    visit_detail_id               int4        NULL,
    measurement_source_value      varchar(50) NULL,
    measurement_source_concept_id int4        NULL,
    unit_source_value             varchar(50) NULL,
    unit_source_concept_id        int4        NULL,
    value_source_value            varchar(50) NULL,
    measurement_event_id          int8        NULL,
    meas_event_field_concept_id   int4        NULL
);


CREATE TABLE drug_exposure
(
    drug_exposure_id             int4        NOT NULL,
    person_id                    int4        NOT NULL,
    drug_concept_id              int4        NOT NULL,
    drug_exposure_start_date     date        NOT NULL,
    drug_exposure_start_datetime timestamp   NULL,
    drug_exposure_end_date       date        NOT NULL,
    drug_exposure_end_datetime   timestamp   NULL,
    verbatim_end_date            date        NULL,
    drug_type_concept_id         int4        NOT NULL,
    stop_reason                  varchar(20) NULL,
    refills                      int4        NULL,
    quantity                     numeric     NULL,
    days_supply                  int4        NULL,
    sig                          text        NULL,
    route_concept_id             int4        NULL,
    lot_number                   varchar(50) NULL,
    provider_id                  int4        NULL,
    visit_occurrence_id          int4        NULL,
    visit_detail_id              int4        NULL,
    drug_source_value            varchar(50) NULL,
    drug_source_concept_id       int4        NULL,
    route_source_value           varchar(50) NULL,
    dose_unit_source_value       varchar(50) NULL,
    location_id                  int4        NULL
);

CREATE TABLE death
(
    person_id               int4        NOT NULL,
    death_date              date        NOT NULL,
    death_datetime          timestamp   NULL,
    death_type_concept_id   int4        NULL,
    cause_concept_id        int4        NULL,
    cause_source_value      varchar(50) NULL,
    cause_source_concept_id int4        NULL
);


INSERT INTO care_site
(care_site_id, care_site_name, place_of_service_concept_id, location_id, care_site_source_value,
 place_of_service_source_value)
VALUES (1, 'Example care site name', 8717, 1, '2600GD', 'Inpatient Facility'),
       (2, NULL, 8756, 2, '2600RA', 'Outpatient Facility'),
       (3, NULL, 8940, NULL, '815501822', ' '),
       (4, NULL, 8940, NULL, '272401260', ' '),
       (5, NULL, 8940, NULL, '017191654', ' '),
       (6, NULL, 8940, NULL, '396635013', ' '),
       (7, NULL, 8940, NULL, '631138902', ' '),
       (8, NULL, 8717, NULL, '3913XU', 'Inpatient Facility'),
       (9, NULL, 8717, NULL, '3900MB', 'Inpatient Facility'),
       (10, NULL, 8717, NULL, '3900HM', 'Inpatient Facility'),
       (11, NULL, 8756, NULL, '3901GS', 'Outpatient Facility'),
       (12, NULL, 8756, NULL, '3939PG', 'Outpatient Facility'),
       (13, NULL, 8940, NULL, '673314266', ' '),
       (14, NULL, 8940, NULL, '028262926', ' '),
       (15, NULL, 8940, NULL, '027730834', ' '),
       (16, NULL, 8940, NULL, '335324178', ' '),
       (17, NULL, 8940, NULL, '602380861', ' '),
       (18, NULL, 8940, NULL, '958903309', ' '),
       (19, NULL, 8940, NULL, '802066794', ' '),
       (20, NULL, 8940, NULL, '392434615', ' ');


INSERT INTO location
(location_id, address_1, address_2, city, state, zip, county, location_source_value, country_concept_id,
 country_source_value, latitude, longitude)
VALUES (1, '19 Farragut', 'Oxford Street', NULL, 'MO', NULL, '26950', '26-950', 4330424, NULL, NULL, NULL),
       (2, NULL, NULL, NULL, 'PA', NULL, '39230', '39-230', NULL, NULL, NULL, NULL),
       (3, NULL, NULL, NULL, 'PA', NULL, '39280', '39-280', NULL, NULL, NULL, NULL),
       (4, NULL, NULL, NULL, 'CO', NULL, '06290', '06-290', NULL, NULL, NULL, NULL),
       (5, NULL, NULL, NULL, 'WI', NULL, '52590', '52-590', NULL, NULL, NULL, NULL);


INSERT INTO concept
(concept_id, concept_name, domain_id, vocabulary_id, concept_class_id, standard_concept,
 concept_code, valid_start_date, valid_end_date, invalid_reason)
VALUES (8756, 'Outpatient Hospital', 'Place of Service', 'Place of Service', 'Place of Service', 'S', '22',
        '1970-01-01', '2099-12-31', NULL),
       (8940, 'Office', 'Place of Service', 'Place of Service', 'Place of Service', 'S', '11', '1970-01-01',
        '2099-12-31', NULL),
       (8717, 'Inpatient Hospital', 'Place of Service', 'Place of Service', 'Place of Service', 'S', '21', '1970-01-01',
        '2099-12-31', NULL),
       (2000064, 'Percutaneous transluminal coronary angioplasty [PTCA]', 'Procedure', 'ICD9Proc', '4-dig billing code',
        'S', '00.66', '2005-10-01', '2099-12-31', NULL),
       (2001220, 'Suture of laceration of palate', 'Procedure', 'ICD9Proc', '4-dig billing code', 'S', '27.61',
        '1970-01-01', '2099-12-31', NULL),
       (2008238, 'Transfusion of packed cells', 'Procedure', 'ICD9Proc', '4-dig billing code', 'S', '99.04',
        '1970-01-01', '2099-12-31', NULL),
       (2005595, 'Unspecified operation on bone injury, phalanges of hand', 'Procedure', 'ICD9Proc',
        '4-dig billing code', 'S', '79.94', '1970-01-01', '2099-12-31', NULL),
       (2005199, 'Bone graft, patella', 'Procedure', 'ICD9Proc', '4-dig billing code', 'S', '78.06', '1970-01-01',
        '2099-12-31', NULL),
       (4011566, 'Health visitor', 'Provider Specialty', 'SNOMED', 'Social Context', NULL, '159000000', '1970-01-01',
        '2016-07-30', 'D'),
       (4330153, 'Nurse practitioner', 'Provider Specialty', 'SNOMED', 'Social Context', NULL, '224571005',
        '1970-01-01', '2099-12-31', NULL),
       (44818517, 'Visit derived from encounter on claim', 'Type Concept', 'Visit Type', 'Visit Type', 'S',
        'OMOP generated', '1970-01-01', '2099-12-31', NULL),
       (378419, 'Alzheimer''s disease', 'Condition', 'SNOMED', 'Clinical Finding', 'S', '26929004', '1970-01-01',
        '2099-12-31', NULL),
       (75721, 'Prosthetic joint mechanical failure', 'Condition', 'SNOMED', 'Clinical Finding', 'S', '271578000',
        '1970-01-01', '2099-12-31', NULL),
       (439697, 'Hypertensive renal disease with renal failure', 'Condition', 'SNOMED', 'Clinical Finding', 'S',
        '194774006', '1970-01-01', '2099-12-31', NULL),
       (40481816, 'Infection by methicillin sensitive Staphylococcus aureus', 'Condition', 'SNOMED', 'Clinical Finding',
        'S', '442073005', '2009-07-31', '2099-12-31', NULL),
       (80180, 'Osteoarthritis', 'Condition', 'SNOMED', 'Clinical Finding', 'S', '396275006', '1970-01-01',
        '2099-12-31', NULL),
       (2614906, 'Slings', 'Device', 'HCPCS', 'HCPCS', 'S', 'A4565', '1983-01-01', '2099-12-31', NULL),
       (2614803, 'Ostomy pouch, drainable, for use on faceplate, plastic, each', 'Device', 'HCPCS', 'HCPCS', 'S',
        'A4377', '2000-01-01', '2099-12-31', NULL),
       (2615031, 'Gloves, non-sterile, per 100', 'Device', 'HCPCS', 'HCPCS', 'S', 'A4927', '1986-01-01', '2099-12-31',
        NULL),
       (2615760,
        'Catheter, electrophysiology, diagnostic/ablation, other than 3d or vector mapping, other than cool-tip',
        'Device', 'HCPCS', 'HCPCS', 'S', 'C1733', '2001-04-01', '2099-12-31', NULL),
       (2615856, 'Stent, non-coated/non-covered, without delivery system', 'Device', 'HCPCS', 'HCPCS', 'S', 'C1877',
        '2001-04-01', '2099-12-31', NULL),
       (46270217, 'Specimen from cartilage obtained by shave excision', 'Specimen', 'SNOMED', 'Specimen', 'S',
        '16212971000119107', '2015-07-31', '2099-12-31', NULL),
       (44818662, 'Turkish lira', 'Currency', 'Currency', 'Currency', 'S', 'TRY', '1970-01-01', '2099-12-31', NULL),
       (44793022, 'Structure of apex of fourth toe', 'Spec Anatomic Site', 'SNOMED', 'Body Structure', NULL,
        '374081000000107', '2014-04-01', '2016-07-30', 'U'),
       (2102832,
        'Vital signs (temperature, pulse, respiratory rate, and blood pressure) documented and reviewed (CAP) (EM)',
        'Observation', 'CPT4', 'CPT4', 'S', '2010F', '2007-07-03', '2099-12-31', NULL),
       (2720896,
        'Transportation of portable x-ray equipment and personnel to home or nursing home, per trip to facility or location, more than one patient seen',
        'Observation', 'HCPCS', 'HCPCS', 'S', 'R0075', '1986-01-01', '2099-12-31', NULL),
       (437175, 'Fall on same level from slipping, tripping or stumbling', 'Observation', 'SNOMED', 'Clinical Finding',
        'S', '217154006', '1970-01-01', '2099-12-31', NULL),
       (4149299, 'Follow-up orthopedic assessment', 'Observation', 'SNOMED', 'Clinical Finding', 'S', '310249008',
        '1970-01-01', '2099-12-31', NULL),
       (40793114, 'Thiazides | Urine', 'Measurement', 'LOINC', 'LOINC Hierarchy', 'C', 'LP41891-0', '1970-01-01',
        '2099-12-31', NULL),
       (45757035, 'GBq/ml', 'Unit', 'SNOMED', 'Qualifier Value', NULL, '8090711000001107', '1970-01-01', '2007-09-30',
        'U'),
       (1, 'Domain', 'Metadata', 'Domain', 'Domain', NULL, 'OMOP generated', '1970-01-01', '2099-12-31', NULL),
       (40168913, 'carprofen 75 MG Oral Tablet', 'Drug', 'RxNorm', 'Clinical Drug', 'S', '885737', '2010-01-03',
        '2099-12-31', NULL),
       (40164929, 'Metformin hydrochloride 500 MG Oral Tablet', 'Drug', 'RxNorm', 'Clinical Drug', 'S', '861007',
        '2009-09-06', '2099-12-31', NULL),
       (19077375, 'Finasteride 5 MG Oral Tablet', 'Drug', 'RxNorm', 'Clinical Drug', 'S', '310346', '1970-01-01',
        '2099-12-31', NULL),
       (46275616, 'Ampicillin 1000 MG / Sulbactam 500 MG Injection', 'Drug', 'RxNorm', 'Clinical Drug', 'S', '1659592',
        '2015-09-08', '2099-12-31', NULL),
       (40224789, 'medroxyprogesterone acetate 10 MG Oral Tablet', 'Drug', 'RxNorm', 'Clinical Drug', 'S', '1000114',
        '2010-09-05', '2099-12-31', NULL),
       (4128794, 'Oral', 'Route', 'SNOMED', 'Qualifier Value', 'S', '260548002', '1970-01-01', '2099-12-31', NULL),
       (42898160, 'Long Term Care Visit', 'Visit', 'Visit', 'Visit', 'S', 'LTCP', '1970-01-01', '2099-12-31', NULL),
       (38003565, 'Payer enrollment status "Deceased"', 'Type Concept', 'Death Type', 'Death Type', 'S',
        'OMOP generated', '1970-01-01', '2099-12-31', NULL),
       (8527, 'White', 'Race', 'Race', 'Race', 'S', '5', '1970-01-01', '2099-12-31', NULL),
       (8516, 'Black or African American', 'Race', 'Race', 'Race', 'S', '3', '1970-01-01', '2099-12-31', NULL),
       (38003563, 'Hispanic or Latino', 'Ethnicity', 'Ethnicity', 'Ethnicity', 'S', 'Hispanic', '1970-01-01',
        '2099-12-31', NULL),
       (38003564, 'Not Hispanic or Latino', 'Ethnicity', 'Ethnicity', 'Ethnicity', 'S', 'Not Hispanic', '1970-01-01',
        '2099-12-31', NULL),
       (45879101, 'Emergency Department', 'Meas Value', 'LOINC', 'Answer', 'S', 'LA10268-3', '1970-01-01', '2099-12-31',
        NULL);



INSERT INTO procedure_occurrence
(procedure_occurrence_id, person_id, procedure_concept_id, procedure_date, procedure_datetime, procedure_end_date,
 procedure_end_datetime, procedure_type_concept_id, modifier_concept_id, quantity, provider_id, visit_occurrence_id,
 visit_detail_id, procedure_source_value, procedure_source_concept_id, modifier_source_value)
VALUES (108599947, 906440, 2008238, '2010-04-25', NULL, NULL, NULL, 38000251, NULL, NULL, 48878, 43483680, NULL, '9904',
        2008238, NULL),
       (114598132, 956309, 2000064, '2010-05-13', NULL, NULL, NULL, 38000251, NULL, NULL, 12731, 45887852, NULL, '0066',
        2000064, NULL),
       (275191342, 2296927, 2005199, '2008-03-29', NULL, NULL, NULL, 38000251, NULL, NULL, 202664, 110204292, NULL,
        '7806', 2005199, NULL),
       (134276546, 1121148, 2005595, '2009-08-20', NULL, NULL, NULL, 38000251, NULL, NULL, 14272, 53771451, NULL,
        '7994', 2005595, NULL),
       (265732251, 2218124, 2001220, '2008-05-08', NULL, NULL, NULL, 38000251, NULL, NULL, 47376, 106415668, NULL,
        '2761', 2001220, NULL);


INSERT INTO provider
(provider_id, provider_name, npi, dea, specialty_concept_id, care_site_id, year_of_birth, gender_concept_id,
 provider_source_value, specialty_source_value, specialty_source_concept_id, gender_source_value,
 gender_source_concept_id)
VALUES (1, 'John Wick', '3139083564', 'abc', 4011566, 1, 1980, 8532, '3139083564', NULL, NULL, NULL, NULL),
       (2, NULL, '4824842417', NULL, 4330153, 2, NULL, 8532, '4824842417', NULL, NULL, NULL, NULL),
       (3, NULL, '9382129590', NULL, 4330153, 3, NULL, 8507, '9382129590', NULL, NULL, NULL, NULL);

INSERT INTO person
(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, birth_datetime, race_concept_id,
 ethnicity_concept_id, location_id, provider_id, care_site_id, person_source_value, gender_source_value,
 gender_source_concept_id, race_source_value, race_source_concept_id, ethnicity_source_value,
 ethnicity_source_concept_id)
VALUES (1, 8507, 1923, 5, 1, NULL, 8516, 38003564, 1, 1, 1, '00013D2EFD8E45D1', '1', NULL, '1', NULL, '1', NULL),
       (2, 8507, 1943, 5, 1, TO_TIMESTAMP('1943-05-01T06:00:00+01:00', 'YYYY-MM-DDTHH24:MI:SS+TZH:TZM'), 8516, 38003564,
        2, NULL, NULL, '00016F745862898F', '1', NULL, '1', NULL, '1', NULL),
       (3, 8532, 1936, 9, 1, NULL, 8516, 38003564, 3, NULL, NULL, '0001FDD721E223DC', '2', NULL, '1', NULL, '1', NULL),
       (4, 8507, 1941, 6, 1, NULL, 8527, 38003563, 4, NULL, NULL, '00021CA6FF03E670', '1', NULL, '5', NULL, '5', NULL),
       (5, 8507, 1936, 8, 1, NULL, 8527, 38003564, 5, NULL, NULL, '00024B3D2352D2D0', '1', NULL, '1', NULL, '1', NULL);

INSERT INTO visit_occurrence
(visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_start_datetime, visit_end_date,
 visit_end_datetime, visit_type_concept_id, provider_id, care_site_id, visit_source_value, visit_source_concept_id,
 admitted_from_concept_id, admitted_from_source_value, discharged_to_concept_id, discharged_to_source_value,
 preceding_visit_occurrence_id)
VALUES (1, 1, 42898160, '2010-03-12', NULL, '2010-03-13', NULL, 44818517, 1, 1, '196661176988405', NULL, 45879101, NULL,
        0, NULL, NULL),
       (2, 1, 42898160, '2008-09-04', NULL, '2008-09-04', NULL, 44818517, 2, 2, '542192281063886', NULL, 45879101, NULL,
        0, NULL, 1),
       (3, 1, 42898160, '2009-10-14', NULL, '2009-10-14', NULL, 44818517, 3, 3, '887213386947664', NULL, 45879101, NULL,
        0, NULL, 2),
       (4, 1, 42898160, '2010-04-01', NULL, '2010-04-01', NULL, 44818517, 1, 4, '887243388666441', NULL, 45879101, NULL,
        0, NULL, 3),
       (5, 1, 42898160, '2010-11-05', NULL, '2010-11-05', NULL, 44818517, 2, 5, '887463387476539', NULL, 45879101, NULL,
        0, NULL, 4);


INSERT INTO condition_occurrence
(condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_start_datetime,
 condition_end_date, condition_end_datetime, condition_type_concept_id, condition_status_concept_id, stop_reason,
 provider_id, visit_occurrence_id, visit_detail_id, condition_source_value, condition_source_concept_id,
 condition_status_source_value)
VALUES (1, 1, 378419, '2010-03-12', TO_TIMESTAMP('2010-03-12T06:00:00+01:00', 'YYYY-MM-DDTHH24:MI:SS+TZH:TZM'),
        '2010-03-23', NULL, 38000200, NULL, NULL, 1, 1, NULL, '3310', 44826537, NULL),
       (2, 2, 439697, '2009-08-13', NULL, '2009-08-16', NULL, 38000200, NULL, NULL, 2, 2, NULL, '40390', 44835923,
        NULL),
       (3, 3, 40481816, '2009-05-28', NULL, '2009-06-08', NULL, 38000200, NULL, NULL, 3, 3, NULL, '04111', 44827488,
        NULL),
       (4, 4, 75721, '2008-07-14', NULL, '2008-07-15', NULL, 38000200, NULL, NULL, 1, 4, NULL, '99643', 44829478, NULL),
       (5, 1, 80180, '2008-09-27', NULL, '2008-09-30', NULL, 38000200, NULL, NULL, 2, 5, NULL, '71590', 44831489, NULL);


INSERT INTO device_exposure
(device_exposure_id, person_id, device_concept_id, device_exposure_start_date, device_exposure_start_datetime,
 device_exposure_end_date, device_exposure_end_datetime, device_type_concept_id, unique_device_id, production_id,
 quantity, provider_id, visit_occurrence_id, visit_detail_id, device_source_value, device_source_concept_id,
 unit_concept_id, unit_source_value, unit_source_concept_id)
VALUES (1, 1, 2614906, '2009-03-06', NULL, '2009-03-06', NULL, 44818705, NULL, NULL, NULL, 130895, 34364414, NULL,
        'A4565', 2614906, NULL, NULL, NULL),
       (2, 2, 2614803, '2008-07-08', NULL, '2008-07-26', NULL, 44818705, NULL, NULL, NULL, 20268, 61051980, NULL,
        'A4377', 2614803, NULL, NULL, NULL),
       (3, 3, 2615031, '2008-07-26', NULL, '2008-07-26', NULL, 44818705, NULL, NULL, NULL, 40666, 1913688, NULL,
        'A4927', 2615031, NULL, NULL, NULL),
       (4, 4, 2615856, '2010-02-04', NULL, '2010-02-04', NULL, 44818705, NULL, NULL, NULL, 33674, 48173742, NULL,
        'C1877', 2615856, NULL, NULL, NULL),
       (5, 5, 2615760, '2009-12-04', NULL, '2009-12-04', NULL, 44818705, NULL, NULL, NULL, 71682, 4507515, NULL,
        'C1733', 2615760, NULL, NULL, NULL);


INSERT INTO specimen
(specimen_id, person_id, specimen_concept_id, specimen_type_concept_id, specimen_date, specimen_datetime, quantity,
 unit_concept_id, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id, specimen_source_value,
 unit_source_value, anatomic_site_source_value, disease_status_source_value)
VALUES (1, 1, 46270217, 1, '2004-08-05', TO_TIMESTAMP('2004-08-05T20:00:00+01:00', 'YYYY-MM-DDTHH24:MI:SS+TZH:TZM'),
        9.0, 45757035, 44793022, 1, '1', NULL, NULL, NULL, NULL);

INSERT INTO observation
(observation_id, person_id, observation_concept_id, observation_date, observation_datetime, observation_type_concept_id,
 value_as_number, value_as_string, value_as_concept_id, qualifier_concept_id, unit_concept_id, provider_id,
 visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, unit_source_value,
 qualifier_source_value, value_source_value, observation_event_id, obs_event_field_concept_id)
VALUES (3, 3, 4149299, '2009-11-17', TO_TIMESTAMP('2009-11-17T06:00:00+01:00', 'YYYY-MM-DDTHH24:MI:SS+TZH:TZM'),
        38000282, NULL, NULL, 0, NULL, NULL, 14702, 29804754, NULL, 'V5489', 44834301, NULL, NULL, NULL, NULL, NULL),
       (4, 2, 437175, '2008-05-29', NULL, 38000282, NULL, NULL, 0, NULL, NULL, 99385, 36373366, NULL, 'E8859', 44836540,
        NULL, NULL, NULL, NULL, NULL),
       (5, 1, 4149299, '2009-09-01', NULL, 38000282, NULL, NULL, 0, NULL, NULL, 50267, 68310170, NULL, 'V549', 44822712,
        NULL, NULL, NULL, NULL, NULL),
       (1, 1, 2720896, '2008-09-23', NULL, 38000282, NULL, NULL, 0, NULL, 45757035, 259847, 52171704, NULL, 'R0075',
        2720896, NULL, NULL, NULL, NULL, NULL),
       (2, 2, 2102832, '2008-09-23', NULL, 38000282, NULL, NULL, 0, NULL, 45757035, 194285, 23502684, NULL, '2010F',
        2102832, NULL, NULL, NULL, NULL, NULL);

INSERT INTO measurement
(measurement_id, person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_time,
 measurement_type_concept_id, operator_concept_id, value_as_number, value_as_concept_id, unit_concept_id, range_low,
 range_high, provider_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id,
 unit_source_value, unit_source_concept_id, value_source_value, measurement_event_id, meas_event_field_concept_id)
VALUES (1, 1, 40793114, '2002-01-30', TO_TIMESTAMP('2002-10-13T15:59:00+03:00', 'YYYY-MM-DDTHH24:MI:SS+TZH:TZM'), NULL, 1, 1, 1, 1, 45757035, 1.0, 9.0, 1, 1, 1, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO drug_exposure
(drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_start_datetime,
 drug_exposure_end_date, drug_exposure_end_datetime, verbatim_end_date, drug_type_concept_id, stop_reason, refills,
 quantity, days_supply, sig, route_concept_id, lot_number, provider_id, visit_occurrence_id, visit_detail_id,
 drug_source_value, drug_source_concept_id, route_source_value, dose_unit_source_value, location_id)
VALUES (52717068, 972524, 40224789, '2010-12-03', NULL, '2011-01-21', NULL, NULL, 38000175, NULL, NULL, 240, 50, NULL,
        4128794, NULL, NULL, NULL, NULL, '35470053801', 44879709, NULL, NULL, 756),
       (101235033, 1868969, 19077375, '2008-05-06', NULL, '2008-07-24', NULL, NULL, 38000175, NULL, NULL, 300, 80, NULL,
        4128794, NULL, NULL, NULL, NULL, '16729009017', 45049088, NULL, NULL, 326),
       (65042718, 1200768, 40164929, '2010-02-14', NULL, '2010-04-04', NULL, NULL, 38000175, NULL, NULL, 70, 50, NULL,
        NULL, NULL, NULL, NULL, NULL, '59762432000', 45056300, NULL, NULL, 519),
       (57532188, 1061667, 40168913, '2008-03-27', NULL, '2008-05-15', NULL, NULL, 38000175, NULL, NULL, 200, 50, NULL,
        NULL, NULL, NULL, NULL, NULL, '26637091221', 44964289, NULL, NULL, 37),
       (74839724, 1381204, 46275616, '2009-05-14', NULL, '2009-07-02', NULL, NULL, 38000175, NULL, NULL, 200, 50, NULL,
        NULL, NULL, NULL, NULL, NULL, '10515063601', 44895028, NULL, NULL, 831);


INSERT INTO death
(person_id, death_date, death_datetime, death_type_concept_id, cause_concept_id, cause_source_value,
 cause_source_concept_id)
VALUES (1, '2010-12-01', TO_TIMESTAMP('2010-12-01T06:00:00+01:00', 'YYYY-MM-DDTHH24:MI:SS+TZH:TZM'), 38003565, NULL,
        NULL, 0),
       (2, '2009-07-01', NULL, 38003565, NULL, NULL, 0),
       (3, '2009-01-01', TO_TIMESTAMP('2009-01-01T06:00:00+01:00', 'YYYY-MM-DDTHH24:MI:SS+TZH:TZM'), 38003565, NULL,
        NULL, 0),
       (4, '2008-09-01', '2008-09-01', 38003565, NULL, NULL, 0),
       (5, '2008-07-01', '2008-07-01', 38003565, NULL, NULL, 0);
