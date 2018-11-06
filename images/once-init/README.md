Using json-groovy scripts whith nexus api:

Add script example:

curl -v -X POST -u admin:admin456 --header "Content-Type: application/json" 'https://nexus.djeg-test.shalb.com/service/rest/v1/script' -d @change-pass.json

Run script:

curl -v -X POST -u admin:admin456 --header "Content-Type: text/plain" 'https://nexus.djeg-test.shalb.com/service/rest/v1/script/setadmpass/run'

Delete script:

curl -v -X DELETE -u admin:admin456 'https://nexus.djeg-test.shalb.com/service/rest/v1/script/setadmpass'

