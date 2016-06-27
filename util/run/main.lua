package.path = package.path..';'..SCRIPT_DIR..'?.lua'
MOAIFileSystem.setWorkingDirectory(INVOKE_DIR)

HOSTS_FOLDER = INVOKE_DIR..'/hosts'
io.stdout:setvbuf('no')


function command_error(message)
  print()
  print("ERROR: "..message)
  print()
  os.exit(1)
end

local START_FILE = MOAIFileSystem.getAbsoluteFilePath("src/main.lua")
local runtype = 'desktop'
local activity = false
local package = false
for i, escape, param, iter in util.iterateCommandLine ( arg or {}) do
  
	if (param) then
    if escape == 's' or escape == 'start' then
      START_FILE = MOAIFileSystem.getAbsoluteFilePath(param)
    end
    if escape == 'p' or escape == 'package' then
      package = MOAIFileSystem.getAbsoluteDirectoryPath(param)
    end
    if escape == 'activity' then
      activity = param
    end
    
	end
  if escape == 'a' or escape == 'android' then
      runtype = 'android'
  end
end
--sanity check
assert(MOAIFileSystem.checkFileExists(START_FILE), "Could not find specified start file: "..tostring(START_FILE))




-- default is to run desktop version
local srcdir = util.getFolderFromPath(START_FILE)
local srcFile = util.getFilenameFromPath(START_FILE)


function getTempDir()
  local tempdir = false
  if MOAIEnvironment.osBrand == 'Windows' then
     tempdir = os.getenv("TEMP") or os.getenv("TMP")
  else
     tempdir = "/tmp"
  end
  assert(tempdir, "Could not file temp directory")
  
  tempdir = MOAIFileSystem.getAbsoluteDirectoryPath(tempdir)
  math.randomseed( os.time() )
  --now append some random stuff
  tempdir = tempdir.."pitoApkRun-"..tostring(math.random(1000000))
  
  MOAIFileSystem.affirmPath(tempdir)
  assert(MOAIFileSystem.checkPathExists(tempdir),"Could not create temp dir at "..tostring(tempdir))
  return MOAIFileSystem.getAbsoluteDirectoryPath(tempdir)
end



if (runtype == 'android') then
   --run android
   if package and not MOAIFileSystem.checkFileExists(package) then
      error("Apk specified was not found")
   end
   
   if not package then
     -- find host package
     package = HOSTS_FOLDER..'/android/moai/build/outputs/apk/moai-debug.apk'
     if not MOAIFileSystem.checkFileExists(package) then
       package = PITO_HOME..'/lib/android/apk/moai-debug.apk'
       if not MOAIFileSystem.checkFileExists(package) then
         error("Could not find a suitable apk to launch, either it needs to be built or you need -p")
       end
     end
   end
   
   local android = require('lib.android-helper')()
   assert(android.sdkPath, "Could not determine path to android SDK, try setting ANDROID_SDK_HOME")
   assert(android.javaPath, "Could not determine path to Java, try setting JAVA_HOME")
   assert(android:adbBin(), "Could not determine location of adb binary")
   assert(android:latestBuildToolsPath(), "Could not determine the latest build tools path in the android sdk")
   print("Building new apk using",package,"as a base")
   
   local tempdir = getTempDir()
   local apktmp = MOAIFileSystem.getAbsoluteDirectoryPath(tempdir.."/apkSrc")
   MOAIFileSystem.affirmPath(apktmp)
   
   --extract
   print("Extracting apk")
   assert(android:extractApk(package, apktmp), "Could not extract src apk:"..tostring(package))
   --unsign
   print("Unsigning apk")
   local signDir = MOAIFileSystem.getAbsoluteDirectoryPath(apktmp.."META-INF")
   if MOAIFileSystem.checkPathExists(signDir) then
     assert(MOAIFileSystem.deleteDirectory(apktmp.."META-INF", true), "Could not delete signing information from src apk:"..tostring(signDir))
   end
   print("Copying assets")
   --overwrite assets (keep in mind that this doesn't remove unused assets)
   local srcOut = apktmp..'assets/'
   MOAIFileSystem.affirmPath(srcOut)
   assert(MOAIFileSystem.copy(srcdir, srcOut),"could not copy assets into apk dir: "..tostring(srcDir).."->"..tostring(srcOut))
   
   if (string.lower(srcFile) ~= "main.lua") then
    print("Patching start file")
    assert(MOAIFileSystem.checkFileExists(srcOut.."bootstrap.lua"), "Unable to set custom start file "..tostring(srcFile).." could not find bootstrap.lua in"..tostring(srcOut))
    util.replaceInFiles ({
     [ srcOut.."bootstrap.lua"] = {
        ['main%.lua'] = srcFile,
      }
     })
  end
  
  print ("Compressing apk")
  local unalignedApk = MOAIFileSystem.getAbsoluteFilePath(tempdir.."pito-unaligned.apk")
  local alignedApk = MOAIFileSystem.getAbsoluteFilePath(tempdir.."pito-run.apk")
  assert(android:createApk(apktmp, unalignedApk), "could not create apk from src: "..tostring(apktmp).."->"..tostring(unalignedApk))
  
  print ("signing apk")
  assert(android:signApk(unalignedApk),"could not sign apk")
  
  print ("verify apk")
-- assert(android:verifyApk(unalignedApk),"verification of apk failed")
  
  print ("zipalign apk")
  MOAIFileSystem.deleteFile(alignedApk)
  assert(android:zipAlign(unalignedApk, alignedApk),"zip align failed")
  
  print ("installing apk")
  assert(android:installApk(alignedApk), "failed to install apk")
  
  print ("running apk")
  local mainActivity = activity or android:getApkMainActivity(alignedApk)
  assert(mainActivity, "failed to determine the main activity from parsing the manifest in the apk, please provide one with --activity")
  android:runActivity(mainActivity)

  return
elseif (runtype ~= 'desktop') then
  command_error("unsupported run type "..tostring(runtype))
end



if not MOAIFileSystem.setWorkingDirectory(srcdir) then
  command_error("Could not change into src dir:"..srcdir)
end

print ("Launching "..srcdir..srcFile)

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
    print("\nOutput:\n")
    print(moai..' "'..srcFile..'"')
    os.execute(moai..' "'..srcFile..'"')
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
   print("\nOutput:\n")
   os.execute(moai..' "'..srcFile..'"')
end

function runOsx()
  local moai = MOAIFileSystem.getAbsoluteFilePath(PITO_HOME)..'/bin/moai'
  print("Running bundled Moai")
  print("\nOutput:\n")
  os.execute(moai..' "'..srcFile..'"')
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





