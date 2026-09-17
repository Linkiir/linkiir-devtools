-- ---------------------------------------------------------------------------
-- samples - hardcoded message templates for the Data Simulator.
--
-- Each template is a realistic, complete message with {{TOKEN}} placeholders
-- that main.lua fills in. Keeping the messages as literal text rather than
-- building them from a grammar is deliberate: it keeps the node self-contained
-- (no library, no schema files), and what you read here is exactly what gets
-- pushed, which is the property that matters when you are using this to test
-- somebody else's parser.
--
-- Everything is synthetic. The names, addresses, identifiers and payers are
-- invented, so the output needs no de-identification and is safe to share.
-- Adding a format or a message type means adding one entry to M.Templates.
-- ---------------------------------------------------------------------------

local M = {}

-- Three fixed patients, rotated through so repeated messages describe a stable
-- population rather than a stream of strangers - an upsert or patient-match
-- rule needs the same MRN to recur.
M.Patients = {
   {
      mrn = 'MRN100001', account = 'ACC00012345', member = 'W123456789',
      family = 'SMITH', given = 'JAMES', gender = 'M', genderWord = 'male',
      dob = '19800115', dobDash = '1980-01-15',
      street = '123 OAK AVENUE', city = 'CHICAGO', state = 'IL', zip = '60601',
      phone = '(312)555-0142',
   },
   {
      mrn = 'MRN100002', account = 'ACC00067890', member = 'W987654321',
      family = 'JOHNSON', given = 'PATRICIA', gender = 'F', genderWord = 'female',
      dob = '19751122', dobDash = '1975-11-22',
      street = '456 MAIN STREET', city = 'AUSTIN', state = 'TX', zip = '78701',
      phone = '(512)555-0177',
   },
   {
      mrn = 'MRN100003', account = 'ACC00024680', member = 'W456789123',
      family = 'WILLIAMS', given = 'MICHAEL', gender = 'M', genderWord = 'male',
      dob = '19920307', dobDash = '1992-03-07',
      street = '789 ELM DRIVE', city = 'DENVER', state = 'CO', zip = '80202',
      phone = '(303)555-0198',
   },
}

-- ---------------------------------------------------------------------------
-- HL7 v2.5.1 ADT^A01 (admit). Pipe-delimited, CR-separated segments - the
-- separator is applied in main.lua so the template stays readable here.
-- ---------------------------------------------------------------------------
local HL7_ADT_A01 = {
[[MSH|^~\&|LINKIIREMR|LINKIIR HEALTH|GRIDLAB|METRO HOSPITAL|{{TS}}||ADT^A01^ADT_A01|{{CTRL}}|P|2.5.1]],
[[EVN|A01|{{TS}}|||^SIMULATOR^LINKIIR]],
[[PID|1||{{MRN}}^^^LINKIIR^MR||{{FAMILY}}^{{GIVEN}}^A||{{DOB}}|{{GENDER}}|||{{STREET}}^^{{CITY}}^{{STATE}}^{{ZIP}}^USA||{{PHONE}}|||||{{ACCOUNT}}]],
[[NK1|1|{{FAMILY}}^ALEX|SPO|{{STREET}}^^{{CITY}}^{{STATE}}^{{ZIP}}^USA|{{PHONE}}]],
[[PV1|1|I|ICU^101^A||||1234^JONES^ROBERT^^^^MD|||MED||||1|||1234^JONES^ROBERT^^^^MD|INP|{{ACCOUNT}}|SELF|||||||||||||||||01|||LINKIIR HEALTH|||||{{TS}}]],
[[OBX|1|NM|WT^BODY WEIGHT^L||{{WEIGHT}}|lb|||||F|||{{TS}}]],
[[OBX|2|NM|HT^BODY HEIGHT^L||{{HEIGHT}}|in|||||F|||{{TS}}]],
[[AL1|1|DA|F-PENICILLIN^PENICILLIN^L|MO|HIVES]],
[[DG1|1|I10|J18.9^PNEUMONIA, UNSPECIFIED ORGANISM^I10|||A]],
}

