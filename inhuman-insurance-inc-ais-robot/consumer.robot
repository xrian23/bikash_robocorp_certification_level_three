*** Settings ***
Documentation       Inhuman Insurance, Inc. Artificial Intelligence System robot.
...                 Consumes traffic data work items.

Resource            shared.robot
Library             RPA.JSON
Library             RPA.HTTP


*** Tasks ***
Consume traffic data work items
    For Each Input Work Item    Process traffic data


*** Keywords ***
Process traffic data
    ${payload}=    Get Work Item Payload
    ${traffic_data}=    Set Variable    ${payload}[${WORK_ITEM_NAME}]
    ${valid}=    Validate traffic data    ${traffic_data}
    IF    ${valid}    Post traffic data to sales system    ${traffic_data}

Validate traffic data
    [Arguments]    ${traffic_data}
    Log    ${traffic_data}
    Set Recursion Limit For System
    ${country}=    Get value from JSON    ${traffic_data}    $.country
    ${valid}=    Evaluate    len("${country}")==3
    RETURN    ${valid}

Post traffic data to sales System
    [Arguments]    ${traffic_data}
    ${status}    ${return}=    Run Keyword And Ignore Error
    ...    POST
    ...    https://robocorp.com/inhuman-insurance-inc/sales-system-api
    ...    json=${traffic_data}
