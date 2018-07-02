--Build Descriptor Logic - Col 1 Color Col 2 Size Col 3 Leftovers
--Get Max Year for Pack
Drop table #ptMaxYear
Select Pack, Max(YEar) as Year
into #ptMaxYear
from Conversion
--where pack = '6706870'
group by Pack

Drop table ##ptMerch2DescriptorChange
SELECT distinct [swiss_colony\Trumpy].Pack_Conversion_Ship.Pack
	,Ship
	,Descriptor1
	,DescriptorCode1
	,Descriptor2
	,DescriptorCode2
	,Descriptor3
	,DescriptorCode3
	,CASE 
		WHEN DescriptorCode1 = '6'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '6'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '6'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = '0'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '0'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '0'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = '9'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '9'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '9'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = '7'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '7'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '7'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = '8'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '8'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '8'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = '1'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '1'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '1'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'S'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'S'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'S'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'U'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'U'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'U'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = '2'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '2'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '2'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'Y'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'Y'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'Y'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'G'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'G'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'G'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'J'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'J'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'J'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'K'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'K'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'K'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'L'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'L'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'L'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'P'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'P'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'P'
			THEN Descriptor3 + '*' + DescriptorCode3
		ELSE '*'
		END AS NewDescriptor1
	,CASE 
		WHEN DescriptorCode1 = '3'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '3'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '3'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = '4'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '4'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '4'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = '5'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '5'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '5'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'A'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'A'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'A'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'B'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'B'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'B'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'H'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'H'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'H'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'C'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'C'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'C'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'D'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'D'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'D'
			THEN Descriptor3 + '*' + DescriptorCode3
		ELSE '*'
		END AS NewDescriptor2
	,CASE 
		WHEN DescriptorCode1 = 'E'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'E'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'E'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = 'F'
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = 'F'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'F'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = '6'
			AND DescriptorCode2 = '6'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = '0'
			AND DescriptorCode2 = '0'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = '9'
			AND DescriptorCode2 = '9'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = '7'
			AND DescriptorCode2 = '7'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = '8'
			AND DescriptorCode2 = '8'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = '1'
			AND DescriptorCode2 = '1'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = 'S'
			AND DescriptorCode2 = 'S'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = 'U'
			AND DescriptorCode2 = 'U'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = '2'
			AND DescriptorCode2 = '2'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = 'Y'
			AND DescriptorCode2 = 'Y'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = 'G'
			AND DescriptorCode2 = 'G'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = 'J'
			AND DescriptorCode2 = 'J'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = 'K'
			AND DescriptorCode2 = 'K'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = 'L'
			AND DescriptorCode2 = 'L'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = 'P'
			AND DescriptorCode2 = 'P'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode1 = '0'
			AND (
				DescriptorCode2 = '6'
				OR DescriptorCode3 = '6'
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = '9'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = '7'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = '8'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = '1'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'S'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'U'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = '2'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'Y'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'G'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					,'Y'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					,'Y'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'J'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					,'Y'
					,'G'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					,'Y'
					,'G'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'K'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					,'Y'
					,'G'
					,'J'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					,'Y'
					,'G'
					,'J'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'L'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					,'Y'
					,'G'
					,'J'
					,'K'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					,'Y'
					,'G'
					,'J'
					,'K'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'P'
			AND (
				DescriptorCode2 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					,'Y'
					,'G'
					,'J'
					,'K'
					,'L'
					)
				OR DescriptorCode3 IN (
					'6'
					,'0'
					,'9'
					,'7'
					,'8'
					,'1'
					,'S'
					,'U'
					,'2'
					,'Y'
					,'G'
					,'J'
					,'K'
					,'L'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '0'
			AND DescriptorCode1 = '6'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '0'
			AND DescriptorCode1 = '6'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = '9'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '9'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = '7'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '7'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = '8'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '8'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = '1'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '1'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'S'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'S'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'U'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'U'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = '2'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '2'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'Y'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'Y'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'G'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				,'Y'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'G'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				,'Y'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'J'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				,'Y'
				,'G'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'J'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				,'Y'
				,'G'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'K'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				,'Y'
				,'G'
				,'J'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'K'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				,'Y'
				,'G'
				,'J'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'L'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				,'Y'
				,'G'
				,'J'
				,'K'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'L'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				,'Y'
				,'G'
				,'J'
				,'K'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'P'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				,'Y'
				,'G'
				,'J'
				,'K'
				,'L'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'P'
			AND DescriptorCode1 IN (
				'6'
				,'0'
				,'9'
				,'7'
				,'8'
				,'1'
				,'S'
				,'U'
				,'2'
				,'Y'
				,'G'
				,'J'
				,'K'
				,'L'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode1 = '4'
			AND (
				DescriptorCode2 = '3'
				OR DescriptorCode3 = '3'
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = '5'
			AND (
				DescriptorCode2 IN (
					'3'
					,'4'
					)
				OR DescriptorCode3 IN (
					'4'
					,'4'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'A'
			AND (
				DescriptorCode2 IN (
					'3'
					,'4'
					,'5'
					)
				OR DescriptorCode3 IN (
					'3'
					,'4'
					,'5'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'B'
			AND (
				DescriptorCode2 IN (
					'3'
					,'4'
					,'5'
					,'A'
					)
				OR DescriptorCode3 IN (
					'3'
					,'4'
					,'5'
					,'A'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'H'
			AND (
				DescriptorCode2 IN (
					'3'
					,'4'
					,'5'
					,'A'
					,'B'
					)
				OR DescriptorCode3 IN (
					'3'
					,'4'
					,'5'
					,'A'
					,'B'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'C'
			AND (
				DescriptorCode2 IN (
					'3'
					,'4'
					,'5'
					,'A'
					,'B'
					,'H'
					)
				OR DescriptorCode3 IN (
					'3'
					,'4'
					,'5'
					,'A'
					,'B'
					,'H'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode1 = 'D'
			AND (
				DescriptorCode2 IN (
					'3'
					,'4'
					,'5'
					,'A'
					,'B'
					,'H'
					,'C'
					)
				OR DescriptorCode3 IN (
					'3'
					,'4'
					,'5'
					,'A'
					,'B'
					,'H'
					,'C'
					)
				)
			THEN Descriptor1 + '*' + DescriptorCode1
		WHEN DescriptorCode2 = '4'
			AND DescriptorCode1 = '3'
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '4'
			AND DescriptorCode1 = '3'
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = '5'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = '5'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'A'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				,'5'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'A'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				,'5'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'B'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				,'5'
				,'A'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'B'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				,'5'
				,'A'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'H'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				,'5'
				,'A'
				,'B'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'H'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				,'5'
				,'A'
				,'B'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'C'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				,'5'
				,'A'
				,'B'
				,'H'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'C'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				,'5'
				,'A'
				,'B'
				,'H'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		WHEN DescriptorCode2 = 'D'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				,'5'
				,'A'
				,'B'
				,'H'
				,'C'
				)
			THEN Descriptor2 + '*' + DescriptorCode2
		WHEN DescriptorCode3 = 'D'
			AND DescriptorCode1 IN (
				'3'
				,'4'
				,'5'
				,'A'
				,'B'
				,'H'
				,'C'
				)
			THEN Descriptor3 + '*' + DescriptorCode3
		ELSE '*'
		END AS NewDescriptor3
INTO ##ptMerch2DescriptorChange
FROM [swiss_colony\Trumpy].Pack_Conversion_Ship Join #ptMaxYear y on [swiss_colony\Trumpy].Pack_Conversion_Ship.Year = y.Year and [swiss_colony\Trumpy].Pack_Conversion_Ship.Pack = y.Pack
--WHERE YEar >= 2013
	--AND 
	--DescriptorCode1 IN (
	--	'6'
	--	,'0'
	--	,'9'
	--	,'7'
	--	,'8'
	--	,'1'
	--	,'S'
	--	,'U'
	--	,'2'
	--	,'Y'
	--	,'G'
	--	,'J'
	--	,'K'
	--	,'L'
	--	,'P'
	--	)
	--AND DescriptorCode2 IN (
	--	'6'
	--	,'0'
	--	,'9'
	--	,'7'
	--	,'8'
	--	,'1'
	--	,'S'
	--	,'U'
	--	,'2'
	--	,'Y'
	--	,'G'
	--	,'J'
	--	,'K'
	--	,'L'
	--	,'P'
	--	)
	--DescriptorCode1 IN (
	--	'3'
	--	,'4'
	--	,'5'
	--	,'A'
	--	,'B'
	--	,'H'
	--	,'C'
	--	,'D'
	--	)
	--AND DescriptorCode2 IN (
	--	'3'
	--	,'4'
	--	,'5'
	--	,'A'
	--	,'B'
	--	,'H'
	--	,'C'
	--	,'D'
	--	)


--Connect to Copy of F21 Item Master to get new SKU numbers
Drop table ##ptCorrectSKUs
SELECT distinct a.Pack
	,a.Ship
	,CASE 
		WHEN a.Ship != i.Sku
			THEN i.Sku
		ELSE a.Ship
		END AS Sku
	,a.NewDescriptor1
	,a.NewDescriptor2
	,a.NewDescriptor3
INTO ##ptCorrectSKUs
FROM ##ptMerch2DescriptorChange a
 JOIN [johnson\dept_app_prod].nfim.dbo.F21ItemMaster i ON a.Pack = i.Product_ID  
	AND a.NewDescriptor1 = i.Descriptor1
	AND a.NewDescriptor2 = i.Descriptor2
	AND a.NewDescriptor3 = i.Descriptor3
	--where Pack = '655265'

	--select * from ##ptMerch2DescriptorChange where Pack = '6706870'

	--select * from Ship where Ship = '6991266'

	--select * from [johnson\dept_app_prod].nfim.dbo.F21ItemMaster where 

