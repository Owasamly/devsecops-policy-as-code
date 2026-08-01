RESULT=$(opa eval \
--format json \
--data policies \
--input terraform/tfplan.json \
"data.terraform.security.deny")


echo $RESULT


COUNT=$(echo $RESULT | jq '.result[0].expressions[0].value | length')


if [ "$COUNT" -gt 0 ]; then

    echo "Security violations found!"

    exit 1

else

    echo "Security scan passed!"

fi