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
  local adbExecutable = "adb"..self.exeExt
  return MOAIFileSystem.getAbsoluteFilePath(self.sdkPath.."/platform-tools/"..adbExecutable)
end

function M:jarCommand(args)
  local jar = self.javaPath.."jar"..self.exeExt
  local cmd = string.format('"%s" %s', jar, args);
  
  if (MOAIEnvironment.osBrand == 'Windows') then cmd = '"'..cmd..'"' end
  
  return os.execute(cmd)
end


function M:jarsignerCommand(args)
  local jar = self.javaPath.."jarsigner"..self.exeExt
  local cmd = string.format('"%s" %s', jar, args);
  
  if (MOAIEnvironment.osBrand == 'Windows') then cmd = '"'..cmd..'"' end
  
  return os.execute(cmd)
end

function M:adbCommand(args)
  local adb  = self:adbBin()
  local cmd = string.format('"%s" %s', adb, args);
  
  if (MOAIEnvironment.osBrand == 'Windows') then cmd = '"'..cmd..'"' end
  
  return os.execute(cmd)
end



function M:extractApk(apk, dest)
  local oldworkdir = MOAIFileSystem.getWorkingDirectory()
  MOAIFileSystem.setWorkingDirectory(dest)
  local result = self:jarCommand('xf "'..apk..'"')
  MOAIFileSystem.setWorkingDirectory(oldworkdir)
  return result
end

function M:createApk(apksrc, destApk)
  local oldworkdir = MOAIFileSystem.getWorkingDirectory()
  MOAIFileSystem.setWorkingDirectory(apksrc)
  local result = self:jarCommand('cf "'..destApk..'" .')
  MOAIFileSystem.setWorkingDirectory(oldworkdir)
  return result
end

function M:signApk(apk, keystore, storepass, alias)
  
  
  if not keystore then
    local home = false
    if MOAIEnvironment.osBrand == 'Windows' then
      home = os.getenv("USERPROFILE")
    else
      home = os.getenv("HOME")
    end
    if not home then
      print("No keystore found. Could not find $HOME path")
      return false
    end
    home = MOAIFileSystem.getAbsoluteDirectoryPath(home)
    keystore = MOAIFileSystem.getAbsoluteFilePath(home..".android/debug.keystore")
    storepass = "android"
    alias = "androiddebugkey"
  end
  
  
  print("Signing apk with debug key from "..keystore)
  if not MOAIFileSystem.checkFileExists(keystore) then
    print("no key found at "..keystore)
    return false
  end
  
  local cmd = string.format('--verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "%s" -storepass "%s" "%s" "%s"', keystore, storepass, apk, alias)
  return self:jarsignerCommand(cmd)
end

function M:verifyApk(apk)
  return self:jarsignerCommand(string.format("-verify %s",apk))
end

function M:zipAlign(apk,dstapk)
  local buildtoolpath = self:latestBuildToolsPath()
  if not buildtoolpath then
    print("Could not find build tools do you have build tools installed")
    return false
  end
  
  local zipalign = MOAIFileSystem.getAbsoluteFilePath(string.format("%s/%s",buildtoolpath,"zipalign"..self.exeExt))
  if not (MOAIFileSystem.checkFileExists(zipalign)) then
    print("Could not find zipalign binary in build tools: ",zipalign)
    return false
  end
    
  local cmd = string.format('"%s" -v 4 "%s" "%s"',zipalign,apk,dstapk)
    
  if (MOAIEnvironment.osBrand == 'Windows') then cmd = '"'..cmd..'"' end
  
  return os.execute(cmd)

end

function M:installApk(apk,device)
  local devicearg = device and string.format("-s %s",device) or ""
  local args = string.format('%s install -r "%s"',devicearg, apk)
  return self:adbCommand(args)
end


local function os_capture(cmd)
  local f = io.popen(cmd, 'r')
  if not f then return "" end
  local s = f:read('*a')
  f:close()
  return s
end

function M:dumpManifest(apk)
  local buildtoolpath = self:latestBuildToolsPath()
  if not buildtoolpath then
    print("Could not find build tools do you have build tools installed")
    return false
  end
  local aapt = MOAIFileSystem.getAbsoluteFilePath(string.format("%s/%s",buildtoolpath,"aapt"..self.exeExt))
  if not (MOAIFileSystem.checkFileExists(aapt)) then
    print("Could not find aapt binary in build tools: ",aapt)
    return false
  end
  
  local cmd = string.format('"%s" d xmltree "%s" AndroidManifest.xml"',aapt, apk)
  if (MOAIEnvironment.osBrand == 'Windows') then cmd = '"'..cmd..'"' end
  --get contents of file and return
  return os_capture(cmd)
end

