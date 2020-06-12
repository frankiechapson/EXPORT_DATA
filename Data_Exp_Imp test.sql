
CREATE TABLE ALL_TYPES(
c_smallint              SMALLINT,
c_integer               INTEGER,
c_real                  REAL,
c_double                DOUBLE PRECISION,
c_bigdecimal            DECIMAL(13,0),
c_number                NUMBER(3,2),
c_varchar2              VARCHAR2(254),
c_nvarchar2             NVARCHAR2(254),
c_varchar               VARCHAR(254),
c_char                  CHAR(254),
c_nchar                 NCHAR(254),
c_raw                   RAW(2000),
c_interval_y_m          INTERVAL YEAR (3) TO MONTH,
c_interval_d_s          INTERVAL DAY (3) TO SECOND,
c_date                  DATE,
c_timestamp             TIMESTAMP(6),
c_timestamp_tz          TIMESTAMP(6) WITH TIME ZONE,
c_clob                  CLOB,
c_blob                  BLOB
);


------------------------------------------------------------------------------
DECLARE
    V_ALL_TYPES    ALL_TYPES%rowtype;
BEGIN
    V_ALL_TYPES.C_SMALLINT                                            := 1;
    V_ALL_TYPES.C_INTEGER                                             := 2;
    V_ALL_TYPES.C_REAL                                                := 33.1415;
    V_ALL_TYPES.C_DOUBLE                                              := 11;
    V_ALL_TYPES.C_BIGDECIMAL                                          := 22;
    V_ALL_TYPES.C_NUMBER                                              := 3;
    V_ALL_TYPES.C_VARCHAR2                                            := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_NVARCHAR2                                           := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_VARCHAR                                             := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_CHAR                                                := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_NCHAR                                               := 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP';
    V_ALL_TYPES.C_RAW                                                 := utl_raw.cast_to_raw( 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP' );
    V_ALL_TYPES.C_INTERVAL_Y_M                                        := TO_YMINTERVAL('0-1');
    V_ALL_TYPES.C_INTERVAL_D_S                                        := TO_DSINTERVAL('100 00:00:00');
    V_ALL_TYPES.C_DATE                                                := sysdate;
    V_ALL_TYPES.C_TIMESTAMP                                           := systimestamp;
    V_ALL_TYPES.C_TIMESTAMP_TZ                                        := systimestamp;
    V_ALL_TYPES.C_CLOB                                                := to_clob( 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP' );
    V_ALL_TYPES.C_BLOB                                                := utl_raw.cast_to_raw( 'árvíztűrőtükörfúrógépÁRVÍZTŰRŐTÜKÖRFÚRÓGÉP' );
    insert into ALL_TYPES values V_ALL_TYPES;
    commit;
END;
/

select * from table( EXPORT_DATA ( 'ALL_TYPES' ) );
