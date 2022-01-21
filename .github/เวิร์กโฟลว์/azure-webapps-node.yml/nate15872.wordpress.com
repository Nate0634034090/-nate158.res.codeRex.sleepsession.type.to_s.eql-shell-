# This workflow will build and push a node.js application to an Azure Web App when a commit is pushed to your default branch.
#
# This workflow assumes you have already created the target Azure App Service web app.
# For instructions see https://docs.microsoft.com/en-us/azure/app-service/quickstart-nodejs?tabs=linux&pivots=development-environment-cli
#
# To configure this workflow:
#
# 1. Download the Publish Profile for your Azure Web App. You can download this file from the Overview page of your Web App in the Azure Portal.
#    For more information: https://docs.microsoft.com/en-us/azure/app-service/deploy-github-actions?tabs=applevel#generate-deployment-credentials
#
# 2. Create a secret in your repository named AZURE_WEBAPP_PUBLISH_PROFILE, paste the publish profile contents as the value of the secret.
#    For instructions on obtaining the publish profile see: https://docs.microsoft.com/azure/app-service/deploy-github-actions#configure-the-github-secret
#
# 3. Change the value for the AZURE_WEBAPP_NAME. Optionally, change the AZURE_WEBAPP_PACKAGE_PATH and NODE_VERSION environment variables below.
#
# For more information on GitHub Actions for Azure: https://github.com/Azure/Actions
# For more information on the Azure Web Apps Deploy action: https://github.com/Azure/webapps-deploy
# For more samples to get started with GitHub Action workflows to deploy to Azure: https://github.com/Azure/actions-workflow-samples

on:
  push:
    branches:
      - main
  workflow_dispatch:

env:
  AZURE_WEBAPP_NAME: your-app-name    # set this to your application's name
  AZURE_WEBAPP_PACKAGE_PATH: '.'      # set this to the path to your web app project, defaults to the repository root
  NODE_VERSION: '14.x'                # set this to the node version to use

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    - name: Set up Node.js
      uses: actions/setup-node@v2
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'

    - name: npm install, build, and test
      run: |
        npm install
        npm run build --if-present
        npm run test --if-present

    - name: Upload artifact for deployment job
      uses: actions/upload-artifact@v2
      with:
        name: node-app
        path: .

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: 'Development'
      url: ${{ steps.deploy-to-webapp.outputs.webapp-url }}

    steps:
    - name: Download artifact from build job
      uses: actions/download-artifact@v2
      with:
        name: node-app

    - name: 'Deploy to Azure WebApp'
      id: deploy-to-webapp 
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
        package: ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}
