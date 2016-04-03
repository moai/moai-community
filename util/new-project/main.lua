
MOAIFileSystem.setWorkingDirectory(INVOKE_DIR)

local projectName = arg[4]

--sanity check (no spaces in path or name)
if string.find(projectName, " ") then
   print("\nERROR: Project name can't contain spaces. It breaks NDK\n") 
   os.exit(1)
end

if string.find(INVOKE_DIR, " ") then
   print("\nERROR: Project directory name can't contain spaces. It breaks NDK\n") 
   os.exit(1)
end

if not projectName or (projectName == "") then
   print("\nERROR: You must provide a project name (no spaces)\n") 
   os.exit(1)
end

local fullProjectPath = MOAIFileSystem.getAbsoluteDirectoryPath(projectName)
if MOAIFileSystem.checkPathExists(fullProjectPath) then
   print("\nERROR: A folder with that name already exists\n") 
   os.exit(1)
end

print("\nCreating project : "..projectName.."\n\n")

MOAIFileSystem.affirmPath(fullProjectPath)
MOAIFileSystem.affirmPath(fullProjectPath..'/src')

--copy some sample

if not MOAIFileSystem.copy(MOAI_SDK_HOME.."/samples/hello-moai", fullProjectPath..'/src') then
   print("\nERROR: could not copy sample files. Is the sdk installed properly?\n") 
   os.exit(1)
end




MOAIFileSystem.setWorkingDirectory(MOAIFileSystem.getAbsoluteDirectoryPath(projectName));
local cmd = string.format('"%sbin/pito" host init',MOAIFileSystem.getAbsoluteDirectoryPath(PITO_HOME))
os.execute(cmd)

util.replaceInFiles ({
	  
    [ 'hostconfig.lua'] = {
      [ 'AppName = "[^"]+"']= 'AppName = "'..projectName..'"',
      [ 'ApplicationId = "[^"]+"']= 'ApplicationId = "com.example.anonymousmoaidev.'..projectName..'"',
    }
    })

print("\n\nProject created and initialized.\n\n Run moai from src directory, or create hosts with pito host create ...\n\n")


