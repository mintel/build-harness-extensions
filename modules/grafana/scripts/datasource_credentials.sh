#!/usr/bin/env bash
#
# Set the credentials for monitoring related datasources as environment variables to be used in provisioning/datasources/automatic.yml
for s in $(aws secretsmanager get-secret-value --secret-id sre/monitoring/loki-read-ingress-auth --query SecretString --output text --region us-east-2 | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]"); do
    export "${s?}"
done
echo "Successfully loaded loki credentials."
for s in $(aws secretsmanager get-secret-value --secret-id sre/monitoring/tempo-read-ingress-auth --query SecretString --output text --region us-east-2 | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]"); do
    export "${s?}"
done
echo "Successfully loaded tempo credentials."
for s in $(aws secretsmanager get-secret-value --secret-id sre/monitoring/mimir-read-ingress-auth --query SecretString --output text --region us-east-2 | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]"); do
    export "${s?}"
done
echo "Successfully loaded mimir credentials."
