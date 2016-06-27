hostsFolder = INVOKE_DIR..'/hosts/'

--TODO probably should iterate over folders and extract this information so we don't need to keep it up to date
hosts = { 
    ["android"] = "host-android-studio",
    ["html"] = "host-html",
    ["ios"] = "host-ios",
    ["linux"] = "host-linux",
    ["osx"] = "host-osx-app",
    ["vs2013"] = "host-windows-vs2013",
    ["vs2015"] = "host-windows-vs2015"
  }

function printValidHosts()
  print("Available Hosts:")
  local allHosts = {}
  for k,v in pairs(hosts) do
    table.insert(allHosts, k)
  end
  table.sort(allHosts)
  for _,v in pairs(allHosts) do
    print("  "..v)
  end
end

function hostAlreadyCreated(hostname)
  return MOAIFileSystem.checkPathExists(hostsFolder..hostname)
end

function canCreateHost(hostname)
  return hosts[hostname] ~= nil 
end

function command_error(message)
  print()
  print("ERROR: "..message)
  print()
  os.exit(1)
end

function confirm(message)
  io.write(message)
  local answer
  while true do
    io.write("\nContinue [y/n]?")
    answer=io.read()
    if answer=="y" then
       return true
    elseif answer=="n" then
       return false
    end
  end
end

function hasConfig()
  return MOAIFileSystem.checkFileExists("hostconfig.lua")
end

function ensureHostConfig()
  if (not hasConfig()) then
    command_error("this command must be run from a project folder containing hostconfig.lua\nYou can create one using pito host init\n")
  end
end


local subcommand = arg[4]
hostname = arg[5]

if (subcommand == "" or subcommand == nil) then
  usage("host")
  return
end


--all our subcommands are relative to invoke dir
MOAIFileSystem.setWorkingDirectory(INVOKE_DIR)

if MOAIFileSystem.checkFileExists(SCRIPT_DIR..subcommand..'.lua') then
  dofile(SCRIPT_DIR..subcommand..'.lua')
else
  print('host command "'..subcommand..'" not found')
  usage("host")
end

os.exit(0)




