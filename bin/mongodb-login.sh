echo ''
echo '**********************************************************************************************'
echo 'mongo -u main -p admin123 --authenticationDatabase "admin" --sslAllowInvalidCertificates --ssl'
echo '**********************************************************************************************'
echo ''
#ssh -i ansible/ssh_key.pem ubuntu@$IPADDRESS
ssh -i ./devtools/ansible/mongodb/ssh_key.pem ubuntu@$IPADDRESS

