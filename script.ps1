#Changelog

#Created on 12.12.2021 
#This script is used to download data of new customers and compares it to the old file.
#After the comparison, it inserts verified data to newly created database and sends report to the given e-mail address.
#It also runs a query to choose the best customers based on the distance from chosen point and sends this data to 
#e-mail address with the compressed file as an attachment.




#sql

$SQL_USER = "postgres"
$SQL_PASS = "admin123"
$SQL_HOST = "localhost"
$SQL_PORT = "5432"
$SQL_DB = "lab6"
$SQL_PATH = "postgresql://${SQL_USER}:${SQL_PASS}@${SQL_HOST}:${SQL_PORT}/${SQL_DB}"
$SQL_TABLE_NAME = "CUSTOMERS_${NO_INDEX}"

#files_data

$FILE_URL = "https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip"
$ZIP_PASS = "agh"
$NO_INDEX = "400049"
$TIMESTAMP = Get-Date -Format "MMddyyyy"
$TIMESTAMP_LOG = Get-Date
$DOWN = "C:\Users\kondz\Desktop\bazy\cwiczenie6\DOWNLOAD\"
$PROCC = "C:\Users\kondz\Desktop\bazy\cwiczenie6\PROCESSED\"
$FILE_NAME = "Customers_Nov2021.csv"


#Working Directories

$DIR_1 = New-Item -Path $DOWN -ItemType Directory -Force
$DIR_2 = New-Item -Path $PROCC -ItemType Directory -Force


#Downloading data
Invoke-WebRequest -Uri $FILE_URL -OutFile  "${DOWN}Customers_Nov2021.zip"

#Extracting Archive

$7ZipPath = '"C:\Program Files\7-Zip\7z.exe"'
$zipFile = '"${DOWN}Customers_Nov2021.zip"'
$command = "& $7ZipPath e -o${DOWN} -y -tzip -p$ZIP_PASS $zipFile"

iex $command

if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG Unziping succeeded"
}
else
{
    Add-Content "${PROCC}script_${NO_INDEX}.log"-Value "$TIMESTAMP_LOG Unziping failed"
}

#Importing csvs

$FILE_NEW = Import-Csv -Path "${DOWN}Customers_Nov2021.csv"
$FILE_OLD = Import-Csv -Path "${DOWN}Customers_old.csv"

$FILE_TYPE = ".csv"
$FILE_BAD_NAME = "Customers_Nov2021.bad_"

#Finding duplicates

Compare-Object -ReferenceObject $FILE_NEW -DifferenceObject $FILE_OLD  -Property first_name,last_name,email,lat,long -IncludeEqual -ExcludeDifferent |Select-Object -Property first_name,last_name,email,lat,long  |ConvertTo-Csv -Delimiter "," -NoTypeInformation |Foreach-Object {$_ -replace '"', ''} | Out-File ($PROCC+$FILE_BAD_NAME+$TIMESTAMP+$FILE_TYPE)


if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG Found bad lines, moved them to $PROCC$FILE_BAD_NAME$TIMESTAMP$FILE_BAD_TYPE"
}

#Verification of file

$FILE_VER = Compare-Object -ReferenceObject $FILE_NEW -DifferenceObject $FILE_OLD  -Property first_name,last_name,email,lat,long |?{$_.SideIndicator -eq '<='}|Select-Object -Property first_name,last_name,email,lat,long  


if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG $FILE_NAME validated succesfully "
}

#Creating extension

"CREATE EXTENSION IF NOT EXISTS POSTGIS;" |psql --quiet $SQL_PATH



if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG Added postgis extension"
}
#Creating Table

"CREATE TABLE IF NOT EXISTS $SQL_TABLE_NAME (first_name varchar(30), last_name varchar(50), email varchar(100), geom geometry(Point));"|psql $SQL_PATH

if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG Created table"
}


