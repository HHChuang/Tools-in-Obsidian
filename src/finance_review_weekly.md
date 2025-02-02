### 2.4 Review finance
#### Moze 3.0

> Update the MOZE csv file 
> 1. Export csv file from app to mac at `meta/csv/MOZE.csv`
> 2. Use VSCode with bash script `MOZE_date_format.sh` to fix format issue

>[!multi-column]
>> **Category**
>> ```sqlseal
>>TABLE moze = file(meta/csv/MOZE.csv)
>>
>>SELECT Maincategory, SUM(amount) as expense FROM moze
>>WHERE 
>>	Date BETWEEN '<% day1 %>' AND '<% day7 %>'
>>	AND Recordtype = 'Expense'
>>	AND Currency = 'EUR'
>>GROUP BY 
>>	Maincategory
>>ORDER BY 
>>	expense
>>```
> 
>> **Highlist spending**
>>```sqlseal
>>TABLE moze = file(meta/csv/MOZE.csv)
>>
>>SELECT Subcategory, amount FROM moze 
>>WHERE 
>>	Date BETWEEN '<% day1 %>' AND '<% day7 %>'
>>	AND Recordtype = 'Expense'
>>	AND Currency = 'EUR'
>>ORDER BY 
>>	amount DESC
>>LIMIT 5
>>```
>

>[!note]- Total spending 
> ```sqlseal
> TABLE moze = file(meta/csv/MOZE.csv)
> 
> SELECT * FROM moze
> WHERE 
> 	Date BETWEEN '<% day1 %>' AND '<% day7 %>'
> ```

```tasks

(description includes @finance) OR (description includes @shopping)

(done after <% day1 %>) OR (done on <% day1 %> ) 
(done before  <% day7 %>) OR (done on  <% day7 %>)

done

hide start date
hide due date
hide backlink

sort by done
```
#### Note
- #finance/reflection 
	- 
