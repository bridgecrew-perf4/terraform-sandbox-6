source exports

docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/demo2 . -f Dockerfile || exit 9

$(aws ecr get-login --registry-ids ${AWS_ACCOUNT_ID}  --no-include-email)
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/demo2

/usr/local/bin/aws lambda update-function-code --function-name demo2-injection --region eu-west-1 --image-uri ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-1.amazonaws.com/demo2:latest
