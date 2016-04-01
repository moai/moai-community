package.path = package.path..';'..SCRIPT_DIR..'?.lua'
MOAIFileSystem.setWorkingDirectory(INVOKE_DIR)

HOSTS_FOLDER = INVOKE_DIR..'/hosts'

function command_error(message)
  print()
  print("ERROR: "..message)
  print()
  os.exit(1)
end

local SRC_DIR = MOAIFileSystem.getAbsoluteDirectoryPath("src")
local runtype = 'desktop'
local package = false
for i, escape, param, iter in util.iterateCommandLine ( arg or {}) do
  
	if (param) then
    if escape == 's' or escape == 'src' then
      SRC_DIR = MOAIFileSystem.getAbsoluteDirectoryPath(param)
    end
    if escape == 'p' or escape == 'package' then
      package = MOAIFileSystem.getAbsoluteDirectoryPath(param)
    end
	end
  if escape == 'a' or escape == 'android' then
      runtype = 'android'
  end
end







if (runtype == 'android') then
   --run android
   if package and not MOAIFileSystem.checkFileExists(package) then
      error("Apk specified was not found")
   end
   
   if not package then
     --find host package
     package = HOSTS_FOLDER..'/android/moai/build/outputs/apk/moai-debug.apk'
     if not MOAIFileSystem.checkFileExists(package) then
       package = PITO_HOME..'/lib/android/apk/moai-debug.apk'
       if not MOAIFileSystem.checkFileExists(package) then
         error("Could not find a suitable apk to launch, either it needs to be built or you need -p")
       end
     end
   end
   
   
   
   
   local android = require('lib.android-helper')()
    print("sdk path",android.sdkPath)
    print("java path",android.javaPath)
    print("adb bin",android:adbBin())
    print("latest build tools", android:latestBuildToolsPath())
    print("using apk",package)
   
   
   return
elseif (runtype ~= 'desktop') then
  command_error("unsupported run type "..tostring(runtype))
end


-- default is to run desktop version

if not MOAIFileSystem.setWorkingDirectory(SRC_DIR) then
  command_error("Could not change into src dir")
end

function runWindows()
    local moai = 'moai'
    local vs2015moai = HOSTS_FOLDER..'/vs2015/Debug/Moai.exe'
    local vs2013moai = HOSTS_FOLDER..'/vs2013/Debug/Moai.exe'
    
    if MOAIFileSystem.checkFileExists(vs2015moai) then
      moai = vs2015moai
      print("Running custom host: "..vs2015moai)
    elseif MOAIFileSystem.checkFileExists(vs2013moai) then
      moai = vs2013moai
      print("Running custom host: "..vs2013moai)
    else
      print("Running bundled Moai")
    end
    
    os.execute(moai..' main.lua')
end

function runLinux()
   -- TODO execute custom host if found
   local moai = 'moai'
   local custommoai = HOSTS_FOLDER..'/linux/build/debug/moai'
   if MOAIFileSystem.checkFileExists(custommoai) then
     print("Running custom host: "..custommoai)    
     moai = custommoai
   else
     print("Running bundled Moai")
   end
   os.execute(moai..' main.lua')
end

function runOsx()
  print("Running bundled Moai")
  os.execute(moai..' main.lua')
end



--which host
if (MOAIEnvironment.osBrand == 'Windows') then
	runWindows()
elseif (MOAIEnvironment.osBrand == 'Linux') then
	runLinux()
else
	runOsx()
end

MOAIFileSystem.setWorkingDirectory(INVOKE_DIR)





