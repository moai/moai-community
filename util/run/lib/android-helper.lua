local M = {}
local M_mt = { __index = M }



function M:findJava()
  local fromenv = os.getenv("JAVA_HOME")
  if fromenv then return MOAIFileSystem.getAbsoluteDirectoryPath(fromenv.."/bin") end
  
  return false
end
function M:findAndroidSdk()
  local fromenv = os.getenv("ANDROID_SDK_ROOT") or os.getenv("ANDROID_HOME") or os.getenv("ANDROID_SDK_HOME")
  if fromenv then return fromenv end
  
  
  if MOAIEnvironment.osBrand == 'Windows' then
    local appdata = os.getenv("LOCALAPPDATA")
    if (appdata and MOAIFileSystem.checkPathExists(appdata.."\\android\\sdk")) then
      return MOAIFileSystem.getAbsoluteDirectoryPath(appdata.."\\android\\sdk")   
    end
  elseif MOAIEnvironment.osBrand == 'Linux' then
    local home = os.getenv("HOME")
    local sdkpath = home.."/android-sdk-linux"
    if (home and MOAIFileSystem.checkPathExists(sdkpath)) then
      return sdkpath
    end
  else
    local home = os.getenv("HOME")
    if (home and MOAIFileSystem.checkPathExists(home.."/Library/Android/sdk")) then
      return home.."/Library/Android/sdk"
    end 
  end
  
  return false
end


function M:latestBuildToolsPath()
  local buildToolsRoot = MOAIFileSystem.getAbsoluteDirectoryPath(self.sdkPath.."/build-tools")
  local files = MOAIFileSystem.listDirectories(buildToolsRoot)
  if #files > 0 then
    local currentBest = ""
    local currentVersion = 0
    for _,v in ipairs(files) do
       local major,minor,build = v:match("(%d-)%.(%d-)%.(%d+)")
       if major then
          local thisversion = major*1000000+minor*1000+build
          if thisversion > currentVersion then
            currentVersion = thisversion
            currentBest = v
          end
       end
    end
    if currentVersion > 0 then
      return MOAIFileSystem.getAbsoluteDirectoryPath(buildToolsRoot.."/"..currentBest)
    end
    return false
  else
    return false
  end
end

function M:adbBin()
  local adbExecutable = "adb"
  if MOAIEnvironment.osBrand == 'Windows' then
    adbExecutable = "adb.exe"
  end
  return MOAIFileSystem.getAbsoluteFilePath(self.sdkPath.."/platform-tools/"..adbExecutable)
end


return function()
  local obj = {}
  setmetatable(obj,M_mt)
  obj.sdkPath = obj:findAndroidSdk()
  obj.javaPath = obj:findJava()
  return obj
end