-- ---------------------------------------------------------------------------
-- C-CDA R2.1 Continuity of Care Document. Trimmed to a valid-shaped header
-- plus an Allergies and a Problems section - enough to exercise an XML/CDA
-- parser without shipping a 2,000-line document.
-- ---------------------------------------------------------------------------
local CDA_CCD = [[<?xml version="1.0" encoding="UTF-8"?>
<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <realmCode code="US"/>
  <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
  <templateId root="2.16.840.1.113883.10.20.22.1.1" extension="2015-08-01"/>
  <templateId root="2.16.840.1.113883.10.20.22.1.2" extension="2015-08-01"/>
  <id root="{{UUID}}"/>
  <code code="34133-9" codeSystem="2.16.840.1.113883.6.1" displayName="Summarization of Episode Note"/>
  <title>Continuity of Care Document</title>
  <effectiveTime value="{{CDATS}}"/>
  <confidentialityCode code="N" codeSystem="2.16.840.1.113883.5.25"/>
  <languageCode code="en-US"/>
  <recordTarget>
    <patientRole>
      <id root="2.16.840.1.113883.19.5" extension="{{MRN}}"/>
      <addr use="HP">
        <streetAddressLine>{{STREET}}</streetAddressLine>
        <city>{{CITY}}</city>
        <state>{{STATE}}</state>
        <postalCode>{{ZIP}}</postalCode>
        <country>US</country>
      </addr>
      <telecom use="HP" value="tel:{{PHONE}}"/>
      <patient>
        <name use="L">
          <given>{{GIVEN}}</given>
          <family>{{FAMILY}}</family>
        </name>
        <administrativeGenderCode code="{{GENDER}}" codeSystem="2.16.840.1.113883.5.1" displayName="{{GENDERWORD}}"/>
        <birthTime value="{{DOB}}"/>
      </patient>
      <providerOrganization>
        <id root="2.16.840.1.113883.4.6" extension="1234567893"/>
        <name>LINKIIR HEALTH</name>
        <telecom use="WP" value="tel:(312)555-0100"/>
        <addr>
          <streetAddressLine>1 GRID PLAZA</streetAddressLine>
          <city>CHICAGO</city>
          <state>IL</state>
          <postalCode>60601</postalCode>
          <country>US</country>
        </addr>
      </providerOrganization>
    </patientRole>
  </recordTarget>
  <author>
    <time value="{{CDATS}}"/>
    <assignedAuthor>
      <id root="2.16.840.1.113883.4.6" extension="1234567893"/>
      <assignedPerson>
        <name><given>ROBERT</given><family>JONES</family><suffix>MD</suffix></name>
      </assignedPerson>
    </assignedAuthor>
  </author>
  <custodian>
    <assignedCustodian>
      <representedCustodianOrganization>
        <id root="2.16.840.1.113883.19.5"/>
        <name>LINKIIR HEALTH</name>
      </representedCustodianOrganization>
    </assignedCustodian>
  </custodian>
  <component>
    <structuredBody>
      <component>
        <section>
          <templateId root="2.16.840.1.113883.10.20.22.2.6.1" extension="2015-08-01"/>
          <code code="48765-2" codeSystem="2.16.840.1.113883.6.1" displayName="Allergies"/>
          <title>ALLERGIES AND ADVERSE REACTIONS</title>
          <text>
            <table border="1" width="100%">
              <thead><tr><th>Substance</th><th>Reaction</th><th>Status</th></tr></thead>
              <tbody><tr><td>Penicillin</td><td>Hives</td><td>Active</td></tr></tbody>
            </table>
          </text>
        </section>
      </component>
      <component>
        <section>
          <templateId root="2.16.840.1.113883.10.20.22.2.5.1" extension="2015-08-01"/>
          <code code="11450-4" codeSystem="2.16.840.1.113883.6.1" displayName="Problem List"/>
          <title>PROBLEMS</title>
          <text>
            <table border="1" width="100%">
              <thead><tr><th>Problem</th><th>Code</th><th>Status</th></tr></thead>
              <tbody><tr><td>Pneumonia, unspecified organism</td><td>J18.9</td><td>Active</td></tr></tbody>
            </table>
          </text>
        </section>
      </component>
    </structuredBody>
  </component>
</ClinicalDocument>]]

-- ---------------------------------------------------------------------------
-- FHIR R4 Patient resource.
-- ---------------------------------------------------------------------------
local FHIR_PATIENT = [[{
  "resourceType": "Patient",
  "id": "{{UUID}}",
  "meta": {
    "versionId": "1",
    "lastUpdated": "{{ISO}}",
    "profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"]
  },
  "identifier": [
    {
      "use": "usual",
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "MR",
            "display": "Medical Record Number"
          }
        ]
      },
      "system": "urn:oid:2.16.840.1.113883.19.5",
      "value": "{{MRN}}"
    }
  ],
  "active": true,
  "name": [
    {
      "use": "official",
      "family": "{{FAMILY}}",
      "given": ["{{GIVEN}}"]
    }
  ],
  "telecom": [
    { "system": "phone", "value": "{{PHONE}}", "use": "home" }
  ],
  "gender": "{{GENDERWORD}}",
  "birthDate": "{{DOBDASH}}",
  "address": [
    {
      "use": "home",
      "line": ["{{STREET}}"],
      "city": "{{CITY}}",
      "state": "{{STATE}}",
      "postalCode": "{{ZIP}}",
      "country": "US"
    }
  ],
  "managingOrganization": { "display": "LINKIIR HEALTH" }
}]]

-- ---------------------------------------------------------------------------
-- FHIR R4 Observation (a vital sign, tied to the same patient).
-- ---------------------------------------------------------------------------
local FHIR_OBSERVATION = [[{
  "resourceType": "Observation",
  "id": "{{UUID}}",
  "meta": { "lastUpdated": "{{ISO}}" },
  "status": "final",
  "category": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/observation-category",
          "code": "vital-signs",
          "display": "Vital Signs"
        }
      ]
    }
  ],
  "code": {
    "coding": [
      { "system": "http://loinc.org", "code": "29463-7", "display": "Body Weight" }
    ],
    "text": "Body Weight"
  },
  "subject": {
    "reference": "Patient/{{MRN}}",
    "display": "{{GIVEN}} {{FAMILY}}"
  },
  "effectiveDateTime": "{{ISO}}",
  "issued": "{{ISO}}",
  "valueQuantity": {
    "value": {{WEIGHT}},
    "unit": "lb",
    "system": "http://unitsofmeasure.org",
    "code": "[lb_av]"
  }
}]]

