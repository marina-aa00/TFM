# Execute the 'az functionapp keys list' and 'az functionapp function keys list' commands to obtain the keys used by the Function App for authentication
# Store the JSON output in 'json_output' and 'json_output2' variables
json_output=$(az functionapp keys list --resource-group marina --name appf-pro-transaction-01 --query "{Key1: functionKeys.default}")
json_output2=$(az functionapp function keys list -g marina -n appf-pro-transaction-01 --function-name CurrencyConversionFunction --query "{Key2: default}")

# Use 'jq' to extract values from the JSON map and assign them to variables
value1=$(echo "$json_output" | jq -r '.Key1')
value2=$(echo "$json_output2" | jq -r '.Key2')

# Print the values to verify they have been assigned correctly
echo "Value1: $value1"
echo "Value2: $value2"

# Create two KeyVault secrets to store the previous values 
az keyvault secret set --name funcapp-defaultkeyHost --vault-name kv-pro-main-01 --expires '2023-09-30T12:00:00Z' --value "$value1"
az keyvault secret set --name funcapp-defaultkeyFunc --vault-name kv-pro-main-01 --expires '2023-09-30T12:00:00Z'  --value "$value2"

#Reference the KeyVault secrets in the Function App. By doing so, we avoid having the values of the FunctionApp keys used for authentication visible
az functionapp keys set -g marina -n appf-pro-transaction-01 --key-type functionKeys --key-name default --key-value "@Microsoft.KeyVault(SecretUri=https://kv-pro-main-01.vault.azure.net/secrets/funcapp-defaultkeyHost/)"
az functionapp function keys set -g marina -n appf-pro-transaction-01 --function-name CurrencyConversionFunction --key-name default --key-value "@Microsoft.KeyVault(SecretUri=https://kv-pro-main-01.vault.azure.net/secrets/funcapp-defaultkeyFunc/)"


#Key vault firewall network rules
az keyvault network-rule add --name kv-pro-main-01 -g marina --vnet-name vnet-apps --subnet snet-func
az keyvault network-rule add --name kv-pro-main-01 -g marina --vnet-name vnet-apps --subnet sql-server-subnetwork
az keyvault network-rule add --name kv-pro-main-01 -g marina --vnet-name vnet-apps --subnet appserv-subnetwork
az keyvault network-rule add --name kv-pro-main-01 -g marina --vnet-name vnet-apps --subnet snet-pe
az keyvault network-rule add --name kv-pro-main-01 -g marina --vnet-name vnet-main-pro --subnet subnet_virtual_desktops
az keyvault network-rule add --name kv-pro-main-01 -g marina --vnet-name vnet-main-pro --subnet subnet_main_vm
az keyvault network-rule add --name kv-pro-main-01 -g marina --vnet-name vnet-main-pro --subnet subnet_sql_server
az keyvault network-rule add --name kv-pro-main-01 -g marina --ip-address "2.153.193.121"

#Default rule to deny any access that does not come from any of the previous origins
az keyvault update --resource-group marina --name kv-pro-main-01 --bypass None --default-action Deny