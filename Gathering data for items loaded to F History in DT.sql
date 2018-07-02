select    allocatedseason, ( RTRIM(AllocatedCatalog) +'F') as LoadOffer,
       (Case when ItemNumber < 100000 then ItemNumber + 600000 else ItemNumber + 6000000 end) as Itemnumber,
    (Case when Conversionitemnumber < 100000 then Conversionitemnumber + 600000 else Conversionitemnumber + 6000000 end) as Conversionitemnumber,
       sum (itemQty) as qty
from CurrentOrderLineAllocate

Where allocatedseason = '2013' and allocatedcatalog in ('WB','JM')
and ItemErrorFlag  in(' ','5') and AvailabilityFlag in(' ','1')  and OrderStatus = 'F' and zsubcode not in ('A','B') 
and addressIncompleteCode = '' and LineError17 in ('0',' ') and lineerror22 in ('0',' ') 
 
group by  allocatedseason,(Rtrim(AllocatedCatalog)+'F'),
(Case when Conversionitemnumber < 100000 then Conversionitemnumber + 600000 else Conversionitemnumber + 6000000 end),
(Case when ItemNumber < 100000 then ItemNumber + 600000 else ItemNumber + 6000000 end) 

order by allocatedseason, LoadOffer ,Conversionitemnumber, Itemnumber


select * from currentorderlineallocate where (case when left(conversionitemnumber,2) = '00' then '6' + Right(conversionitemnumber,5) else '6' + Right(conversionItemNumber,6) end) in('6878763','6971733','6801296','6967320','6960814','6872697','6959101','6801287','6872700','6980387','6967646','6801299','6854564','6952176','6975247','6959486','6976158','6973618','6957845','6960805','6952178','6958873','6952191','6959304','6952226','6801307','6884848','6959299','6922678','6884849','6884768','6971726','6884772','6959390','6971755','6854562','6957828','6968681','6959099','6976346','6854560','6979567','6980363','6967307','6952203','6959346','6936695','6957767','6841317','6959339','6959233','6977287','6950984','6952195','6974255','6883442','6841311','6971729','6979457','6878789','6976355','6971724','6895804','6841309','6957043','694986','6952227','691646','6959296','6971735','6961136','6923778','6801894','6854555','6952194','6979588','6958871','6959489','6952089','6979480','6959318','6854554','6976378','6872687','6801874','6958869','6884818','6878694','6959246','6828508','6957751','6859441','6971754','6979600','6859442','6859446','6859450','6959313','6971783','6928075','6971732','6959403','6967297','6957847','6975289','6967308','6971749','6884843','6975059','6971745','6959226','6979555','6959237','6872702','6872698','6950983','691658','6884822','6959340','6884764','6992602','6841259','6950926','6884838','6884815','6967645','6860851','6967644','6827077','6952181','6801328','6959396','6957044','6960405','6979569','6971722','6976116','6957039','6958882','6959391','6950905','6854561','6878787','6959343','6976047','6872696','6959248','6973649','6952197','6872685','6957785','6872686','6959317','6967299','6959325','6962738','6895798','6959327','6801340','6859447','6959238','6959288','6884841','6971719','6976401','6961145','6957025','6900027','6971721','6957021','6872699','6967296','6992464','6959382','6960809','6967323','6957765','6958870','6959300','6959384','6971734','6959229','6957817','6878761','6884810','6884781','6959312','6965624','6960806','6957737','6959307','6957819','6884749','6971725','6986498','6872681','6884804','6859445','6959333','6959329','6967304','6884847','6959492','6967311','6959287','6854559','6952190','6959261','6962737','6952202','6959311','6958884','6960813','6884782','6971737','6841246','6959334','6884823','6959289','6971748','6986485','6976150','6878790','6959335','6973621','6959322','6884803','6979471','6971740','6860852','6884835','6957033','6980404','6959236','6967317','6959308','6971789','6884842','6854556','6895799','6960808','6960812','6884778','691640','6979479','6872701','6952189','6979539','6923780','6959407','6884800','6979454','6959406','6957761','6957777','6878772','6957846','6957032','6959381','6960401','6959394','6957826','687757','6979618','6889701','6971731','6958887','6960817','6884829','6957834','6952198','689760','6841245','6979589','6959404','6967324','6878783','6958868','6952179','6959345','6884840','6957839','6986496','6979577','6958890','6957778','6957776','6884830','6967643','6965767','6971785','6986482','6923800','6979598','6958885','691696','6960802','6936700','6952180','6960810','6979538','6976344','6971782','6959387','6980369','6839479','6872684','6884846','6952146','6855576','6971720','6884779','6957042','6895805','6965759','6901509','6976157','6841323','6878773','6860850','6959344','6980386','6959319','6952205','6890781','6986483','6952163','6979481','6959221','6801314','6884852','6960804','6971751','6957766','6971730','6959336','6961785','6958872','6976197','6884845','6854563','6957836','6971756','6959323','6971739','6959224','6854553','6959370','6889700','6841314','6978637','6957782','6976398','6854566','6974001','6966905','6973644','6884833','6884824','6967312','6971746','6884836','6957827','6952223','6957041','6959098','6978551','6872691','6978477','6961784','6937575','6961953','6884812','6977285','6962736','6979611','6971728','6872683','6986484','6959352','6834590','6916614','6959290','6976216','6884817','6959380','6971736','6973647','6957750','6958877','6979606','6884832','6978605','6884775','6978627','6979576','6957030','6959326','6854557','6971788','6957037','687749','6957047','6962732','6980384','6976403','6959400','6884777','6957045','691650','6967313','6986497','6968503','6976350','6884814','6978606','6976936','6971747','6976347','6976399','681628','6979472','6979591','6878781','6966372','6878764','6957816','6854558','6960816','6959320','6959398','6959097','6801876','6958883','6884853','6960404','6952182','6928039','6957829','6961949','6958893','6975218','6958876','6878776','6967301','6849227','6855578','6977286','6976153','6967647','6884821','6959302','6976074','6976395','6859449','6841268','6878785','6959337','6976923','6884826','6957036','6959331','6878777','6884808','6884851','6979571','6979482','6976361','6971727','6884795','6957770','6961954','6855577','6967321','6872689','6872692','6854565','6976376','6979578','6957034','6550560','6872690','6839827','6959330','6841308','6872695','6981140','6980373','6960811','6860870','6968507','6884850','6872680','6959360','6957597','6959328','6960807','6976397','6959392','6832023','6959275','6961951','6872682','6980885','6959222','6968505','6976387','6959479','6961817','6959234','6959314','6976219','6959332','6849228','6957811','6884811','6959295','6957810','6960393','6980393','6834615','6960815','6801325','6957754'
) and allocatedseason = 2013 and conversionitemnumber not in ('0     0','0.....0') and allocatedcatalog in('JM','WB')

select  top 100 conversionitemnumber, case when left(conversionitemnumber,2) = '00' then '6' + Right(conversionitemnumber,5) else '6' + Right(conversionItemNumber,6) end as item2 from orderline where itemnumber = '0063301'