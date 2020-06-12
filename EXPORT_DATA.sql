create or replace function EXPORT_DATA ( I_TABLE_NAME  in varchar2
                                       , I_WHERE       in varchar2 default null
                                       ) return T_STRING_LIST pipelined is
---------------------------------------------------------------------------
-- select * from table( EXPORT_DATA ( 'all_types' ) );
---------------------------------------------------------------------------

    V_BLOB                  blob;
    V_CLOB                  clob;
    V_CUR_SQL               varchar( 32000 );
    V_LOB_SQL               varchar( 32000 );
    V_RAW                   varchar( 32000 );
    V_START                 number;
    V_DATA                  sys_refcursor;
    V_CURSOR                integer;
    V_COLUMN_CNT            integer;
    V_DESC                  dbms_sql.desc_tab;
    V_TO_PIPE               varchar2( 32000 );
    V_TABLE_NAME            varchar2(    30 );
    V_STRING                varchar2( 32000 );
    V_NUMBER                number;
    V_DATE                  date;
    V_LONG                  long;
    V_LONG_RAW              long raw;
    V_INTERVAL_Y_M          interval year(6) to month;
    V_INTERVAL_D_S          interval day (6) to second;
    V_TIMESTAMP             timestamp;
    V_TIMESTAMP_TZ          timestamp with time zone;
    V_BFILE                 bfile;
    V_DIR_ALIAS             varchar2( 255 );
    V_FILE_NAME             varchar2( 255 );
    V_SPACES                varchar2( 255 ) := '                                                                                ';
    V_ANY_TYPE              ANYTYPE;
    V_ANY_DATA              ANYDATA;

    function TO_STRING( I_STRING in varchar2 ) return varchar2 is
        L_STRING varchar2(32000) := I_STRING;
    begin
        for I in 1..31 loop
            L_STRING := replace( L_STRING, chr( I ), ''' || chr( ' || to_char( I ) || ' ) || ''' );
        end loop;
        L_STRING := replace( L_STRING, '''', '''''' );
        L_STRING := '''' || L_STRING || '''';
        return L_STRING;
    end;

begin

    V_TABLE_NAME  := upper( trim( I_TABLE_NAME  ) );

    V_CUR_SQL := 'select * from '||V_TABLE_NAME||' where '||nvl( I_WHERE, ' 1 = 1 ');
    open V_DATA for V_CUR_SQL;
    V_CURSOR := dbms_sql.to_cursor_number( V_DATA );
    dbms_sql.describe_columns( V_CURSOR, V_COLUMN_CNT, V_DESC );

    for L_I in 1..V_COLUMN_CNT 
    loop

        --  VARCHAR2, NVARCHAR2, VARCHAR, CHAR, NCHAR, RAW
        if V_DESC( L_I ).col_type in ( 1, 23, 96 ) then      
            dbms_sql.define_column( V_CURSOR, L_I, V_STRING, 32000 ); 
      
        -- SMALLINT, INTEGER, REAL, DOUBLE, BIGDECIMAL ,NUMBER
        elsif V_DESC( L_I ).col_type in ( 2, 21, 22 ) then      
            dbms_sql.define_column( V_CURSOR, L_I, V_NUMBER        ); 
      
        -- DATE
        elsif V_DESC( L_I ).col_type = 12 then 
            dbms_sql.define_column( V_CURSOR, L_I, V_DATE          ); 
            
        -- TIMESTAMP
        elsif V_DESC( L_I ).col_type = 180 then       
            dbms_sql.define_column( V_CURSOR, L_I, V_TIMESTAMP     ); 

        -- TIMESTAMP_TZ
        elsif V_DESC( L_I ).col_type in ( 181, 231 ) then       
            dbms_sql.define_column( V_CURSOR, L_I, V_TIMESTAMP_TZ     ); 

        -- INTERVAL_Y_M
        elsif V_DESC( L_I ).col_type = 182 then       
            dbms_sql.define_column( V_CURSOR, L_I, V_INTERVAL_Y_M     ); 

        -- INTERVAL_D_S
        elsif V_DESC( L_I ).col_type = 183 then 
            dbms_sql.define_column( V_CURSOR, L_I, V_INTERVAL_D_S     ); 

        -- LONG
        elsif V_DESC( L_I ).col_type = 8 then 
            dbms_sql.define_column_long ( V_CURSOR, L_I ); 

        -- LONG_RAW
        elsif V_DESC( L_I ).col_type = 24  then 
--            dbms_sql.define_column ( V_CURSOR, L_I, V_LONG_RAW ); 
            null;

        -- BLOB
        elsif V_DESC( L_I ).col_type = 113 then 
            dbms_sql.define_column( V_CURSOR, L_I, V_BLOB     ); 

        -- CLOB
        elsif V_DESC( L_I ).col_type = 112 then 
            dbms_sql.define_column( V_CURSOR, L_I, V_CLOB     ); 

        -- BFILE
        elsif V_DESC( L_I ).col_type = 114 then 
            dbms_sql.define_column( V_CURSOR, L_I, V_BFILE     ); 

        end if; 
      
    end loop;

    while dbms_sql.fetch_rows( V_CURSOR ) > 0 
    loop 

        -- one row
        PIPE ROW( '------------------------------------------------------------------------------' );
        PIPE ROW( 'DECLARE' );
        PIPE ROW( '    V_'||V_TABLE_NAME||'    '||V_TABLE_NAME||'%rowtype;' );
        PIPE ROW( '    function TU_NUMBER( I_STRING in varchar2 ) return number is' );
        PIPE ROW( '        V_STRING    varchar2( 1000 ) := I_STRING;' );
        PIPE ROW( '        V_NUMBER    number;' );
        PIPE ROW( '    begin' );
        PIPE ROW( '        begin' );
        PIPE ROW( '            V_NUMBER := to_number( V_STRING );' );
        PIPE ROW( '        exception when others then' );
        PIPE ROW( '            V_STRING := translate( V_STRING, '',.'', ''.,'' );' );
        PIPE ROW( '            V_NUMBER := to_number( V_STRING );' );
        PIPE ROW( '        end;' );
        PIPE ROW( '        return V_NUMBER;' );
        PIPE ROW( '    end;' );
        PIPE ROW( 'BEGIN' );
        for L_I in 1..V_COLUMN_CNT 
        loop

            V_TO_PIPE := substr('    V_'||V_TABLE_NAME||'.'||V_DESC( L_I ).col_name||V_SPACES,1,70 )||':= ';

            --  VARCHAR2, NVARCHAR2, VARCHAR, CHAR, NCHAR, RAW
            if V_DESC( L_I ).col_type in ( 1, 23, 96 ) then 

                dbms_sql.column_value( V_CURSOR, L_I, V_STRING        ); 
                V_TO_PIPE  := V_TO_PIPE||TO_STRING( V_STRING )||';';
                PIPE ROW( V_TO_PIPE );

            -- SMALLINT, INTEGER, REAL, DOUBLE, BIGDECIMAL ,NUMBER
            elsif V_DESC( L_I ).col_type in ( 2, 21, 22 ) then 

                dbms_sql.column_value( V_CURSOR, L_I, V_NUMBER        ); 
                V_TO_PIPE  := V_TO_PIPE||'TU_NUMBER('''||trim( rtrim( to_char( V_NUMBER , 'FM9999999999999999999999990.999999999999999999999999999999' ), '.'  ) )||''');';
                PIPE ROW( V_TO_PIPE );

            -- DATE
            elsif V_DESC( L_I ).col_type = 12 then 

                dbms_sql.column_value( V_CURSOR, L_I, V_DATE          ); 
                V_TO_PIPE  := V_TO_PIPE||'to_date('''||to_char( V_DATE, 'yyyy.mm.dd hh24:mi:ss' )||''',''yyyy.mm.dd hh24:mi:ss'');';
                PIPE ROW( V_TO_PIPE );

            -- TIMESTAMP
            elsif V_DESC( L_I ).col_type = 180 then 
      
                dbms_sql.column_value( V_CURSOR, L_I, V_TIMESTAMP     ); 
                V_TO_PIPE  := V_TO_PIPE||'to_timestamp('''||to_char( V_TIMESTAMP, 'yyyy.mm.dd hh24:mi:ss.ff' )||''',''yyyy.mm.dd hh24:mi:ss.ff'');';
                PIPE ROW( V_TO_PIPE );

            -- TIMESTAMP_TZ
            elsif V_DESC( L_I ).col_type in ( 181, 231 ) then 
      
                dbms_sql.column_value( V_CURSOR, L_I, V_TIMESTAMP_TZ     ); 
                V_TO_PIPE  := V_TO_PIPE||'to_timestamp_tz('''||to_char( V_TIMESTAMP_TZ, 'yyyy.mm.dd hh24:mi:ss.ff TZR' )||''',''yyyy.mm.dd hh24:mi:ss.ff TZR'');';
                PIPE ROW( V_TO_PIPE );


            -- INTERVAL_Y_M
            elsif V_DESC( L_I ).col_type = 182 then 
      
                dbms_sql.column_value( V_CURSOR, L_I, V_INTERVAL_Y_M     ); 
                V_TO_PIPE  := V_TO_PIPE||'to_yminterval('''||to_char(V_INTERVAL_Y_M)||''');';
                PIPE ROW( V_TO_PIPE );

            -- INTERVAL_D_S
            elsif V_DESC( L_I ).col_type = 183 then 
      
                dbms_sql.column_value( V_CURSOR, L_I, V_INTERVAL_D_S     ); 
                V_TO_PIPE  := V_TO_PIPE||'to_dsinterval('''||to_char(V_INTERVAL_D_S)||''');';
                PIPE ROW( V_TO_PIPE );


            -- LONG
            elsif V_DESC( L_I ).col_type = 8 then 
      
                dbms_sql.column_value( V_CURSOR, L_I, V_LONG     ); 
                if nvl( dbms_lob.getlength( V_LONG ), 0 ) > 0 then
                    V_START := 1;
                    for L_J IN 1..ceil( dbms_lob.getlength( V_LONG ) / 100 )
                    loop
                        V_RAW     := dbms_lob.substr( V_LONG, 100, V_START );
                        V_STRING  := ''''||V_RAW||'''';
                        V_TO_PIPE := V_TO_PIPE||V_STRING||';';
                        PIPE ROW( V_TO_PIPE );
                        V_TO_PIPE := '    ||';
                        V_START := V_START + 100;
                    end loop;
                end if;

            -- LONG_RAW
            elsif V_DESC( L_I ).col_type = 24 then 
                null;
/*                dbms_sql.column_value( V_CURSOR, L_I, V_LONG_RAW     ); 
                if nvl( dbms_lob.getlength( V_LONG_RAW ), 0 ) > 0 then
                    V_START := 1;
                    for L_J IN 1..ceil( dbms_lob.getlength( V_LONG_RAW ) / 100 )
                    loop
                        V_RAW     := dbms_lob.substr( V_LONG_RAW, 100, V_START );
                        V_STRING  := ''''||V_RAW||'''';
                        V_TO_PIPE := V_TO_PIPE||V_STRING||';';
                        PIPE ROW( V_TO_PIPE );
                        V_TO_PIPE := '    ||';
                        V_START := V_START + 100;
                    end loop;
                end if;
  */              

            -- BLOB
            elsif V_DESC( L_I ).col_type = 113 then 

                dbms_sql.column_value( V_CURSOR, L_I, V_BLOB     ); 
                if nvl( dbms_lob.getlength( V_BLOB ), 0 ) > 0 then
                    V_START := 1;
                    V_TO_PIPE := V_TO_PIPE||'(';
                    for L_J IN 1..ceil( dbms_lob.getlength( V_BLOB ) / 100 )
                    loop
                        V_RAW     := dbms_lob.substr( V_BLOB, 100, V_START );
                        V_STRING  := 'to_blob(hextoraw('''||V_RAW||'''))';
                        V_TO_PIPE := V_TO_PIPE||V_STRING||');';
                        PIPE ROW( V_TO_PIPE );
                        V_TO_PIPE := '    dbms_lob.append(V_'||V_TABLE_NAME||'.'||V_DESC( L_I ).col_name||',';
                        V_START := V_START + 100;
                    end loop;
                end if;


            -- CLOB
            elsif V_DESC( L_I ).col_type = 112 then 

                dbms_sql.column_value( V_CURSOR, L_I, V_CLOB     ); 
                if nvl( dbms_lob.getlength( V_CLOB ), 0 ) > 0 then
                    V_START := 1;
                    V_TO_PIPE := V_TO_PIPE||'(';
                    for L_J IN 1..ceil( dbms_lob.getlength( V_CLOB ) / 100 )
                    loop
                        V_RAW   := UTL_RAW.CAST_TO_RAW( dbms_lob.substr( V_CLOB, 100, V_START ) );
                        V_STRING  := 'to_clob(utl_raw.cast_to_varchar2(hextoraw('''||V_RAW||''')))';
                        V_TO_PIPE := V_TO_PIPE||V_STRING||');';
                        PIPE ROW( V_TO_PIPE );
                        V_TO_PIPE := '    dbms_lob.append(V_'||V_TABLE_NAME||'.'||V_DESC( L_I ).col_name||',';
                        V_START := V_START + 100;
                    end loop;
                end if;

            -- BFILE
            elsif V_DESC( L_I ).col_type = 114 then 
      
                dbms_sql.column_value( V_CURSOR, L_I, V_BFILE     ); 
                dbms_lob.filegetname ( V_BFILE, V_DIR_ALIAS, V_FILE_NAME );
                V_TO_PIPE  := V_TO_PIPE||'BFILENAME('''||V_DIR_ALIAS||''','''||V_FILE_NAME||''');';
                PIPE ROW( V_TO_PIPE );

            else 

                V_TO_PIPE  := V_TO_PIPE||'''DT:'||to_char( V_DESC( L_I ).col_type )||''';';
                PIPE ROW( V_TO_PIPE );

            end if; 

    
        end loop; 


        PIPE ROW( '    insert into '||V_TABLE_NAME||' values V_'||V_TABLE_NAME||';' );
        PIPE ROW( '    commit;' );
        PIPE ROW( 'END;' );
        PIPE ROW( '/' );

    end loop; 

    dbms_sql.close_cursor( V_CURSOR ); 

end;
/



