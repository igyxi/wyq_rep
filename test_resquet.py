import requests


url =  'http://10.157.56.139/StoreInfoXml/StoreInfo2.xml'

reponse=requests.get(url)

if reponse.status_code ==200:
    content= reponse.text

    print(content)

else:
    print('fail...')