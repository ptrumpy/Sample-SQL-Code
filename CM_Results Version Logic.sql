SELECT *
FROM DT_RD_CM_RESULTS
WHERE (
		(
			offer_ID = 'WB'
			AND offer_year IN (2013)
			AND version_type = (
				CASE 
					WHEN 'END' IN (
							SELECT DISTINCT version_type
							FROM DT_RD_CM_RESULTS
							WHERE offer_id = 'WB'
								AND offer_year IN (2013)
							)
						THEN 'END'
					ELSE 'INSN'
					END
				)
			AND version_no IN (
				SELECT max(version_no)
				FROM DT_RD_CM_RESULTS
				WHERE version_type = (
						CASE 
							WHEN 'END' IN (
									SELECT DISTINCT version_type
									FROM DT_RD_CM_RESULTS
									)
								THEN 'END'
							ELSE 'INSN'
							END
						)
					AND offer_id = 'WB'
					AND offer_year IN (2013)
				GROUP BY offer_year
					,offer_ID
				)
			)
		OR (
			offer_ID = 'WB'
			AND offer_year IN (2012)
			AND version_type = (
				CASE 
					WHEN 'END' IN (
							SELECT DISTINCT version_type
							FROM DT_RD_CM_RESULTS
							WHERE offer_id = 'WB'
								AND offer_year IN (2012)
							)
						THEN 'END'
					ELSE 'INSN'
					END
				)
			AND version_no IN (
				SELECT max(version_no)
				FROM DT_RD_CM_RESULTS
				WHERE version_type = (
						CASE 
							WHEN 'END' IN (
									SELECT DISTINCT version_type
									FROM DT_RD_CM_RESULTS
									)
								THEN 'END'
							ELSE 'INSN'
							END
						)
					AND offer_id = 'WB'
					AND offer_year IN (2012)
				GROUP BY offer_year
					,offer_ID
				)
			)
		OR (
			offer_ID = 'WB'
			AND offer_year IN (2011)
			AND version_type = (
				CASE 
					WHEN 'END' IN (
							SELECT DISTINCT version_type
							FROM DT_RD_CM_RESULTS
							WHERE offer_id = 'WB'
								AND offer_year IN (2011)
							)
						THEN 'END'
					ELSE 'INSN'
					END
				)
			AND version_no IN (
				SELECT max(version_no)
				FROM DT_RD_CM_RESULTS
				WHERE version_type = (
						CASE 
							WHEN 'END' IN (
									SELECT DISTINCT version_type
									FROM DT_RD_CM_RESULTS
									)
								THEN 'END'
							ELSE 'INSN'
							END
						)
					AND offer_id = 'WB'
					AND offer_year IN (2011)
				GROUP BY offer_year
					,offer_ID
				)
			)
		)