SELECT history.unit_id, count(allegation.*) as allegation_count
FROM data_officerhistory as history
LEFT JOIN data_officerallegation as allegation
ON
  history.officer_id = allegation.officer_id
WHERE
  history.effective_date >= allegation.start_date AND
  (history.end_date = Null or history.end_date < allegation.end_date)
GROUP BY
  history.unit_id
ORDER BY
  allegation_count desc;