function M:parseManifest(apk)
  
  local man = self:dumpManifest(apk)
  if not man then
    return false 
  end
  
  local oldDepth = ""
  local rootNode = { name="ROOT", attributes = {}, children = {} }
  local depthNodes = {["  "] = rootNode}
  local currentNode = rootNode
  
  for line in man:gmatch("[^\r\n]+") do 
    local depth, nodeType, value = line:match("( -)([AEN]+): (.+)")
    if depth ~= oldDepth then
      currentNode = depthNodes[depth]
      assert(currentNode, "Could not find parent for xml output line")
      oldDepth = depth
    end
    
    if nodeType == "A" or nodeType == "N"  then
      local name,avalue = value:match("(.-)=(.+)")
      name = name:match("(.-)%(.-%)") or name
      currentNode.attributes[name] = avalue:match('"(.+)" %(Raw: .-%)') or avalue
    end
    if nodeType == "E"  then
      --make new node
      local newNode = { name=value:match("(.-) %(.-%)") , attributes = {}, children = {} }
      depthNodes[depth.."  "] = newNode
      table.insert(currentNode.children,newNode)
    end
  end
  
  return rootNode

end


function M:getApkMainActivity(apk)
  local man = self:parseManifest(apk)
  if not man then return false end
  
  local function where(tab, func)
    local res = {}
    for k,v in ipairs(tab) do
      if func(v) then table.insert(res,v) end
    end
    return res
  end
  
  local function childrenByName(node, name)
    local res = {}
    if not node then return res end
    return where(node.children, function(c) return c.name == name end)
  end
  
  local function childByName(node, name)
      return childrenByName(node, name)[1]
  end
  
  local manifest = childByName(man,'manifest')
  if not manifest then return false end
  
  local package = manifest.attributes['package']
  
  local application = childByName(manifest, 'application')
  
  local mainactivity = where(childrenByName(application,'activity'), function(act)
      local intentfilters = childrenByName(act,'intent-filter')
      local mainIntents = where(intentfilters, function(int)
          local action = childrenByName(int,"action")[1]
          return action and action.attributes['android:name'] == 'android.intent.action.MAIN'
      end)
      return #mainIntents > 0
  end)[1]
  
  if package and mainactivity and mainactivity.attributes['android:name'] then
    return string.format("%s/%s",package, mainactivity.attributes['android:name'])  
  else
    return false
  end
  
  
end

--[[
C:\Users\David\AppData\Local\Temp\pitoApkRun-794207\apkSrc>C:\Users\David\AppData\Local\Android\sdk\build-tools\23.0.1\aapt.exe d xmltree ..\pito-run.apk AndroidManifest.xml
N: android=http://schemas.android.com/apk/res/android
  E: manifest (line=2)
    A: android:versionCode(0x0101021b)=(type 0x10)0x1
    A: android:versionName(0x0101021c)="1.0" (Raw: "1.0")
    A: package="com.moaiforge.moaidebugger" (Raw: "com.moaiforge.moaidebugger")
    A: platformBuildVersionCode=(type 0x10)0x16 (Raw: "22")
    A: platformBuildVersionName="5.1.1-1819727" (Raw: "5.1.1-1819727")
    E: uses-sdk (line=7)
      A: android:minSdkVersion(0x0101020c)=(type 0x10)0x11
      A: android:targetSdkVersion(0x01010270)=(type 0x10)0x16
    E: uses-permission (line=11)
      A: android:name(0x01010003)="android.permission.ACCESS_NETWORK_STATE" (Raw: "android.permission.ACCESS_NETWORK_STATE")
    E: application (line=13)
      A: android:theme(0x01010000)=@0x7f0b0004
      A: android:label(0x01010001)=@0x7f0a0012
      A: android:icon(0x01010002)=@0x7f02004d
      A: android:debuggable(0x0101000f)=(type 0x12)0xffffffff
      A: android:allowBackup(0x01010280)=(type 0x12)0xffffffff
      E: activity (line=18)
        A: android:label(0x01010001)=@0x7f0a0012
        A: android:name(0x01010003)="com.moaisdk.moai.MainActivity" (Raw: "com.moaisdk.moai.MainActivity")
        E: intent-filter (line=21)
          E: action (line=22)
            A: android:name(0x01010003)="android.intent.action.MAIN" (Raw: "android.intent.action.MAIN")
          E: category (line=24)
            A: android:name(0x01010003)="android.intent.category.LAUNCHER" (Raw: "android.intent.category.LAUNCHER")
            ]]--
            
function M:runActivity(activity,device)
  --TODO parse that crap above and get package name, and MainActivity.
  --Maybe for now we just use package, since mainactivity is kept the same for pito
  local devicearg = device and string.format("-s %s",device) or ""
  local args = string.format('%s shell am start -a android.intent.action.MAIN -n %s',devicearg, activity)
  return self:adbCommand(args)
end



return function()
  local obj = {}
  setmetatable(obj,M_mt)
  obj.sdkPath = obj:findAndroidSdk()
  obj.javaPath = obj:findJava()
  obj.exeExt =  MOAIEnvironment.osBrand == 'Windows' and '.exe' or ''
  return obj
end
