use datacleaning;
SELECT * FROM laptopdata;

CREATE TABLE laptopdata_backup LIKE laptopdata;

INSERT INTO laptopdata_backup
SELECT * FROM laptopdata;

SELECT count(*) FROM laptopdata;

SELECT * FROM information_schema.TABLES
WHERE TABLE_SCHEMA='datacleaning'
AND TABLE_NAME='laptopdata';

ALTER TABLE laptopdata DROP COLUMN `Unnamed: 0`;

SELECT * FROM laptopdata
WHERE Company IS NULL or TypeName IS NULL OR Inches IS NULL
or ScreenResolution IS NULL or Cpu IS NULL or Ram IS NULL
or Memory IS NULL or Gpu IS NULL or OpSys IS NULL or
WEIGHT IS NULL or Price IS NULL;

SELECT * FROM laptopdata;
WHERE TypeName IS NULL;
SELECT DISTINCT TypeName FROM laptopdata;

ALTER TABLE laptopdata MODIFY COLUMN Inches DECIMAL(10,1);

UPDATE laptopdata l1
SET Ram=(SELECT REPLACE(Ram,'GB',' ') FROM laptopdata l2 WHERE l2.index=l1.index);

ALTER TABLE laptopdata MODIFY COLUMN Ram integer;

UPDATE laptopdata l1
SET Weight=(SELECT REPLACE(Weight,'kg',' ') FROM laptopdata l2 WHERE l2.index=l1.index);

ALTER TABLE laptopdata MODIFY COLUMN Weight integer;

UPDATE laptopdata l1
SET Price=(SELECT ROUND(Price)
	FROM laptopdata l2 
	WHERE l2.index=l1.index);

SELECT DISTINCT OpSys FROM laptopdata;


UPDATE laptopdata
SET OpSys=CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
	WHEN OpSys LIKE '%windows%' THEN 'windows'
	WHEN OpSys LIKE '%linux%' THEN 'linux'
	WHEN OpSys = 'No OS' THEN 'N/A'
	ELSE 'other'
END;

ALTER TABLE laptopdata
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

SELECT gpu from laptopdata;

UPDATE laptopdata l1
SET gpu_brand=(SELECT SUBSTRING_INDEX(Gpu,' ',1)
			FROM laptopdata l2 WHERE l2.index=l1.index);

UPDATE laptopdata l1
SET gpu_name=(SELECT REPLACE(Gpu,gpu_brand,' ')
			FROM laptopdata l2 WHERE l2.index=l1.index);

ALTER TABLE laptopdata DROP COLUMN Gpu;

SELECT * from laptopdata;

ALTER TABLE laptopdata
ADD COLUMN cpu_brand VARCHAR(255) AFTER cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

UPDATE laptopdata l1
SET cpu_brand =(SELECT substring_index(Cpu,' ',1)
			FROM laptopdata l2 WHERE l2.index=l1.index);

UPDATE laptopdata l1
SET cpu_speed=(SELECT CAST(REPLACE(substring_index(Cpu,' ',-1),'GHz',' ')
			AS DECIMAL(10,2)) FROM laptopdata l2
            WHERE l2.index=l1.index);
            
update laptopdata l1
set cpu_name=(select
				REPLACE(REPLACE(Cpu,cpu_brand,' '),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,' '),' ',-1),' ')
                FROM laptopdata l2 WHERE l2.index=l1.index);

ALTER TABLE laptopdata DROP COLUMN Cpu;

SELECT ScreenResolution,
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1)
FROM laptopdata;

ALTER TABLE laptopdata
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;

UPDATE laptopdata
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,'
',-1),'x',1),
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1);

ALTER TABLE laptopdata
ADD COLUMN touchscreen INTEGER AFTER resolution_height;

SELECT ScreenResolution LIKE '%Touch%' FROM laptopdata;

UPDATE laptopdata
SET touchscreen = ScreenResolution LIKE '%Touch%';

SELECT * FROM laptopdata;

ALTER TABLE laptopdata
DROP COLUMN ScreenResolution;

UPDATE laptopdata
SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

SELECT DISTINCT cpu_name FROM laptopdata;

SELECT Memory FROM laptopdata;

ALTER TABLE laptopdata
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

SELECT Memory,
CASE
WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
WHEN Memory LIKE '%SSD%' THEN 'SSD'
WHEN Memory LIKE '%HDD%' THEN 'HDD'
WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
ELSE NULL
END AS 'memory_type'
FROM laptopdata;

UPDATE laptopdata
SET memory_type = CASE
WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
WHEN Memory LIKE '%SSD%' THEN 'SSD'
WHEN Memory LIKE '%HDD%' THEN 'HDD'
WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
ELSE NULL
END;

SELECT Memory,
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
CASE WHEN Memory LIKE '%+%' THEN
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END
FROM laptopdata;

UPDATE laptopdata
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

SELECT
primary_storage,
CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage,
CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE
secondary_storage END
FROM laptopdata;

UPDATE laptopdata
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE
primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024
ELSE secondary_storage END;

SELECT * FROM laptopdata;

ALTER TABLE laptopdata DROP COLUMN Memory;

ALTER TABLE laptopdata DROP COLUMN gpu_name;