#Insert Data
foreach($line in $FILE_VER)
{
    $first_name = $line.first_name
    $last_name = $line.last_name
    $email = $line.email
    $lat = $line.lat
    $long = $line.long
    

    "INSERT INTO $SQL_TABLE_NAME VALUES('${first_name}', '${last_name}', '${email}', St_GeomFromText('POINT(${lat} ${long})',4326));" | psql --quiet $SQL_PATH

}

if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG Data has been inserted"
}
else
{
    Add-Content "${PROCC}script_${NO_INDEX}.log"-Value "$TIMESTAMP_LOG Inserting data failed"
}


#Verified Outfile
$FILE_VER|ConvertTo-Csv -Delimiter "," -NoTypeInformation |Foreach-Object {$_ -replace '"', ''}| Out-File ($PROCC+$TIMESTAMP+"_"+$FILE_NAME)

if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG Outfile $PROCC+$TIMESTAMP_$FILE_NAME created succesfully"
}



#Creating credentials
$userName = "c99ab4f9a219dd"
$userPassword = "41f037b91701b0"


$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)


#Email body
$dup_tmp = Import-Csv ($PROCC+$FILE_BAD_NAME+$TIMESTAMP+$FILE_TYPE) | Measure-Object
$down_tmp = $FILE_NEW |Measure-Object
$ver_tmp = $FILE_VER |Measure-Object



$DUPLICATES = $dup_tmp.Count
$LINES_DOWN = $down_tmp.Count
$LINES_VER = $ver_tmp.Count
$TABLE_DATA = $ver_tmp.Count*4


$Body = "Liczba wierszy w pobranym pliku: $LINES_DOWN `nLiczba poprawnych wierszy: $LINES_VER `nLiczba duplikatów w pliku wejściowym: $DUPLICATES`nIlość danych załadowanych do tabeli: $TABLE_DATA"

#Sending email report

Send-MailMessage -To “jon-snow@winterfell.com” -From “mother-of-dragons@houseoftargaryen.net”  -Subject “CUSTOMERS LOAD-$TIMESTAMP” -Body $Body -Credential $credObject -SmtpServer “smtp.mailtrap.io” -Port 587


if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG Report sent succesfully"

}

#Creating table BEST_CUSTOMERS_400049
"SELECT first_name,last_name INTO BEST_$SQL_TABLE_NAME FROM $SQL_TABLE_NAME x
WHERE ST_DistanceSpheroid(x.geom, ST_GeomFromText('POINT(41.39988501005976  -75.67329768604034)',4326),'SPHEROID[`"WGS 84`",6378137,298.257223563]')<50000"|psql $SQL_PATH

if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG Created table"
}

#Export table to csv file

$OUT_CSV = ${PROCC}+'BEST_'+$SQL_TABLE_NAME+'.csv'

"COPY BEST_$SQL_TABLE_NAME TO '$OUT_CSV' DELIMITER ',' CSV HEADER;"| psql $SQL_PATH

if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG Exporting successfull"
}


#archiving
$OUT_ZIP = ${PROCC}+'BEST_'+$SQL_TABLE_NAME+'.zip'
$command_e = "& $7ZipPath  a -mx=9 $OUT_ZIP $OUT_CSV"

iex $command_e

if($?)
{
   Add-Content "${PROCC}script_${NO_INDEX}.log" -Value "$TIMESTAMP_LOG Archiving Step - Succesful"
}

#Sending email with archive and report
$csv_tmp = Import-Csv -Path $OUT_CSV | Measure-Object
$csv_final = $csv_tmp.Count

$Last_write = (Get-Item $OUT_CSV).LastWriteTime 

$Body_arch = "Data ostatniej modyfikacji: $Last_write`nILość wierszy: $csv_final"

Send-MailMessage -To “jon-snow@winterfell.com” -From “mother-of-dragons@houseoftargaryen.net”  -Subject “CUSTOMERS PROCCESSED-$TIMESTAMP” -Body $Body_arch -Attachments $OUT_ZIP -Credential $credObject -SmtpServer “smtp.mailtrap.io” -Port 587