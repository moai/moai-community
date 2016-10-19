--==============================================================
-- args
--==============================================================

VERSION = dofile ( MOAI_SDK_HOME..'/util/sdk-version/version.lua' )


print ( string.format ( 'MOAI SDK VERSION IS %d.%d.%d', VERSION.MAJOR, VERSION.MINOR, VERSION.REVISION or -1 ))
