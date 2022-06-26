*** Settings ***
Documentation       Inhuman Insurance, Inc. Artificial Intelligence System robot.
...                 Produces traffic data work items.

Library             RPA.HTTP
Library             RPA.JSON
Library             RPA.Tables
Library             Collections
Resource            shared.robot


*** Variables ***
${TRAFFIC_JSON_FILE_PATH}=      ${OUTPUT_DIR}${/}traffic.json
# JSON data keys:
${COUNTRY_KEY}=                 SpatialDim
${GENDER_KEY}=                  Dim1
${RATE_KEY}=                    NumericValue
${YEAR_KEY}=                    TimeDim


*** Tasks ***
Produce traffic data work items
    Download traffic data
    ${traffic_data}=    Load traffic data as table
    ${filtered_sorted_table}=    Filter and sort traffic data    ${traffic_data}
    #Write table to CSV    ${filtered_sorted_table}    ${OUTPUT_DIR}${/}traffic.csv
    ${filtered_sorted_table}=    Get latest data by country    ${filtered_sorted_table}
    ${payloads}=    Create work item payloads    ${filtered_sorted_table}
    Save work item payloads    ${payloads}


*** Keywords ***
Download traffic data
    Download
    ...    https://github.com/robocorp/inhuman-insurance-inc/raw/main/RS_198.json
    ...    ${OUTPUT_DIR}${/}traffic.json
    ...    overwrite=True

Load traffic data as table
    ${json}=    Load JSON from file    ${TRAFFIC_JSON_FILE_PATH}
    ${table}=    Create Table    ${json}[value]
    RETURN    ${table}

Filter and sort traffic data
    [Arguments]    ${table}
    ${max_rate}=    Set Variable    ${5.0}
    ${rate_key}=    Set Variable    NumericValue
    ${gender_key}=    Set Variable    Dim1
    ${both_genders}=    Set Variable    BTSX
    ${year_key}=    Set Variable    TimeDim
    Filter Table By Column    ${table}    ${rate_key}    <    ${max_rate}
    Filter Table By Column    ${table}    ${gender_key}    ==    ${both_genders}
    Sort Table By Column    ${table}    ${year_key}    ascending=${True}
    RETURN    ${table}

Get latest data by country
    [Arguments]    ${table}
    Log    ${table}
    ${table}=    Group Table By Column    ${table}    ${country_key}
    Log    ${table}
    ${latest_data_by_country}=    Create List
    FOR    ${group}    IN    @{table}
        ${first_row}=    Pop Table Row    ${group}
        Append To List    ${latest_data_by_country}    ${first_row}
    END
    Log    ${latest_data_by_country}
    RETURN    ${latest_data_by_country}

Create work item payloads
    [Arguments]    ${traffic_data}
    Log    ${traffic_data}
    ${payloads}=    Create List
    FOR    ${row}    IN    @{traffic_data}
        Log    ${row}
        ${payload}=
        ...    Create Dictionary
        ...    country=${row}[${COUNTRY_KEY}]
        ...    year=${row}[${YEAR_KEY}]
        ...    rate=${row}[${RATE_KEY}]
        Log    ${payload}
        Append To List    ${payloads}    ${payload}
    END
    RETURN    ${payloads}

Save work item payloads
    [Arguments]    ${payloads}
    FOR    ${payload}    IN    @{payloads}
        Save work item payload    ${payload}
    END

Save work item payload
    [Arguments]    ${payload}
    ${variables}=    Create Dictionary    ${WORK_ITEM_NAME}=${payload}
    Create Output Work Item    variables=${variables}    save=${True}
