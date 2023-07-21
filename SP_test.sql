
use Promo_DataMart;

SELECT SCHEMA_NAME(schema_id)+'.'+[name],[type],create_date,modify_date
FROM sys.objects
WHERE [type] IN ('V','U')
ORDER BY 1

;