-- ---------------------------------------------------------------------------
-- X12 5010 270 - Health Care Eligibility Benefit Inquiry (005010X279A1).
-- Segments are joined with the ~ terminator in main.lua.
-- ---------------------------------------------------------------------------
local X12_270 = {
[[ISA*00*          *00*          *ZZ*LINKIIRGRID    *ZZ*LINKIIRPAYER   *{{DATE6}}*{{TIME}}*^*00501*{{ISACTRL}}*0*P*:]],
[[GS*HS*LINKIIRGRID*LINKIIRPAYER*{{DATE}}*{{TIME}}*{{GSCTRL}}*X*005010X279A1]],
[[ST*270*0001*005010X279A1]],
[[BHT*0022*13*{{TRACE}}*{{DATE}}*{{TIME}}]],
[[HL*1**20*1]],
[[NM1*PR*2*LINKIIR HEALTH PLAN*****PI*00123]],
[[HL*2*1*21*1]],
[[NM1*1P*2*GRID MEDICAL CENTER*****XX*1234567893]],
[[HL*3*2*22*0]],
[[TRN*1*{{TRACE}}*9LINKIIRGRD]],
[[NM1*IL*1*{{FAMILY}}*{{GIVEN}}****MI*{{MEMBER}}]],
[[DMG*D8*{{DOB}}*{{GENDER}}]],
[[DTP*291*D8*{{DATE}}]],
[[EQ*30]],
[[SE*{{SEGCOUNT}}*0001]],
[[GE*1*{{GSCTRL}}]],
[[IEA*1*{{ISACTRL}}]],
}

-- ---------------------------------------------------------------------------
-- X12 5010 271 - Health Care Eligibility Benefit Response (005010X279A1).
-- The response to the 270 above, for the same member: active coverage plus a
-- co-payment and a deductible benefit line.
-- ---------------------------------------------------------------------------
local X12_271 = {
[[ISA*00*          *00*          *ZZ*LINKIIRPAYER   *ZZ*LINKIIRGRID    *{{DATE6}}*{{TIME}}*^*00501*{{ISACTRL}}*0*P*:]],
[[GS*HB*LINKIIRPAYER*LINKIIRGRID*{{DATE}}*{{TIME}}*{{GSCTRL}}*X*005010X279A1]],
[[ST*271*0001*005010X279A1]],
[[BHT*0022*11*{{TRACE}}*{{DATE}}*{{TIME}}]],
[[HL*1**20*1]],
[[NM1*PR*2*LINKIIR HEALTH PLAN*****PI*00123]],
[[HL*2*1*21*1]],
[[NM1*1P*2*GRID MEDICAL CENTER*****XX*1234567893]],
[[HL*3*2*22*0]],
[[TRN*2*{{TRACE}}*9LINKIIRGRD]],
[[NM1*IL*1*{{FAMILY}}*{{GIVEN}}****MI*{{MEMBER}}]],
[[N3*{{STREET}}]],
[[N4*{{CITY}}*{{STATE}}*{{ZIP}}]],
[[DMG*D8*{{DOB}}*{{GENDER}}]],
[[DTP*346*D8*{{YEARSTART}}]],
[[EB*1*IND*30**GOLD PPO PLAN]],
[[EB*B*IND*30*****25*****Y]],
[[EB*C*IND*30*****1500*****Y]],
[[SE*{{SEGCOUNT}}*0001]],
[[GE*1*{{GSCTRL}}]],
[[IEA*1*{{ISACTRL}}]],
}

-- ---------------------------------------------------------------------------
-- The dropdown. Key must match a Message Type list_option in node_config.json.
--   segs   - table of segments joined by `sep`
--   body   - a single ready-made string
--   ext    - file extension, used only in log lines
-- ---------------------------------------------------------------------------
M.Templates = {
   ['HL7 v2.5.1 ADT^A01 (Admit)'] = { segs = HL7_ADT_A01, sep = '\r', ext = 'hl7' },
   ['C-CDA R2.1 CCD']             = { body = CDA_CCD,      ext = 'xml' },
   ['FHIR R4 Patient']            = { body = FHIR_PATIENT, ext = 'json' },
   ['FHIR R4 Observation']        = { body = FHIR_OBSERVATION, ext = 'json' },
   ['X12 5010 270 (Eligibility Inquiry)']  = { segs = X12_270, sep = '~', tail = '~', ext = 'x12', x12 = true },
   ['X12 5010 271 (Eligibility Response)'] = { segs = X12_271, sep = '~', tail = '~', ext = 'x12', x12 = true },
}

return M
