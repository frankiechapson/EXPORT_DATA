# EXPORT_DATA

## Oracle SQL and PL/SQL solution to export data rows


## Why?

Because sometimes we need export and import data rows what contains special data types such as blob, clob, sdo_geometry or any other data types defined by anybody.
This is a simple function which we can extend with any data type what we would like to.

## How?

It is very easy to use. It has only one mandatory parameter: the name of the table what we want to export.
The second paramter is optional. That could be a where condition to specify the row(s) what we would like to export.
So we can call this way:

    select * from table( EXPORT_DATA ( 'all_types' ) );
or this way:

    select * from table( EXPORT_DATA ( 'persons' , 'id=103' ) );


the result (an sql script) will be like this (the "all_types" table contains only one row and a lot of different type columns see the test script! ):

    DECLARE
        V_ALL_TYPES    ALL_TYPES%rowtype;
        function TU_NUMBER( I_STRING in varchar2 ) return number is
            V_STRING    varchar2( 1000 ) := I_STRING;
            V_NUMBER    number;
        begin
            begin
                V_NUMBER := to_number( V_STRING );
            exception when others then
                V_STRING := translate( V_STRING, ',.', '.,' );
                V_NUMBER := to_number( V_STRING );
            end;
            return V_NUMBER;
        end;
    BEGIN
        V_ALL_TYPES.C_SMALLINT                    := TU_NUMBER('1');
        V_ALL_TYPES.C_INTEGER                     := TU_NUMBER('2');
        V_ALL_TYPES.C_REAL                        := TU_NUMBER('33.1415');
        V_ALL_TYPES.C_DOUBLE                      := TU_NUMBER('11');
        V_ALL_TYPES.C_BIGDECIMAL                  := TU_NUMBER('22');
        V_ALL_TYPES.C_NUMBER                      := TU_NUMBER('3');
        V_ALL_TYPES.C_VARCHAR2                    := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
        V_ALL_TYPES.C_NVARCHAR2                   := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
        V_ALL_TYPES.C_VARCHAR                     := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
        V_ALL_TYPES.C_CHAR                        := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP                                                                                                                                                                                                                    ';
        V_ALL_TYPES.C_NCHAR                       := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP                                                                                                                                                                                                                    ';
        V_ALL_TYPES.C_RAW                         := 'E17276ED7A74FB72F574FC6BF67266FA72F367E970C15256CD5A54DB52D554DC4BD65246DA52D347C950';
        V_ALL_TYPES.C_INTERVAL_Y_M                := to_yminterval('+000000-01');
        V_ALL_TYPES.C_INTERVAL_D_S                := to_dsinterval('+000100 00:00:00.000000');
        V_ALL_TYPES.C_DATE                        := to_date('2020.06.12 13:30:08','yyyy.mm.dd hh24:mi:ss');
        V_ALL_TYPES.C_TIMESTAMP                   := to_timestamp('2020.06.12 13:30:08.625196000','yyyy.mm.dd hh24:mi:ss.ff');
        V_ALL_TYPES.C_TIMESTAMP_TZ                := to_timestamp_tz('2020.06.12 13:30:08.625203000 +02:00','yyyy.mm.dd hh24:mi:ss.ff TZR');
        V_ALL_TYPES.C_CLOB                        := (to_clob(utl_raw.cast_to_varchar2(hextoraw('E17276ED7A74FB72F574FC6BF67266FA72F367E970C15256CD5A54DB52D554DC4BD65246DA52D347C950'))));
        V_ALL_TYPES.C_BLOB                        := (to_blob(hextoraw('E17276ED7A74FB72F574FC6BF67266FA72F367E970C15256CD5A54DB52D554DC4BD65246DA52D347C950')));
        insert into ALL_TYPES values V_ALL_TYPES;
        commit;
    END;
    /
    

## Inside

The function contains ways to export and import for the most common data types.
But we can add any other to it.
For example I inserted the TU_NUMBER function because who knows what will be the decimal symbol on the target database!?


