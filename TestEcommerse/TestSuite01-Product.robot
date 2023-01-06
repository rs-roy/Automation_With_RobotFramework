*** Settings ***
Suite Setup       open browser    ${url}    ${browser}
Suite Teardown    close browser
Library           SeleniumLibrary
Library           String

*** Variables ***
${url}            https://academybugs.com/find-bugs/
${browser}        chrome
${PLP}            https://academybugs.com/find-bugs
${PDP}            https://academybugs.com/store/professional-suit/

*** Test Cases ***
TC001:Price_Compare
    [Documentation]    Check that Price on the Product Listing Page is the same as that on the Product Page without the Currency
    [Setup]    Go To    ${PLP}
    ${totalProducts}    Get Element Count    //li[@class='ec_product_li']
    Should Be True    ${totalProducts}>0
    ${Price1}    Get Text    //*[@id="ec_store_product_list"]/li[1]/*//span[@class = "ec_price_type1"]
    ${url_Product1PDP}    Get Element Attribute    //li[@class='ec_product_li'][1]/*//a    href
    Go To    ${url_Product1PDP}
    ${Price2}    Get Element Attribute    (//div[@class='ec_details_price ec_details_single_price']/span)[1]    innerHTML
    Should Be Equal    ${Price1}[1:]    ${Price2}[1:]

TC002:Product_Sorting
    [Documentation]    After sorting by price, check that the price for the first product is the lowest one
    [Setup]    Go To    ${PLP}
    ${sortfield} =    Set Variable    id=sortfield
    Click Element    ${sortfield}
    Select From List By Label    ${sortfield}    Price Low-High
    ${Price1}    Get Text    //*[@id="ec_store_product_list"]/li[1]/*//span[@class = "ec_price_type1"]
    Log To Console    ${Price1}
    Check if Price1 is the lowest    ${Price1}

TC003:Set_Suite_Variable
    [Documentation]    Get a Model Number (only Number) and set it as Suite Variable
    [Setup]    Go To    ${PDP}
    ${ModelNumber}    Get Model Number
    Set suite variable    ${ModelNumber}

TC004:Search_By_ModelNumber
    [Documentation]    Search a product by Model Number and check if the product is displayed
    [Setup]    Go To    ${PDP}
    Input Text    //input[@name='ec_search']    ${ModelNumber}
    Click Element    //input[@value='Search']
    Sleep    3
    ${count}    Get Element Count    //*[@id="ec_store_product_list"]
    Should Be True    ${count}==1

*** Keywords ***
Check if Price1 is the lowest
    [Arguments]    ${Price1}
    ${count}    Get Element Count    //li[@class='ec_product_li']
    FOR    ${i}    IN RANGE    2    ${count} + 1
        ${ProductPriceExists}=    Run Keyword And Return Status    Get WebElement    //*[@id="ec_store_product_list"]/li[${i}]/*//span[@class = "ec_price_type1"]
        IF    '${ProductPriceExists}' == 'False'
            CONTINUE
        END
        ${priceOther}    Get Text    //*[@id="ec_store_product_list"]/li[${i}]/*//span[@class = "ec_price_type1"]
        Should Be True    ${Price1}[1:] < ${priceOther}[1:]
    END

Get Model Number
    ${Model}    Get Text    //div[@class="ec_details_model_number"]
    ${strModelNumber}    Get Regexp Matches    ${Model}    \\d+    flags=None
    ${ModelNumber}    Convert To Integer    ${strModelNumber}[0]
    [Return]    ${ModelNumber}
