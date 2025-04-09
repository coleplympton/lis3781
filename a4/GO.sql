-- Populate person table with hashed and salted SSN numbers. *MUST* include salted value in DB!
CREATE PROC dbo.CreatePersonSSN
AS
BEGIN
    DECLARE @salt binary(64);
    DECLARE @ran_num int;
    DECLARE @ssn binary(64);
    DECLARE @x INT, @y INT;
    SET @x = 1;

    -- dynamically set loop ending value (total number of persons)
    SET @y = (select count(*) from dbo.person);
    -- select @y; -- display number of persons (only for testing)

    WHILE (@x <= @y)
    BEGIN
        -- give each person a unique randomized salt, and hashed and salted randomized SSN.
        -- Note: this demo is *only* for showing how to include salted and hashed randomized values for testing purposes!
        -- function returns a cryptographic, randomly-generated hexadecimal number with length of specified number of bytes
        -- https://docs.microsoft.com/en-us/sql/t-sql/functions/crypt-gen-random-transact-sql?view=sql-server-2017
        SET @salt=CRYPT_GEN_RANDOM(64); -- salt includes unique random bytes for each user when looping
        SET @ran_num=FLOOR(RAND()*(999999999-111111111+1))+111111111; -- random 9-digit SSN from 111111111 - 999999999, inclusive (see link below)
        SET @ssn=HASHBYTES('SHA2_512', concat(@salt, @ran_num));

        -- select @salt, len(@salt), @ran_num, len(@ran_num), @ssn, len(@ssn); -- only for testing values

        -- RAND([N]): Returns random floating-point value v in the range 0 <= v < 1.0
        -- Documentation: https://www.techonthenet.com/sql_server/functions/rand.php
        -- randomize ssn between 111111111 - 999999999 (note: using value 000000000 for ex. 4 below)

        update dbo.person
        set per_ssn = @ssn, per_salt=@salt
        where per_id=@x;

        SET @x = @x + 1;
    END;
END;
GO

exec dbo.CreatePersonSSN