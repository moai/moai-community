require ( 'util' )
require ( 'http' )

--==============================================================
-- setup
--==============================================================

INVOKE_DIR      = MOAIFileSystem.getAbsoluteDirectoryPath ( arg [ 1 ])
MOAI_SDK_HOME   = MOAIFileSystem.getAbsoluteDirectoryPath ( arg [ 2 ])
MOAI_CMD        = arg [ 3 ]
SCRIPT_DIR      = string.format ( '%sutil/%s/', MOAI_SDK_HOME, MOAI_CMD or "help" )

local usageText={}
usageText["wut"] = [[
    pito wut
        Contemplate your pito.
]]

usageText["environment"] = [[
    pito environment 
        This command will give you the needed environment variables to use pito.
        Example:
            /absolute/path/to/moai_sdk/util/pito environment
            (Follow instructions)
]]

usageText["host"] = [[
    pito host <subcommand> <args>
        Subcommands:
            host list - Lists available hosts
            host init - Creates a template host config file used by subsequent commands
            host build <hostname>  - Creates (if it doesn't exist) in hosts folder, and 
                                     (re)builds the host named <hostname>. 
            host run <hostname>    - Creates (if it doesn't exists) in hosts folder, 
                                     (re)builds and runs the host named <hostname>. 
            host create <hostname> - Creates the host in the hosts folder (removing old 
                                     host) based on latest config settings.
        Example:
            cd newMOAIProject && pito host create ios && \
                                 pito host create android-studio && \
                                 pito host create host osx-app && #etc.
]]

usageText["build-sample-browser"] = [[
    pito build-sample-browser
        Builds a local copy of the samples that can be viewed by modern browser
        -o <output-dir> : defaults to ./sample-browser
]]

usageText["sdk-version"] = [[
    pito sdk-version
        Obtain the MOAI SDK Version info for the current configuration.
]]

function usage(subSection)
    print ("pito - the MOAI toolbelt - ", subSection or "general usage:")
    if (subSection) and (usageText[subSection])  then
        print(usageText[subSection])
    else
        for i,v in pairs(usageText) do
            print(v)
        end
    end
end

MOAIFileSystem.setWorkingDirectory ( SCRIPT_DIR )

if MOAIFileSystem.checkFileExists('main.lua') then
    dofile ( 'main.lua' )
else
    usage()
end