![โลโก้](https://whitesource-resources.s3.amazonaws.com/ws-sig-images/Whitesource_Logo_178x44.png)  
[![ใบอนุญาต](https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg)](https://opensource.org/licenses/Apache-2.0)
[![CI](https://github.com/whitesource-ps/ws-sbom-generator/actions/workflows/ci.yml/badge.svg)](https://github.com/whitesource-ps/ ws-sbom-generator/actions/workflows/ci.yml)
[![Python 3.6](https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Blue_Python_3.6%2B_Shield_Badge.svg/86px-Blue_Python_3.6%2B_Shield_Badge.svg.png)](https ://www.python.org/downloads/release/python-360/)
[![ปล่อย GitHub](https://img.shields.io/github/v/release/whitesource-ps/ws-sbom-generator)](https://github.com/whitesource-ps/ws-sbom -เครื่องกำเนิดไฟฟ้า/รุ่น/ล่าสุด)  

# WS SBOM Generator ในรูปแบบ SPDX 
เครื่องมือ CLI และอิมเมจ Docker เพื่อสร้างรายงาน SBOM ใน [รูปแบบ SPDX](https://spdx.org)
* เครื่องมือนี้สามารถสร้างรายงานในขอบเขตต่อไปนี้ (กำหนดด้วย: **-s/WS_SCOPE**):
  * โทเค็นโครงการ - เครื่องมือจะสร้างรายงานเกี่ยวกับโครงการเฉพาะ
  * โทเค็นผลิตภัณฑ์ - เครื่องมือจะสร้างรายงานเกี่ยวกับโครงการทั้งหมดภายในผลิตภัณฑ์
  * ไม่ได้ระบุโทเค็น - เครื่องมือจะสร้างรายงานเกี่ยวกับโครงการทั้งหมดภายในองค์กร
* เครื่องมือนี้ใช้แพ็คเกจ [spdx-tools] (https://github.com/spdx/tools) ที่แยกจากกัน
* เครื่องมือยอมรับค่าเพิ่มเติมที่ WhiteSource ไม่รู้จักผ่าน `sbom_extra.json`
* หากไม่มีการระบุ URL (กำหนดด้วย: **-a/WS_URL**) เครื่องมือจะเข้าถึง **saas**
* หากไม่มีการระบุประเภทรายงาน (กำหนดด้วย: **-t/WS_REPORT_TYPE**) เครื่องมือจะสร้างรายงานในรูปแบบ **แท็ก-ค่า**  
  * รูปแบบไฟล์ที่รองรับ: json, tv, rdf, xml และ yaml
## ระบบปฏิบัติการที่รองรับ
- **Linux (ทุบตี):** CentOS, Debian, Ubuntu, RedHat
- **Windows (PowerShell):** 10, 2555, 2559
## ข้อกำหนดเบื้องต้น
Python 3.7+
## การปรับใช้และการใช้งาน
## จาก PyPi (ง่ายที่สุด)
### ติดตั้งเป็นแพ็คเกจ PyPi:
ดำเนินการ: `pip install ws-sbom-generator`
## การใช้งาน:
       ``` เชลล์
       การใช้งาน: ws_sbom_generator.py [-h] -u WS_USER_KEY -k WS_TOKEN [-s SCOPE_TOKEN] [-a WS_URL] [-t {json,tv,rdf,xml,yaml,all}] [-e EXTRA] [-o OUT_DIR]
    
       ยูทิลิตี้เพื่อสร้าง SBOM จากข้อมูล WhiteSource
    
       อาร์กิวเมนต์ตัวเลือก:
         -h, --help แสดงข้อความช่วยเหลือนี้และออก
         -u WS_USER_KEY, --userKey WS_USER_KEY
                               รหัสผู้ใช้ WS
         -k WS_TOKEN, --token WS_TOKEN
                               คีย์องค์กร WS
         -s SCOPE_TOKEN, --ขอบเขต SCOPE_TOKEN
                               โทเค็นขอบเขตของรายงาน SBOM ที่จะสร้าง
         -a WS_URL, --wsUrl WS_URL
                               WS URL
         -t {json,tv,rdf,xml,yaml,all}, --type {json,tv,rdf,xml,yaml,all}
                               ประเภทเอาต์พุต
         -e EXTRA, --พิเศษ EXTRA
                               การกำหนดค่าพิเศษของ SBOM
         -o OUT_DIR, -- ออก OUT_DIR
                               ไดเรกทอรีผลลัพธ์
       ```
## ตัวอย่าง:
``` เชลล์
# สร้างรายงานมูลค่าแท็กในโครงการเฉพาะ 
ws_sbom_generator -u <WS_USER_KEY> -k <WS_ORG_TOKEN> -a app-eu -s <WS_PROJECT_TOKEN> -e /<path/to>/sbom_extra.json -o </path/reports>
# การสร้างรายงาน JSON ในทุกโครงการภายในผลิตภัณฑ์ 
ws_sbom_generator -u <WS_USER_KEY> -k <WS_ORG_TOKEN> -a https://di.whitesourcesoftware.com -s <WS_PRODUCT_TOKEN> -t json -e /<path/to>/sbom_extra.json -o </path/reports>
```
## ตู้คอนเทนเนอร์
### การติดตั้ง:
``` เชลล์
นักเทียบท่าดึง whitesourcetools/ws-sbom-generator:latest 
 ```
### การดำเนินการ:
``` เชลล์
นักเทียบท่าเรียกใช้ --name ws-sbom-generator \ 
  -v /<EXTRA_CONF_DIR>:/opt/ws-sbom-generator/sbom-generator/resources \ 
  -v /<REPORT_OUTPUT_DIR>:/opt/ws-sbom-generator/sbom-generator/output \
  -e WS_USER_KEY=<USER_KEY> \ 
  -e WS_TOKEN=<ORG_WS_TOKEN> \
  -e WS_SCOPE=<WS_SCOPE> \
  -e WS_URL=<WS_URL> \
  -e WS_TYPE=<WS_TYPE> \
  whitesourcetools/ws-sbom-generator 
```
## ตัวอย่างการกำหนดค่าพิเศษ (--สวิตช์พิเศษ/-e)
`` json
{
  "namespace": "http://CreatorWebsite/pathToSpdx/DocumentName-UUID",
  "org_email": "org@email.address",
  "บุคคล": "ชื่อบุคคล",
  "person_email": "person@email.address"
}
```
