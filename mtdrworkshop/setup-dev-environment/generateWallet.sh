echo ________________________________________
echo Wallet generation for  MTDRDB  ...
echo ________________________________________

if [[ $1 == "" ]]
then
  echo DB OCID not provided
  echo Usage example : ./generateWallet.sh ocid1.autonomousdatabase.oc1.phx.abyhqljtza4ucpamla4huo5o2iopoxk55hia3rfubnwgpmzolya
  exit
fi
export DB_OCID=$1
read -s -p "Wallet Password: " mtdrdb_wallet_password
umask 177
cat >pw <<!
{ "password": "$mtdrdb_wallet_password" }
!
oci db autonomous-database generate-wallet --autonomous-database-id $DB_OCID  --file wallet.zip --from-json file://pw
rm pw
