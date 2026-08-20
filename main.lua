require "import"
import "android.content.Context"
import "android.content.Intent"
import "android.net.Uri"
import "android.provider.ContactsContract"
import "android.speech.SpeechRecognizer"
import "android.speech.RecognitionListener"
import "android.speech.RecognizerIntent"
import "android.os.Handler"
import "android.content.pm.PackageManager"
import "android.hardware.camera2.*"
import "android.bluetooth.BluetoothAdapter"
import "android.media.AudioManager"
import "android.provider.Settings"
import "android.widget.*"
import "android.view.*"
import "android.content.IntentFilter"
import "android.os.BatteryManager"
import "android.app.SearchManager"
import "java.lang.System"
import "java.io.File"
import "android.graphics.Typeface"
import "android.provider.MediaStore"
import "android.media.MediaRecorder"
import "android.os.Environment"
import "android.view.WindowManager"
import "java.util.Locale"
import "android.app.*"
import "android.speech.tts.TextToSpeech"
import "android.os.Vibrator"
import "android.os.VibrationEffect"
import "java.lang.String"
import "com.androlua.LuaDialog"
import "com.androlua.Http"
import "android.os.Looper"
import "android.view.accessibility.AccessibilityNodeInfo"
import "android.graphics.Rect"
import "android.text.InputType"

local CONSTANTS = {
    VERSION = "1.1",
    PREF_NAME = "Hanzla_Final_Safety_V7_Enhanced",
    DELAYS = {
        SUPER_FAST = 300, VERY_FAST = 400, FAST = 600, SHORT = 800,
        MEDIUM = 1200, NORMAL = 1500, LONG = 2000, VERY_LONG = 3500,
        BUTTON_WAIT = 1800, BUTTON_LONG_WAIT = 3000, APP_OPEN_WAIT = 3000,
    }
}
CURRENT_VERSION = CONSTANTS.VERSION

local DEFAULT_COMMANDS = {
    ["assistant setting"] = "assistant setting", ["command list"] = "command list",
    ["restart screen reader"] = "rs", ["turn off screen reader"] = "tf",
    ["current battery"] = "current battery", ["current time"] = "current time",
    ["current date"] = "current date", ["accessibility settings"] = "accessibility settings",
    ["how to use"] = "how to use", ["send now"] = "send now", ["uninstall"] = "uninstall",
    ["remove application"] = "remove application", ["clear chat"] = "clear chat",
    ["delete from everyone"] = "delete from everyone", ["delete from me"] = "delete from me",
    ["delete now"] = "delete now", ["delete number"] = "delete number",
    ["application info"] = "application info", ["voice call"] = "voice call",
    ["video call"] = "video call", ["chat"] = "chat", ["call"] = "call",
    ["search on youtube"] = "search on youtube", ["search on spotify"] = "search on spotify",
    ["search on google"] = "search on google", ["search on play store"] = "search on play store",
    ["search on youtube music"] = "search on youtube music", ["open"] = "open",
    ["toggle bluetooth"] = "toggle bluetooth", ["toggle flashlight"] = "toggle flashlight",
    ["toggle mobile data"] = "toggle mobile data", ["toggle wifi"] = "wf",
    ["toggle silent mode"] = "toggle silent",
    ["only admin mode"] = "only admin mode", ["mention all"] = "mention all", ["rename it"] = "rename it",
    ["brightness"] = "brightness", ["stop listening"] = "stop listening",
    ["spell this"] = "spell this", ["find"] = "find",
    ["share and copy"] = "share and copy", ["delete status"] = "delete status",
    ["clear call history"] = "clear call history", ["switch account"] = "switch account"
}

local FUNCTIONS_LIST = {
    "Main menu", "Recognition menu", "Current per-app gestures menu", "Functions menu", 
    "Screen reader settings", "Enable logging", "Gesture scheme description", 
    "Suspend browse by touch", "Suspend speech feedback and browse by touch", 
    "Disable hotkeys", "Lock touch", "Enable curtain", "Suspend edge gestures", 
    "Suspend main TTS engine", "Suspend secondary TTS engine", "Earpiece mode", 
    "Toggle multi-finger gestures", "Select TTS engine", "Switch the currently used TTS engine", 
    "Increase accessibility volume", "Decrease accessibility volume", "Increase speech rate", 
    "Decrease speech rate", "Increase media volume", "Decrease media volume", 
    "Voice assistant", "Voice dictation", "Actions", "Open an URL", 
    "Monitor the currently focused element", "Focus monitor manager", "Edit dictionary", 
    "Edit node alias", "Add content blacklist", "Spell current focus", 
    "Granular browsing mode", "Edit current Per-App gesture scheme", "Automatic translation", 
    "Recognize subtitles", "Automatically use OCR", "Virtual screen", "Identify form", 
    "Recognize text on the current screen", "Recognize text of the current focused element", 
    "Get CAPTCHA", "Translation", "Jieshuo Camera", "Current time", "Timer", "Pause timer", 
    "Current location", "Speak current lighting", "Speak time and battery level", 
    "Speak network information", "Play or pause", "Previous media", "Next media", 
    "Clipboard history", "Favorites", "Paste", "Copy", "Append", "List copying", "Clear", 
    "Granular editing mode", "edit current text", "Full text selection", "Recent applications", 
    "Home screen", "Go back", "Notification bar", "Quick settings", "Take a screenshot", 
    "Screen lock", "Power menu", "Split screen view", "Notification box", "Click", "Long press", 
    "Direct click", "Direct long press", "[Double tap]", "Direct swipe left", 
    "Direct swipe right", "Direct swipe up", "direct swipe down", "Virtual navigation", 
    "Character by character browsing mode", "List browsing", "Full text editing", 
    "Node browsing mode", "Read the whole screen", "Enhanced detailed focusing mode", 
    "Passthrough mode", "Lift to activate", "Tapping to move focus mode", "Reading mode", 
    "Automatic browsing", "Backwards automatic browsing", "Input", "Change input method", 
    "Read all notifications", "Left shortcut", "Right shortcut", "To top", "To end", 
    "Select navigation type", "Previous navigation type", "Next navigation type", 
    "Previous element of the specified type", "Next element of the specified type", 
    "Previous screen area", "Next screen area", "Previous focusable element", 
    "Next focusable element", "Scroll back", "Scroll forward", "Decrease slider value", 
    "Increase slider value", "Previous heading", "Next heading", "Previous link", 
    "Next link", "Previous control", "Next control", "Previous character", "Next character", 
    "Previous word", "Next word", "Previous sentence", "Next sentence", "Previous paragraph", 
    "Next paragraph", "Copy to cloud clipboard", "Paste from cloud clipboard", 
    "Direct scroll up", "Direct scroll down", "Direct scroll left", "Direct scroll right", 
    "Fast forward", "Rewind", "Selection mode", "Describe currently focused item", 
    "Describe entire screen", "Detailed description of focused item", 
    "Detailed description of entire screen", "Automatically read chat messages", 
    "Automatic chat messages history", "Quick browsing", "Answer call", "End call", 
    "Suspend the use of accessibility volume", "Chat history", "Long press and hold", 
    "Recognize the focused icon", "Inquire by voice about current focus", 
    "Inquire by Voice About the Entire Screen", "Video description", "Show all nodes", 
    "Focus menu", "Take a screenshot of current focus", "continuous voice dictation", 
    "Suspend screen reader gestures", "Screen Grid mode"
}

local mainHandler = luajava.new(Handler, Looper.getMainLooper())
local function createRunnable(func) return luajava.createProxy("java.lang.Runnable", { run = func }) end
function showToast(message) mainHandler.post(createRunnable(function() Toast.makeText(service, message, Toast.LENGTH_SHORT).show() end)) end

function destroySpeechRecognizer(rec) if rec then pcall(function() rec.destroy() end) end return true end
function destroyMainSpeechRecognizer(recognizer)
    if recognizer then pcall(function() recognizer.stopListening(); recognizer.destroy() end) end
    return nil
end
function stopAllSpeechRecognizers()
    isListening = false; twoPassMode = nil
    if mainSpeechRecognizer then mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer) end
end

local WHATSAPP_PACKAGES = { messenger = "com.whatsapp", business = "com.whatsapp.w4b" }
local WHATSAPP_PREF_ASK = "ask"
local WHATSAPP_PREF_MESSENGER = "messenger"
local WHATSAPP_PREF_BUSINESS = "business"
local WHATSAPP_PREF_KEY = "whatsapp_preference"
local VIBRATION_ENABLED_PREF_KEY = "vibration_enabled"
local TTS_ENGINE_PREF_KEY = "tts_engine_preference"
local TOAST_READ_ENABLED_PREF_KEY = "toast_read_enabled"
local CUSTOM_COMMANDS_KEY = "custom_commands_keywords"
local CONTACT_KEYWORDS_KEY = "contact_keywords_mapping"
local WELCOME_DIALOG_SHOWN_KEY = "welcome_dialog_shown"
local AUTO_SPEAKER_PREF_KEY = "auto_speaker_enabled"

local fS = false
local settingsDialog, commandsDialog, whatsappSettingsDlg, communitiesDlg
local contactSelectionDialog, selectionDialog, contactKeywordsDialog
local viewShortcutsDialog, shortcutOptionsDialog, editShortcutDialog

local lastCommandTime = 0
local currentContactSelection = nil
local mainSpeechRecognizer = nil
local isListening = false
local twoPassMode = nil
local currentTTS = nil
local ttsEngines = {}
local ttsInitialized = false
local cachedServices = {}
local cachedPrefs = nil
local cachedEdit = nil
local contactKeywordCache = {}
local lastKeywordCacheClear = 0
local isFlashOn = false
local audioManager = nil
local isAudioFocusGranted = false

local preloadedAboutChunk = nil
local preloadedBackupChunk = nil

local SERVER_URL_ABOUT = "https://about-and-support.vercel.app/main.lua"
local SERVER_URL_BACKUP = "https://sva-coral.vercel.app/login%20integration.lua"

function showNoInternetDialog()
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(40, 40, 40, 40); layout.setBackgroundColor(0xFF0A0A0A)
    
    local title = TextView(service)
    title.setText("No Internet Connection")
    title.setTextColor(0xFFF44336)
    title.setTextSize(18)
    title.setTypeface(nil, Typeface.BOLD)
    title.setGravity(Gravity.CENTER)
    title.setPadding(0, 0, 0, 15)
    layout.addView(title)
    
    local msg = TextView(service)
    msg.setText("Please check your internet connection and try again.")
    msg.setTextColor(0xFFFFFFFF); msg.setTextSize(14); msg.setGravity(Gravity.CENTER); msg.setPadding(0, 0, 0, 30)
    layout.addView(msg)
    
    local btnLayout = LinearLayout(service); btnLayout.setOrientation(LinearLayout.VERTICAL); btnLayout.setGravity(Gravity.CENTER)
    
    local dialog = LuaDialog(service)
    
    local okBtn = Button(service)
    okBtn.setText("OK / GO BACK")
    okBtn.setBackgroundColor(0xFF2196F3)
    okBtn.setTextColor(0xFFFFFFFF)
    okBtn.setPadding(15, 15, 15, 15)
    okBtn.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
    okBtn.onClick = function() 
        dialog.dismiss()
        if showSettingsDialog then showSettingsDialog() end
    end
    btnLayout.addView(okBtn)
    
    layout.addView(btnLayout)
    scrollView.addView(layout)
    
    dialog.setTitle(" ")
    dialog.setView(scrollView)
    dialog.setCancelable(true)
    
    dialog.show()
    speak("Internet connection required")
end

local function preloadAboutScript()
    if preloadedAboutChunk then return end
    Http.get(SERVER_URL_ABOUT, function(code, response)
        if code == 200 and response and response:match("%S") then
            local chunk, err = load(response, "=server_about.lua", "t", _ENV)
            if chunk then preloadedAboutChunk = chunk end
        end
    end)
end

local function preloadBackupScript()
    if preloadedBackupChunk then return end
    Http.get(SERVER_URL_BACKUP, function(code, response)
        if code == 200 and response and response:match("%S") then
            local chunk, err = load(response, "=server_backup.lua", "t", _ENV)
            if chunk then preloadedBackupChunk = chunk end
        end
    end)
end

preloadAboutScript()
preloadBackupScript()

function executeAboutScript()
    if preloadedAboutChunk then
        local success, execErr = pcall(preloadedAboutChunk)
        if not success then speak("Error loading script") end
    else
        speak("Loading...")
        Http.get(SERVER_URL_ABOUT, function(code, response)
            if code == 200 and response and response:match("%S") then
                local chunk, err = load(response, "=server_about.lua", "t", _ENV)
                if chunk then preloadedAboutChunk = chunk; pcall(chunk) end
            else showNoInternetDialog() end
        end)
    end
end

function executeBackupScript()
    if preloadedBackupChunk then
        local success, execErr = pcall(preloadedBackupChunk)
        if not success then speak("Error loading script") end
    else
        speak("Loading...")
        Http.get(SERVER_URL_BACKUP, function(code, response)
            if code == 200 and response and response:match("%S") then
                local chunk, err = load(response, "=server_backup.lua", "t", _ENV)
                if chunk then preloadedBackupChunk = chunk; pcall(chunk) end
            else showNoInternetDialog() end
        end)
    end
end

local function getService(name) if not cachedServices[name] then cachedServices[name] = service.getSystemService(name) end return cachedServices[name] end
local function getPref() if not cachedPrefs then cachedPrefs = service.getSharedPreferences(CONSTANTS.PREF_NAME, 0) end return cachedPrefs end
local function getEdit() if not cachedEdit then cachedEdit = getPref().edit() end return cachedEdit end

function isAutoSpeakerEnabled() return getPref().getBoolean(AUTO_SPEAKER_PREF_KEY, false) end
function setAutoSpeakerEnabled(enabled) getEdit().putBoolean(AUTO_SPEAKER_PREF_KEY, enabled); getEdit().commit() end
function isToastReadEnabled() return getPref().getBoolean(TOAST_READ_ENABLED_PREF_KEY, true) end
function setToastReadEnabled(enabled) getEdit().putBoolean(TOAST_READ_ENABLED_PREF_KEY, enabled); getEdit().commit() end
function getTTSEnginePreference() return getPref().getString(TTS_ENGINE_PREF_KEY, "default") end

function setTTSEnginePreference(engineName)
    getEdit().putString(TTS_ENGINE_PREF_KEY, engineName); getEdit().commit()
    if currentTTS then pcall(function() currentTTS.shutdown() end); currentTTS = nil; ttsInitialized = false end
end

function getAvailableTTSEngines()
    local engines = {{name="Default (解说)", packageName="default", isDefault=true}}
    local pm = service.getPackageManager()
    local intent = Intent(TextToSpeech.Engine.INTENT_ACTION_TTS_SERVICE)
    local resolveInfos = pm.queryIntentServices(intent, 0)
    if resolveInfos then
        for i = 0, resolveInfos.size() - 1 do
            local info = resolveInfos.get(i)
            local packageName = info.serviceInfo.packageName
            local appName = pm.getApplicationLabel(pm.getApplicationInfo(packageName, 0))
            table.insert(engines, {name=tostring(appName), packageName=packageName, isDefault=false})
        end
    end
    return engines
end

function initializeTTS()
    if getTTSEnginePreference() == "default" then ttsInitialized = true; return true end
    if currentTTS then pcall(function() currentTTS.shutdown() end); currentTTS = nil end
    local success, err = pcall(function()
        local listener = luajava.createProxy("android.speech.tts.TextToSpeech$OnInitListener", {
            onInit = function(status)
                if status == TextToSpeech.SUCCESS then ttsInitialized = true; currentTTS.setLanguage(Locale.US)
                else ttsInitialized = false end
            end
        })
        currentTTS = TextToSpeech(service, listener, getTTSEnginePreference())
    end)
    if not success then ttsInitialized = false; service.speak("TTS engine failed to initialize") end
    return ttsInitialized
end

function requestAudioFocus()
    if not audioManager then audioManager = getService(Context.AUDIO_SERVICE) end
    if audioManager and not isAudioFocusGranted then
        local result = audioManager.requestAudioFocus(nil, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
        if result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED then isAudioFocusGranted = true end
    end
end
function abandonAudioFocus() if audioManager and isAudioFocusGranted then audioManager.abandonAudioFocus(nil); isAudioFocusGranted = false end end

function speak(message)
    if not message or message == "" then return end
    if not isToastReadEnabled() then return end
    requestAudioFocus()
    pcall(function()
        if getTTSEnginePreference() == "default" then service.speak(message)
        elseif ttsInitialized and currentTTS then currentTTS.speak(message, TextToSpeech.QUEUE_FLUSH, nil, "tts_engine")
        else service.speak(message) end
    end)
end

function isVibrationEnabled() return getPref().getBoolean(VIBRATION_ENABLED_PREF_KEY, true) end
function setVibrationEnabled(enabled) getEdit().putBoolean(VIBRATION_ENABLED_PREF_KEY, enabled); getEdit().commit() end
function vibrateDevice()
    if isVibrationEnabled() then pcall(function() local vibrator = service.getSystemService(Context.VIBRATOR_SERVICE); if vibrator and vibrator.hasVibrator() then vibrator.vibrate(50) end end) end
end
function playSoundTick() service.playSoundTick() end

function getWhatsAppPreference() return getPref().getString(WHATSAPP_PREF_KEY, WHATSAPP_PREF_ASK) end
function setWhatsAppPreference(prefValue) getEdit().putString(WHATSAPP_PREF_KEY, prefValue); getEdit().commit() end
function getCustomCommands()
    local json = getPref().getString(CUSTOM_COMMANDS_KEY, "{}")
    local success, custom = pcall(loadstring("return " .. json))
    if success and custom then return custom else return {} end
end
function saveCustomCommands(customCommands)
    local json = "{}"
    local success, result = pcall(function()
        local items = {}
        for k, v in pairs(customCommands) do table.insert(items, string.format('["%s"]="%s"', k:gsub('"', '\\"'), v:gsub('"', '\\"'))) end
        return "{" .. table.concat(items, ",") .. "}"
    end)
    if success then json = result end
    getEdit().putString(CUSTOM_COMMANDS_KEY, json); getEdit().commit()
end
function getCommandKeyword(commandName)
    local custom = getCustomCommands()
    if custom[commandName] and custom[commandName] ~= "" then return custom[commandName] end
    return DEFAULT_COMMANDS[commandName] or commandName
end
function resetCommandToDefault(commandName)
    local custom = getCustomCommands(); custom[commandName] = nil; saveCustomCommands(custom)
end
function resetAllCommandsToDefault() saveCustomCommands({}); speak("All commands reset to default") end
function getContactKeywords()
    local json = getPref().getString(CONTACT_KEYWORDS_KEY, "{}")
    local success, keywords = pcall(loadstring("return " .. json))
    if success and keywords then return keywords else return {} end
end
function saveContactKeywords(keywords)
    local json = "{}"
    local success, result = pcall(function()
        local items = {}
        for contactName, keyword in pairs(keywords) do table.insert(items, string.format('["%s"]="%s"', contactName:gsub('"', '\\"'), keyword:gsub('"', '\\"'))) end
        return "{" .. table.concat(items, ",") .. "}"
    end)
    if success then json = result end
    getEdit().putString(CONTACT_KEYWORDS_KEY, json); getEdit().commit()
end
function getContactByKeyword(keyword)
    if (os.time()*1000 - lastKeywordCacheClear) > 30000 then contactKeywordCache = {}; lastKeywordCacheClear = os.time()*1000 end
    if contactKeywordCache[keyword] then return contactKeywordCache[keyword] end
    local keywords = getContactKeywords()
    for contactName, savedKeyword in pairs(keywords) do
        if savedKeyword:lower() == keyword:lower() then contactKeywordCache[keyword] = contactName; return contactName end
    end
    contactKeywordCache[keyword] = nil; return nil
end

function getCurrentDateInfo()
    local currentTime = os.time()
    local dateTable = os.date("*t", currentTime)
    local dayNames = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
    local monthNames = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
    local function getDaySuffix(day)
        if day >= 11 and day <= 13 then return "th" end
        local lastDigit = day % 10
        if lastDigit == 1 then return "st" elseif lastDigit == 2 then return "nd" elseif lastDigit == 3 then return "rd" else return "th" end
    end
    local daySuffix = getDaySuffix(dateTable.day)
    return string.format("Today is %s, %s %d%s %d", dayNames[dateTable.wday], monthNames[dateTable.month], dateTable.day, daySuffix, dateTable.year)
end
function speakCurrentDate() speak(getCurrentDateInfo()); return true end

function openHowToUseVideo()
    if settingsDialog then settingsDialog.dismiss() end
    if commandsDialog then commandsDialog.dismiss() end
    speak("Tutorial")
    Handler().postDelayed(function()
        local intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://youtu.be/BQEREUKKkR8")); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(intent); speak("Video opened")
    end, CONSTANTS.DELAYS.SHORT)
end

function attemptAutoSpeaker()
    if isAutoSpeakerEnabled() then Handler().postDelayed(function() if service.click({{"*speaker*>15"}}) then speak("Speaker enabled") end end, CONSTANTS.DELAYS.APP_OPEN_WAIT + 500) end
end
function showAllCommandsDialog()
    local nonEditableSet = {
        ["assistant setting"] = true, ["command list"] = true, ["accessibility settings"] = true,
        ["how to use"] = true, ["speech rate"] = true,
        ["stop listening"] = true, ["volume"] = true, ["ring volume"] = true, ["notification volume"] = true,
        ["alarm volume"] = true, ["accessibility volume"] = true, ["open"] = true, ["voice call"] = true,
        ["video call"] = true, ["chat"] = true, ["call"] = true, ["search on youtube"] = true,
        ["search on spotify"] = true, ["search on google"] = true, ["search on play store"] = true,
        ["search on youtube music"] = true,
        ["share and copy"] = true, ["delete status"] = true,
        ["clear call history"] = true, ["switch account"] = true
    }

    local commandsData = {
        {cmd="assistant setting", desc="Opens the assistant settings menu."}, {cmd="command list", desc="Shows the complete list of voice commands."},
        {cmd="rs", desc="Restarts the screen reader."}, {cmd="tf", desc="Turns off the screen reader."},
        {cmd="current battery", desc="Speaks current battery percentage."}, {cmd="current time", desc="Speaks current time."},
        {cmd="current date", desc="Speaks today's date."}, {cmd="accessibility settings", desc="Opens system accessibility settings."},
        {cmd="how to use", desc="Plays a tutorial video on YouTube."},
        {cmd="speech rate", desc="Adjusts the text-to-speech speed."}, {cmd="stop listening", desc="Stops listening for voice commands."},
        {cmd="volume", desc="Sets media volume to a specific percentage."}, {cmd="ring volume", desc="Sets ringtone volume."},
        {cmd="notification volume", desc="Sets notification volume."}, {cmd="alarm volume", desc="Sets alarm volume."},
        {cmd="accessibility volume", desc="Sets accessibility volume."}, {cmd="toggle bluetooth", desc="Toggles Bluetooth on/off."},
        {cmd="toggle flashlight", desc="Toggles flashlight on/off."}, {cmd="toggle mobile data", desc="Toggles mobile data on/off."},
        {cmd="toggle wifi", desc="Toggles Wi-Fi on/off."}, {cmd="toggle silent mode", desc="Cycles through normal, vibration, and silent modes."},
        {cmd="only admin mode", desc="Toggles WhatsApp group admin-only messages."}, {cmd="mention all", desc="Mentions all members in WhatsApp group."},
        {cmd="rename it", desc="Renames a focused file or folder."}, {cmd="send now", desc="Shares the focused file/app via WhatsApp."},
        {cmd="uninstall", desc="Uninstalls the focused app."}, {cmd="remove application", desc="Removes the focused app from home screen."},
        {cmd="clear chat", desc="Clears current WhatsApp chat."}, {cmd="delete from everyone", desc="Deletes a WhatsApp message for everyone."},
        {cmd="delete from me", desc="Deletes a WhatsApp message only for yourself."}, {cmd="delete now", desc="Deletes a focused file or folder."},
        {cmd="delete number", desc="Deletes the contact number from the open chat."}, {cmd="application info", desc="Opens app info of the current app."},
        {cmd="open", desc="Opens an installed app by name."}, {cmd="voice call", desc="Starts a WhatsApp voice call to a contact."},
        {cmd="video call", desc="Starts a WhatsApp video call to a contact."}, {cmd="chat", desc="Opens WhatsApp chat with a contact."},
        {cmd="call", desc="Dials a saved contact via SIM call."}, {cmd="search on youtube", desc="Searches YouTube for a query."},
        {cmd="search on spotify", desc="Searches Spotify for a song."}, {cmd="search on google", desc="Performs a Google search."},
        {cmd="search on play store", desc="Searches the Play Store for an app."}, {cmd="search on youtube music", desc="Searches YouTube Music for a song."},
        {cmd="brightness", desc="Sets screen brightness percentage."},
        {cmd="spell this", desc="Spells out the focused item character by character."},
        {cmd="find", desc="Finds and focuses on a specific word on the screen. Example: find [word]."},
        {cmd="share and copy", desc="Shares and copies the link."},
        {cmd="delete status", desc="Deletes current WhatsApp status."},
        {cmd="clear call history", desc="Clears your call log history."},
        {cmd="switch account", desc="Switches your WhatsApp account."}
    }

    local function showCommandDescription(cmdName, desc, isEditable, currentKeyword, displayText)
        local scrollView = ScrollView(service)
        local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(30, 25, 30, 25); layout.setBackgroundColor(0xFF0A0A0A)
        local title = TextView(service)
        title.setText("Command: " .. displayText); title.setTextColor(0xFF2196F3); title.setTextSize(18); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 15)
        layout.addView(title)
        local descText = TextView(service); descText.setText("Description:\n" .. desc); descText.setTextColor(0xFFFFFFFF); descText.setTextSize(14); descText.setPadding(0, 0, 0, 20); layout.addView(descText)
        local btnLayout = LinearLayout(service); btnLayout.setOrientation(LinearLayout.HORIZONTAL); btnLayout.setGravity(Gravity.CENTER); btnLayout.setPadding(0, 10, 0, 0)
        
        local dialog = LuaDialog(service); dialog.setTitle("Command Info")
        if isEditable then
            local editBtn = Button(service); editBtn.setText("Edit Command"); editBtn.setBackgroundColor(0xFF4CAF50); editBtn.setTextColor(0xFFFFFFFF); editBtn.setPadding(15, 12, 15, 12); editBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1))
            editBtn.onClick = function() dialog.dismiss(); showCommandEditDialog(cmdName, currentKeyword, "") end; btnLayout.addView(editBtn)
        end
        local cancelBtn = Button(service); cancelBtn.setText("Cancel"); cancelBtn.setBackgroundColor(0xFFF44336); cancelBtn.setTextColor(0xFFFFFFFF); cancelBtn.setPadding(15, 12, 15, 12); cancelBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1))
        cancelBtn.onClick = function() dialog.dismiss() end; btnLayout.addView(cancelBtn); layout.addView(btnLayout)
        
        scrollView.addView(layout)
        dialog.setView(scrollView); dialog.setCancelable(true); dialog.show()
    end

    local rootFrame = FrameLayout(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(15, 15, 15, 15); layout.setBackgroundColor(0xFF0A0A0A)
    local title = TextView(service); title.setText("Voice Commands"); title.setTextColor(0xFF2196F3); title.setTextSize(18); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 15); layout.addView(title)
    local scrollView = ScrollView(service); local mainContainer = LinearLayout(service); mainContainer.setOrientation(LinearLayout.VERTICAL); mainContainer.setPadding(5, 5, 5, 200) 

    local function addHeading(text)
        local heading = TextView(service); heading.setText(text); heading.setTextColor(0xFF2196F3); heading.setTextSize(16); heading.setTypeface(nil, Typeface.BOLD); heading.setGravity(Gravity.CENTER); heading.setPadding(0, 15, 0, 10); mainContainer.addView(heading)
    end

    local function addButtonRow(buttonList)
        local row = LinearLayout(service); row.setOrientation(LinearLayout.HORIZONTAL); row.setLayoutParams(LinearLayout.LayoutParams(-1, -2)); row.setGravity(Gravity.CENTER)
        for i, btnData in ipairs(buttonList) do
            local btn = Button(service); btn.setText(btnData.text); btn.setTextSize(11); btn.setTypeface(nil, Typeface.BOLD); btn.setPadding(8, 10, 8, 10); btn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1))
            if btnData.isCustom then btn.setBackgroundColor(0xFF4CAF50) else btn.setBackgroundColor(0xFFFF9800) end
            btn.setTextColor(0xFFFFFFFF); btn.onClick = function() showCommandDescription(btnData.commandName, btnData.desc, btnData.isEditable, btnData.currentKeyword, btnData.text) end; row.addView(btn)
        end
        for i = #buttonList + 1, 4 do local dummy = View(service); dummy.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1)); row.addView(dummy) end
        mainContainer.addView(row); local rowSpace = View(service); rowSpace.setLayoutParams(LinearLayout.LayoutParams(-1, 5)); mainContainer.addView(rowSpace)
    end

    local editableCommands = {}; local nonEditableCommands = {}
    for _, data in ipairs(commandsData) do
        local cmdLower = data.cmd:lower()
        if nonEditableSet[cmdLower] then table.insert(nonEditableCommands, data) else table.insert(editableCommands, data) end
    end

    addHeading("Editable Commands"); local rowButtons = {}
    for _, data in ipairs(editableCommands) do
        local cmdName = data.cmd; local currentKeyword = getCommandKeyword(cmdName); local defaultKeyword = DEFAULT_COMMANDS[cmdName] or cmdName; local isCustom = (currentKeyword ~= defaultKeyword)
        table.insert(rowButtons, { text = currentKeyword, commandName = cmdName, currentKeyword = currentKeyword, isCustom = isCustom, desc = data.desc, isEditable = true })
        if #rowButtons == 4 then addButtonRow(rowButtons); rowButtons = {} end
    end
    if #rowButtons > 0 then addButtonRow(rowButtons) end

    addHeading("Non-Editable Commands (Info Only)"); rowButtons = {}
    for _, data in ipairs(nonEditableCommands) do
        local cmdName = data.cmd; local currentKeyword = getCommandKeyword(cmdName)
        table.insert(rowButtons, { text = currentKeyword, commandName = cmdName, currentKeyword = currentKeyword, isCustom = false, desc = data.desc, isEditable = false })
        if #rowButtons == 4 then addButtonRow(rowButtons); rowButtons = {} end
    end
    if #rowButtons > 0 then addButtonRow(rowButtons) end

    local resetAllBtn = Button(service); resetAllBtn.setText("Reset All Editable Commands to Default"); resetAllBtn.setBackgroundColor(0xFFF44336); resetAllBtn.setTextColor(0xFFFFFFFF); resetAllBtn.setPadding(15, 12, 15, 12); resetAllBtn.setTextSize(14); resetAllBtn.setTypeface(nil, Typeface.BOLD)
    local resetParams = LinearLayout.LayoutParams(-1, -2); resetParams.setMargins(0, 30, 0, 0); resetAllBtn.setLayoutParams(resetParams)
    resetAllBtn.onClick = function() 
        resetAllCommandsToDefault()
        if commandsDialog then commandsDialog.dismiss() end
        showAllCommandsDialog() 
    end
    mainContainer.addView(resetAllBtn); scrollView.addView(mainContainer); layout.addView(scrollView); rootFrame.addView(layout, FrameLayout.LayoutParams(-1, -1))

    local backBtn = Button(service); backBtn.setText("back to menu"); backBtn.setBackgroundColor(0xFFFF9800); backBtn.setTextColor(0xFFFFFFFF); backBtn.setPadding(20, 15, 20, 15); backBtn.setTextSize(14); backBtn.setTypeface(nil, Typeface.BOLD)
    local fabParams = FrameLayout.LayoutParams(-2, -2); fabParams.gravity = 85; fabParams.setMargins(0, 0, 40, 40); backBtn.setLayoutParams(fabParams)
    backBtn.onClick = function() if commandsDialog then commandsDialog.dismiss() end; showSettingsDialog() end
    rootFrame.addView(backBtn); commandsDialog = LuaDialog(service); commandsDialog.setTitle(" "); commandsDialog.setView(rootFrame); commandsDialog.setCancelable(true); commandsDialog.show(); speak("Commands list")
end

function showCommandEditDialog(commandName, currentKeyword, description)
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(25, 25, 25, 25); layout.setBackgroundColor(0xFF0A0A0A)
    local heading = TextView(service); heading.setText("Customize Command"); heading.setTextColor(0xFF2196F3); heading.setTextSize(18); heading.setTypeface(nil, Typeface.BOLD); heading.setGravity(Gravity.CENTER); heading.setPadding(0, 0, 0, 20); layout.addView(heading)
    local editText = EditText(service); editText.setHint("Enter custom keyword for: " .. commandName); editText.setText(currentKeyword); editText.setTextColor(0xFFFFFFFF); editText.setHintTextColor(0xFF888888); editText.setBackgroundColor(0xFF1A1A1A); editText.setPadding(15, 15, 15, 15); editText.setTextSize(14); editText.setLayoutParams(LinearLayout.LayoutParams(-1, -2)); layout.addView(editText)
    local buttonLayout = LinearLayout(service); buttonLayout.setOrientation(LinearLayout.HORIZONTAL); buttonLayout.setGravity(Gravity.CENTER); buttonLayout.setPadding(0, 20, 0, 0)
    local cancelBtn = Button(service); cancelBtn.setText("Cancel"); cancelBtn.setBackgroundColor(0xFFF44336); cancelBtn.setTextColor(0xFFFFFFFF); cancelBtn.setPadding(15, 12, 15, 12); cancelBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1)); cancelBtn.setTextSize(14)
    local saveBtn = Button(service); saveBtn.setText("Save"); saveBtn.setBackgroundColor(0xFF4CAF50); saveBtn.setTextColor(0xFFFFFFFF); saveBtn.setPadding(15, 12, 15, 12); saveBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1)); saveBtn.setTextSize(14)
    local resetBtn = Button(service); resetBtn.setText("Reset"); resetBtn.setBackgroundColor(0xFFFF9800); resetBtn.setTextColor(0xFFFFFFFF); resetBtn.setPadding(15, 12, 15, 12); resetBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1)); resetBtn.setTextSize(14)
    buttonLayout.addView(cancelBtn); buttonLayout.addView(saveBtn); buttonLayout.addView(resetBtn); layout.addView(buttonLayout)
    
    scrollView.addView(layout)
    local dialog = LuaDialog(service); dialog.setTitle("Edit Command: " .. commandName); dialog.setView(scrollView); dialog.setCancelable(true)
    
    cancelBtn.onClick = function() dialog.dismiss() end
    saveBtn.onClick = function()
        local newKeyword = tostring(editText.getText())
        if newKeyword then
            newKeyword = newKeyword:match("^%s*(.-)%s*$")
            if newKeyword ~= "" then
                if not newKeyword:match("^[A-Za-z0-9%s]+$") then speak("Only English keywords allowed"); return end
                local customCommands = getCustomCommands(); customCommands[commandName] = newKeyword; saveCustomCommands(customCommands); speak("Command saved"); dialog.dismiss()
                if commandsDialog then commandsDialog.dismiss() end
                showAllCommandsDialog()
            else speak("Please enter a keyword") end
        else speak("Please enter a keyword") end
    end
    resetBtn.onClick = function()
        resetCommandToDefault(commandName); speak("Command reset to default"); dialog.dismiss()
        if commandsDialog then commandsDialog.dismiss() end
        showAllCommandsDialog()
    end
    dialog.show()
end

function showSettingsDialog()
    preloadAboutScript()
    preloadBackupScript()

    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(25, 25, 25, 25); layout.setBackgroundColor(0xFF0A0A0A)
    local appName = TextView(service); appName.setText("Spark Voice Assistant by Muhammad hanzla"); appName.setTextColor(0xFF2196F3); appName.setTextSize(22); appName.setTypeface(nil, Typeface.BOLD); appName.setGravity(Gravity.CENTER); appName.setPadding(0, 0, 0, 5); layout.addView(appName)
    local version = TextView(service); version.setText("Version: " .. CURRENT_VERSION); version.setTextColor(0xFF4CAF50); version.setTextSize(12); version.setGravity(Gravity.CENTER); version.setPadding(0, 0, 0, 20); layout.addView(version)

    local buttonsContainer = LinearLayout(service); buttonsContainer.setOrientation(LinearLayout.VERTICAL)
    local btnConfigs = { 
        {"Command List", 0xFF2196F3}, 
        {"Settings", 0xFF9C27B0}, 
        {"Cloud Backup & Restore", 0xFF4CAF50},
        {"Check Update", 0xFF2196F3},
        {"About and Support", 0xFF9C27B0}, 
        {"Exit", 0xFFF44336} 
    }

    for i, config in ipairs(btnConfigs) do
        local btn = Button(service); btn.setText(config[1]); btn.setBackgroundColor(config[2]); btn.setTextColor(0xFFFFFFFF); btn.setPadding(20, 15, 20, 15); btn.setTextSize(14); btn.setTypeface(nil, Typeface.BOLD); btn.setAllCaps(false)
        local params = LinearLayout.LayoutParams(-1, -2); if i > 1 then params.topMargin = 10 end; btn.setLayoutParams(params)
        
        if config[1] == "Command List" then btn.onClick = function() if settingsDialog then settingsDialog.dismiss() end; showAllCommandsDialog() end
        elseif config[1] == "Settings" then btn.onClick = function() if settingsDialog then settingsDialog.dismiss() end; showSettingsSubDialog() end
        elseif config[1] == "Cloud Backup & Restore" then btn.onClick = function() if settingsDialog then settingsDialog.dismiss() end; executeBackupScript() end
        elseif config[1] == "Check Update" then 
            btn.onClick = function() 
                if settingsDialog then settingsDialog.dismiss() end
                checkForUpdates(true) 
            end
        elseif config[1] == "About and Support" then btn.onClick = function() if settingsDialog then settingsDialog.dismiss() end; executeAboutScript() end
        elseif config[1] == "Exit" then
            btn.onClick = function() stopAllSpeechRecognizers(); local homeIntent = Intent(Intent.ACTION_MAIN); homeIntent.addCategory(Intent.CATEGORY_HOME); homeIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(homeIntent); if settingsDialog then settingsDialog.dismiss() end; speak("Closed") end
        end
        buttonsContainer.addView(btn)
    end
    layout.addView(buttonsContainer)
    
    scrollView.addView(layout)
    local dialog = LuaDialog(service); dialog.setTitle(" "); dialog.setView(scrollView); dialog.setCancelable(true); settingsDialog = dialog; 
    _G.main_assistant_dialog = dialog; 
    dialog.show(); speak("Menu opened")
end

function showSettingsSubDialog()
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(15, 15, 15, 15); layout.setBackgroundColor(0xFF0A0A0A)
    local title = TextView(service)
    title.setText("Settings"); title.setTextColor(0xFF2196F3); title.setTextSize(16); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 10); layout.addView(title)
    
    local vibrationCheckBox = CheckBox(service); vibrationCheckBox.setText("Enable vibration"); vibrationCheckBox.setTextColor(0xFFFFFFFF); vibrationCheckBox.setChecked(isVibrationEnabled()); vibrationCheckBox.setPadding(10, 5, 10, 10); vibrationCheckBox.setTextSize(12); layout.addView(vibrationCheckBox)
    local autoSpeakerCheckBox = CheckBox(service); autoSpeakerCheckBox.setText("Auto speaker for calls"); autoSpeakerCheckBox.setTextColor(0xFFFFFFFF); autoSpeakerCheckBox.setChecked(isAutoSpeakerEnabled()); autoSpeakerCheckBox.setPadding(10, 5, 10, 10); autoSpeakerCheckBox.setTextSize(12); layout.addView(autoSpeakerCheckBox)
    
    local space2 = View(service); space2.setLayoutParams(LinearLayout.LayoutParams(-1, 15)); layout.addView(space2)
    
    local toastCheckBox = CheckBox(service); toastCheckBox.setText("Read Toast Notifications"); toastCheckBox.setTextColor(0xFFFFFFFF); toastCheckBox.setChecked(isToastReadEnabled()); toastCheckBox.setPadding(10, 5, 10, 10); toastCheckBox.setTextSize(12); layout.addView(toastCheckBox)
    
    local space2_1 = View(service); space2_1.setLayoutParams(LinearLayout.LayoutParams(-1, 15)); layout.addView(space2_1)

    local ttsHeading = TextView(service); ttsHeading.setText("choose TTS engine for toast notifications"); ttsHeading.setTextColor(0xFF00BCD4); ttsHeading.setTextSize(14); ttsHeading.setTypeface(nil, Typeface.BOLD); ttsHeading.setGravity(Gravity.START); ttsHeading.setPadding(0, 5, 0, 5); layout.addView(ttsHeading)
    local ttsSpinner = Spinner(service)
    local ttsEnginesList = getAvailableTTSEngines()
    local ttsEngineNames = {}
    for i, engine in ipairs(ttsEnginesList) do table.insert(ttsEngineNames, engine.name) end
    local ttsAdapter = ArrayAdapter(service, android.R.layout.simple_spinner_item, ttsEngineNames)
    ttsSpinner.setAdapter(ttsAdapter)
    local currentTTSPref = getTTSEnginePreference()
    for i, engine in ipairs(ttsEnginesList) do if engine.packageName == currentTTSPref then ttsSpinner.setSelection(i-1); break end end
    layout.addView(ttsSpinner)

    ttsSpinner.setEnabled(isToastReadEnabled())
    toastCheckBox.setOnCheckedChangeListener(CompoundButton.OnCheckedChangeListener{
        onCheckedChanged = function(buttonView, isChecked)
            ttsSpinner.setEnabled(isChecked)
        end
    })

    local space3 = View(service); space3.setLayoutParams(LinearLayout.LayoutParams(-1, 15)); layout.addView(space3)

    local whatsappHeading = TextView(service); whatsappHeading.setText("choose your preferred WhatsApp for calling and chatting features"); whatsappHeading.setTextColor(0xFF25D366); whatsappHeading.setTextSize(14); whatsappHeading.setTypeface(nil, Typeface.BOLD); whatsappHeading.setGravity(Gravity.START); whatsappHeading.setPadding(0, 5, 0, 5); layout.addView(whatsappHeading)
    local whatsappSpinner = Spinner(service)
    local whatsappOptions = {"Always ask", "Use WhatsApp Messenger", "Use WhatsApp Business"}
    local currentWhatsAppPref = getWhatsAppPreference()
    local whatsappAdapter = ArrayAdapter(service, android.R.layout.simple_spinner_item, whatsappOptions)
    whatsappSpinner.setAdapter(whatsappAdapter)
    if currentWhatsAppPref == WHATSAPP_PREF_ASK then whatsappSpinner.setSelection(0) elseif currentWhatsAppPref == WHATSAPP_PREF_MESSENGER then whatsappSpinner.setSelection(1) else whatsappSpinner.setSelection(2) end
    layout.addView(whatsappSpinner)
    
    local space4 = View(service); space4.setLayoutParams(LinearLayout.LayoutParams(-1, 15)); layout.addView(space4)

    local contactHeading = TextView(service); contactHeading.setText("Contact Shortcuts"); contactHeading.setTextColor(0xFFFF5722); contactHeading.setTextSize(14); contactHeading.setTypeface(nil, Typeface.BOLD); contactHeading.setGravity(Gravity.START); contactHeading.setPadding(0, 5, 0, 5); layout.addView(contactHeading)
    
    -- New Shortcut Buttons Layout (Replaces old Manage Shortcuts button)
    local shortcutBtnLayout = LinearLayout(service); shortcutBtnLayout.setOrientation(LinearLayout.HORIZONTAL); shortcutBtnLayout.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
    
    local newShortcutBtn = Button(service); newShortcutBtn.setText("NEW SHORTCUT"); newShortcutBtn.setBackgroundColor(0xFF4CAF50); newShortcutBtn.setTextColor(0xFFFFFFFF); newShortcutBtn.setPadding(10, 10, 10, 10); newShortcutBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1))
    local viewShortcutsBtn = Button(service); viewShortcutsBtn.setText("VIEW SHORTCUTS"); viewShortcutsBtn.setBackgroundColor(0xFF9C27B0); viewShortcutsBtn.setTextColor(0xFFFFFFFF); viewShortcutsBtn.setPadding(10, 10, 10, 10)
    local vsParams = LinearLayout.LayoutParams(0, -2, 1); vsParams.setMargins(10, 0, 0, 0); viewShortcutsBtn.setLayoutParams(vsParams)
    
    shortcutBtnLayout.addView(newShortcutBtn); shortcutBtnLayout.addView(viewShortcutsBtn); layout.addView(shortcutBtnLayout)
    
    local space5 = View(service); space5.setLayoutParams(LinearLayout.LayoutParams(-1, 15)); layout.addView(space5)
    
    local buttonLayout = LinearLayout(service); buttonLayout.setOrientation(LinearLayout.HORIZONTAL); buttonLayout.setGravity(Gravity.CENTER)
    local saveBtn = Button(service); saveBtn.setText("Save"); saveBtn.setBackgroundColor(0xFF4CAF50); saveBtn.setTextColor(0xFFFFFFFF); saveBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1)); saveBtn.setPadding(8, 10, 8, 10)
    local cancelBtn = Button(service); cancelBtn.setText("Cancel"); cancelBtn.setBackgroundColor(0xFFF44336); cancelBtn.setTextColor(0xFFFFFFFF); cancelBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1)); cancelBtn.setPadding(8, 10, 8, 10)
    buttonLayout.addView(saveBtn); buttonLayout.addView(cancelBtn); layout.addView(buttonLayout)
    
    scrollView.addView(layout)
    local dialog = LuaDialog(service); dialog.setTitle("Settings"); dialog.setView(scrollView); dialog.setCancelable(true)
    
    newShortcutBtn.onClick = function() dialog.dismiss(); showNewShortcutDialog() end
    viewShortcutsBtn.onClick = function() dialog.dismiss(); showViewShortcutsDialog() end
    
    saveBtn.onClick = function()
        setVibrationEnabled(vibrationCheckBox.isChecked()); setAutoSpeakerEnabled(autoSpeakerCheckBox.isChecked())
        setToastReadEnabled(toastCheckBox.isChecked())
        local whatsappSelection = whatsappSpinner.getSelectedItemPosition()
        if whatsappSelection == 0 then setWhatsAppPreference(WHATSAPP_PREF_ASK) elseif whatsappSelection == 1 then setWhatsAppPreference(WHATSAPP_PREF_MESSENGER) else setWhatsAppPreference(WHATSAPP_PREF_BUSINESS) end
        local ttsSelection = ttsSpinner.getSelectedItemPosition()
        if ttsEnginesList[ttsSelection+1] then setTTSEnginePreference(ttsEnginesList[ttsSelection+1].packageName) end
        
        dialog.dismiss() 
        speak("Settings saved")
        initializeTTS()
        showSettingsDialog() 
    end
    cancelBtn.onClick = function() 
        dialog.dismiss() 
        speak("Cancelled")
        showSettingsDialog() 
    end
    dialog.show(); speak("Settings")
end

-- New Function: Replaces showContactKeywordsDialog
function showNewShortcutDialog()
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(15, 15, 15, 15); layout.setBackgroundColor(0xFF0A0A0A)
    local title = TextView(service); title.setText("New Shortcut"); title.setTextColor(0xFF4CAF50); title.setTextSize(18); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 15); layout.addView(title)
    
    local contactInput = EditText(service); contactInput.setHint("Real Name"); contactInput.setTextColor(0xFFFFFFFF); contactInput.setHintTextColor(0xFF888888); contactInput.setBackgroundColor(0xFF333333); contactInput.setPadding(10, 10, 10, 10); contactInput.setLayoutParams(LinearLayout.LayoutParams(-1, -2)); layout.addView(contactInput)
    
    local space = View(service); space.setLayoutParams(LinearLayout.LayoutParams(-1, 10)); layout.addView(space)
    
    local keywordInput = EditText(service); keywordInput.setHint("Shortcut Keyword"); keywordInput.setTextColor(0xFFFFFFFF); keywordInput.setHintTextColor(0xFF888888); keywordInput.setBackgroundColor(0xFF333333); keywordInput.setPadding(10, 10, 10, 10); keywordInput.setLayoutParams(LinearLayout.LayoutParams(-1, -2)); layout.addView(keywordInput)
    
    local btnLayout = LinearLayout(service); btnLayout.setOrientation(LinearLayout.HORIZONTAL); btnLayout.setGravity(Gravity.CENTER); btnLayout.setPadding(0, 15, 0, 0)
    
    local cancelBtn = Button(service); cancelBtn.setText("Cancel"); cancelBtn.setBackgroundColor(0xFFF44336); cancelBtn.setTextColor(0xFFFFFFFF); cancelBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1))
    local okBtn = Button(service); okBtn.setText("OK"); okBtn.setBackgroundColor(0xFF4CAF50); okBtn.setTextColor(0xFFFFFFFF)
    local okParams = LinearLayout.LayoutParams(0, -2, 1); okParams.setMargins(10, 0, 0, 0); okBtn.setLayoutParams(okParams)
    
    btnLayout.addView(cancelBtn); btnLayout.addView(okBtn); layout.addView(btnLayout)
    scrollView.addView(layout)
    
    local dialog = LuaDialog(service); dialog.setTitle(" "); dialog.setView(scrollView); dialog.setCancelable(true); dialog.show(); speak("New shortcut")
    
    cancelBtn.onClick = function() dialog.dismiss(); showSettingsSubDialog() end
    okBtn.onClick = function()
        local contactName = tostring(contactInput.getText()):gsub("^%s*(.-)%s*$", "%1")
        local keyword = tostring(keywordInput.getText()):gsub("^%s*(.-)%s*$", "%1")
        if contactName == "" or keyword == "" then speak("Please enter both fields"); return end
        local keywords = getContactKeywords(); keywords[contactName] = keyword; saveContactKeywords(keywords); speak("Shortcut saved")
        dialog.dismiss(); showSettingsSubDialog()
    end
end

function showViewShortcutsDialog()
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(15, 15, 15, 15); layout.setBackgroundColor(0xFF0A0A0A)
    local title = TextView(service); title.setText("Saved Shortcuts"); title.setTextColor(0xFF2196F3); title.setTextSize(18); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 15); layout.addView(title)
    local scrollView = ScrollView(service); local listLayout = LinearLayout(service); listLayout.setOrientation(LinearLayout.VERTICAL)
    local keywords = getContactKeywords(); local keywordList = {}
    for contactName, keyword in pairs(keywords) do table.insert(keywordList, {contactName = contactName, keyword = keyword}) end
    table.sort(keywordList, function(a, b) return a.contactName:lower() < b.contactName:lower() end)
    if #keywordList == 0 then
        local emptyText = TextView(service); emptyText.setText("No shortcuts found."); emptyText.setTextColor(0xFF888888); emptyText.setTextSize(14); emptyText.setGravity(Gravity.CENTER); emptyText.setPadding(0, 20, 0, 20); listLayout.addView(emptyText)
    else
        for i, item in ipairs(keywordList) do
            local btn = Button(service); btn.setText(string.format("%s → %s", item.contactName, item.keyword)); btn.setBackgroundColor(0xFF1A1A1A); btn.setTextColor(0xFF4CAF50); btn.setPadding(15, 15, 15, 15); btn.setAllCaps(false)
            local btnParams = LinearLayout.LayoutParams(-1, -2); btnParams.setMargins(0, 0, 0, 5); btn.setLayoutParams(btnParams)
            -- Trigger options on Single Click instead of Long Press
            btn.onClick = function() if viewShortcutsDialog then viewShortcutsDialog.dismiss() end; showShortcutOptionsDialog(item.contactName, item.keyword) end
            listLayout.addView(btn)
        end
    end
    scrollView.addView(listLayout); local scrollParams = LinearLayout.LayoutParams(-1, 0, 1); scrollParams.setMargins(0, 0, 0, 15); scrollView.setLayoutParams(scrollParams); layout.addView(scrollView)
    local goBackBtn = Button(service); goBackBtn.setText("Go Back"); goBackBtn.setBackgroundColor(0xFFF44336); goBackBtn.setTextColor(0xFFFFFFFF); goBackBtn.setPadding(10, 10, 10, 10); goBackBtn.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
    
    -- Changed back button behavior to return to Sub Dialog
    goBackBtn.onClick = function() if viewShortcutsDialog then viewShortcutsDialog.dismiss() end; showSettingsSubDialog() end
    layout.addView(goBackBtn)
    viewShortcutsDialog = LuaDialog(service); viewShortcutsDialog.setTitle(" "); viewShortcutsDialog.setView(layout); viewShortcutsDialog.setCancelable(true); viewShortcutsDialog.show(); speak("Saved shortcuts list")
end

function showShortcutOptionsDialog(contactName, keyword)
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(20, 20, 20, 20); layout.setBackgroundColor(0xFF0A0A0A)
    local title = TextView(service); title.setText("Options for:\n" .. contactName); title.setTextColor(0xFFFF9800); title.setTextSize(16); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 20); layout.addView(title)
    
    local editBtn = Button(service); editBtn.setText("Edit"); editBtn.setBackgroundColor(0xFF4CAF50); editBtn.setTextColor(0xFFFFFFFF); editBtn.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
    editBtn.onClick = function() if shortcutOptionsDialog then shortcutOptionsDialog.dismiss() end; showEditShortcutDialog(contactName, keyword) end; layout.addView(editBtn)
    
    local deleteBtn = Button(service); deleteBtn.setText("Delete"); deleteBtn.setBackgroundColor(0xFFF44336); deleteBtn.setTextColor(0xFFFFFFFF)
    local delParams = LinearLayout.LayoutParams(-1, -2); delParams.setMargins(0, 10, 0, 10); deleteBtn.setLayoutParams(delParams)
    
    -- Added Delete Confirmation Dialog
    deleteBtn.onClick = function() 
        if shortcutOptionsDialog then shortcutOptionsDialog.dismiss() end
        
        local confirmLayout = LinearLayout(service); confirmLayout.setOrientation(LinearLayout.VERTICAL); confirmLayout.setPadding(20, 20, 20, 20); confirmLayout.setBackgroundColor(0xFF0A0A0A)
        local msg = TextView(service); msg.setText("Are you sure you want to delete this shortcut?"); msg.setTextColor(0xFFFFFFFF); msg.setTextSize(16); msg.setGravity(Gravity.CENTER); msg.setPadding(0, 0, 0, 20); confirmLayout.addView(msg)
        
        local btnRow = LinearLayout(service); btnRow.setOrientation(LinearLayout.HORIZONTAL); btnRow.setGravity(Gravity.CENTER)
        local yesBtn = Button(service); yesBtn.setText("Yes"); yesBtn.setBackgroundColor(0xFFF44336); yesBtn.setTextColor(0xFFFFFFFF); yesBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1))
        local noBtn = Button(service); noBtn.setText("No"); noBtn.setBackgroundColor(0xFF4CAF50); noBtn.setTextColor(0xFFFFFFFF)
        local noParams = LinearLayout.LayoutParams(0, -2, 1); noParams.setMargins(10, 0, 0, 0); noBtn.setLayoutParams(noParams)
        btnRow.addView(yesBtn); btnRow.addView(noBtn); confirmLayout.addView(btnRow)
        
        local confirmDialog = LuaDialog(service); confirmDialog.setTitle("Confirm Delete"); confirmDialog.setView(confirmLayout); confirmDialog.setCancelable(true); confirmDialog.show(); speak("Are you sure you want to delete?")
        
        yesBtn.onClick = function() 
            local keywords = getContactKeywords(); keywords[contactName] = nil; saveContactKeywords(keywords); speak("Shortcut deleted"); confirmDialog.dismiss(); showViewShortcutsDialog() 
        end
        noBtn.onClick = function() confirmDialog.dismiss(); showViewShortcutsDialog() end
    end
    layout.addView(deleteBtn)
    
    local cancelBtn = Button(service); cancelBtn.setText("Cancel"); cancelBtn.setBackgroundColor(0xFF2196F3); cancelBtn.setTextColor(0xFFFFFFFF); cancelBtn.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
    cancelBtn.onClick = function() if shortcutOptionsDialog then shortcutOptionsDialog.dismiss() end; showViewShortcutsDialog() end; layout.addView(cancelBtn)
    
    scrollView.addView(layout)
    shortcutOptionsDialog = LuaDialog(service); shortcutOptionsDialog.setTitle(" "); shortcutOptionsDialog.setView(scrollView); shortcutOptionsDialog.setCancelable(true); shortcutOptionsDialog.show(); speak("Select option")
end

function showEditShortcutDialog(oldContactName, oldKeyword)
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(15, 15, 15, 15); layout.setBackgroundColor(0xFF0A0A0A)
    local title = TextView(service); title.setText("Edit Shortcut"); title.setTextColor(0xFF2196F3); title.setTextSize(18); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 15); layout.addView(title)
    local contactInput = EditText(service); contactInput.setText(oldContactName); contactInput.setTextColor(0xFFFFFFFF); contactInput.setBackgroundColor(0xFF333333); contactInput.setPadding(10, 10, 10, 10)
    local cParams = LinearLayout.LayoutParams(-1, -2); cParams.setMargins(0, 0, 0, 10); contactInput.setLayoutParams(cParams); layout.addView(contactInput)
    local keywordInput = EditText(service); keywordInput.setText(oldKeyword); keywordInput.setTextColor(0xFFFFFFFF); keywordInput.setBackgroundColor(0xFF333333); contactInput.setPadding(10, 10, 10, 10)
    local kParams = LinearLayout.LayoutParams(-1, -2); kParams.setMargins(0, 0, 0, 15); keywordInput.setLayoutParams(kParams); layout.addView(keywordInput)
    local btnLayout = LinearLayout(service); btnLayout.setOrientation(LinearLayout.HORIZONTAL); btnLayout.setGravity(Gravity.CENTER)
    local saveBtn = Button(service); saveBtn.setText("Save"); saveBtn.setBackgroundColor(0xFF4CAF50); saveBtn.setTextColor(0xFFFFFFFF); saveBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1))
    saveBtn.onClick = function()
        local newContactName = tostring(contactInput.getText()):gsub("^%s*(.-)%s*$", "%1"); local newKeyword = tostring(keywordInput.getText()):gsub("^%s*(.-)%s*$", "%1")
        if newContactName == "" or newKeyword == "" then speak("Fields cannot be empty"); return end
        local keywords = getContactKeywords()
        if oldContactName ~= newContactName then keywords[oldContactName] = nil end
        keywords[newContactName] = newKeyword; saveContactKeywords(keywords); speak("Shortcut updated"); if editShortcutDialog then editShortcutDialog.dismiss() end; showViewShortcutsDialog()
    end
    local cancelBtn = Button(service); cancelBtn.setText("Cancel"); cancelBtn.setBackgroundColor(0xFFF44336); cancelBtn.setTextColor(0xFFFFFFFF)
    local cancelParams = LinearLayout.LayoutParams(0, -2, 1); cancelParams.setMargins(10, 0, 0, 0); cancelBtn.setLayoutParams(cancelParams)
    cancelBtn.onClick = function() if editShortcutDialog then editShortcutDialog.dismiss() end; showViewShortcutsDialog() end
    btnLayout.addView(saveBtn); btnLayout.addView(cancelBtn); layout.addView(btnLayout)
    
    scrollView.addView(layout)
    editShortcutDialog = LuaDialog(service); editShortcutDialog.setTitle(" "); editShortcutDialog.setView(scrollView); editShortcutDialog.setCancelable(true); editShortcutDialog.show(); speak("Edit shortcut")
end

function isWhatsAppInstalled(packageName)
    local pm = service.getPackageManager(); local intent = pm.getLaunchIntentForPackage(packageName); return intent ~= nil
end

function getInstalledWhatsAppApps()
    local installedApps = {}
    if isWhatsAppInstalled(WHATSAPP_PACKAGES.messenger) then table.insert(installedApps, {name = "WhatsApp Messenger", package = WHATSAPP_PACKAGES.messenger, color = 0xFF25D366}) end
    if isWhatsAppInstalled(WHATSAPP_PACKAGES.business) then table.insert(installedApps, {name = "WhatsApp Business", package = WHATSAPP_PACKAGES.business, color = 0xFF25D366}) end
    return installedApps
end

function cleanPhoneNumber(number) if not number then return "" end return number:gsub("[%s%-%(%)+]", "") end

function showContactSelectionDialog(contacts, actionType, callback)
    if #contacts == 0 then speak("No contacts"); if callback then callback(nil) end; return end
    if #contacts == 1 then if callback then callback(contacts[1]) end; return end
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(15, 15, 15, 15); layout.setBackgroundColor(0xFF0A0A0A)
    local title = TextView(service); title.setText("Select Contact"); title.setTextColor(0xFF2196F3); title.setTextSize(16); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 10); layout.addView(title)
    for i, contact in ipairs(contacts) do
        local btn = Button(service); local displayText = contact.name
        if contact.number then local formattedNumber = contact.number; if #formattedNumber > 6 then formattedNumber = "..." .. formattedNumber:sub(#formattedNumber-5) end; displayText = displayText .. " (" .. formattedNumber .. ")" end
        btn.setText(displayText); btn.setBackgroundColor(0xFF2196F3); btn.setTextColor(0xFFFFFFFF); btn.setPadding(10, 10, 10, 10); btn.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
        btn.onClick = function() if contactSelectionDialog then contactSelectionDialog.dismiss(); contactSelectionDialog = nil end; if callback then callback(contact) end end
        layout.addView(btn)
        if i < #contacts then local space = View(service); space.setLayoutParams(LinearLayout.LayoutParams(-1, 3)); layout.addView(space) end
    end
    local cancelBtn = Button(service); cancelBtn.setText("Cancel"); cancelBtn.setBackgroundColor(0xFFF44336); cancelBtn.setTextColor(0xFFFFFFFF); cancelBtn.setPadding(10, 10, 10, 10); cancelBtn.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
    cancelBtn.onClick = function() if contactSelectionDialog then contactSelectionDialog.dismiss(); contactSelectionDialog = nil end; speak("Cancelled"); if callback then callback(nil) end end
    layout.addView(cancelBtn)
    
    scrollView.addView(layout)
    contactSelectionDialog = LuaDialog(service); contactSelectionDialog.setTitle("Contact Selection"); contactSelectionDialog.setView(scrollView); contactSelectionDialog.setCancelable(true); contactSelectionDialog.show(); speak("Multiple contacts")
end

function showWhatsAppSelectionDialog(contactName, phoneNumber, callType, callback)
    local installedApps = getInstalledWhatsAppApps()
    if #installedApps == 0 then speak("No WhatsApp"); if callback then callback(nil) end; return end
    local preference = getWhatsAppPreference()
    if preference == WHATSAPP_PREF_MESSENGER then
        for _, app in ipairs(installedApps) do if app.package == WHATSAPP_PACKAGES.messenger then if callback then callback(WHATSAPP_PACKAGES.messenger) end; return end end
    elseif preference == WHATSAPP_PREF_BUSINESS then
        for _, app in ipairs(installedApps) do if app.package == WHATSAPP_PACKAGES.business then if callback then callback(WHATSAPP_PACKAGES.business) end; return end end
    end
    if #installedApps == 1 then if callback then callback(installedApps[1].package) end; return end
    
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(15, 15, 15, 15); layout.setBackgroundColor(0xFF0A0A0A)
    local title = TextView(service); title.setText("Select WhatsApp"); title.setTextColor(0xFF2196F3); title.setTextSize(16); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 10); layout.addView(title)
    for i, app in ipairs(installedApps) do
        local btn = Button(service); btn.setText(app.name); btn.setBackgroundColor(app.color); btn.setTextColor(0xFFFFFFFF); btn.setPadding(10, 10, 10, 10); btn.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
        btn.onClick = function() if selectionDialog then selectionDialog.dismiss(); selectionDialog = nil end; if callback then callback(app.package) end end
        layout.addView(btn)
        if i < #installedApps then local space = View(service); space.setLayoutParams(LinearLayout.LayoutParams(-1, 8)); layout.addView(space) end
    end
    local cancelBtn = Button(service); cancelBtn.setText("Cancel"); cancelBtn.setBackgroundColor(0xFFF44336); cancelBtn.setTextColor(0xFFFFFFFF); cancelBtn.setPadding(10, 10, 10, 10); cancelBtn.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
    cancelBtn.onClick = function() if selectionDialog then selectionDialog.dismiss(); selectionDialog = nil end; speak("Cancelled"); if callback then callback(nil) end end
    layout.addView(cancelBtn)
    
    scrollView.addView(layout)
    selectionDialog = LuaDialog(service); selectionDialog.setTitle("WhatsApp Selection"); selectionDialog.setView(scrollView); selectionDialog.setCancelable(true); selectionDialog.show(); speak("Select WhatsApp")
end

function startWhatsAppVoiceCall(packageName, contactName, phoneNumber)
    if not packageName then speak("WhatsApp not selected"); return end
    local cleanNumber = cleanPhoneNumber(phoneNumber)
    if cleanNumber:sub(1,1) == "0" then cleanNumber = "92" .. cleanNumber:sub(2) end
    local url = "https://wa.me/" .. cleanNumber
    local intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)); intent.setPackage(packageName); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    service.startActivity(intent)
    Handler().postDelayed(function()
        service.click({{"Voice call>15", "Call>15"}})
        Handler().postDelayed(function() service.click({{"Voice call>15"}}); attemptAutoSpeaker() end, CONSTANTS.DELAYS.BUTTON_WAIT)
    end, CONSTANTS.DELAYS.APP_OPEN_WAIT)
end

function startWhatsAppVideoCall(packageName, contactName, phoneNumber)
    if not packageName then speak("WhatsApp not selected"); return end
    local cleanNumber = cleanPhoneNumber(phoneNumber)
    if cleanNumber:sub(1,1) == "0" then cleanNumber = "92" .. cleanNumber:sub(2) end
    local url = "https://wa.me/" .. cleanNumber
    local intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)); intent.setPackage(packageName); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    service.startActivity(intent)
    Handler().postDelayed(function()
        service.click({{"Video call>15", "Call>15"}})
        Handler().postDelayed(function() service.click({{"Video call>15"}}); attemptAutoSpeaker() end, CONSTANTS.DELAYS.BUTTON_WAIT)
    end, CONSTANTS.DELAYS.APP_OPEN_WAIT)
end

function startWhatsAppChat(packageName, contactName, phoneNumber)
    if not packageName then speak("WhatsApp not selected"); return end
    local cleanNumber = cleanPhoneNumber(phoneNumber)
    if cleanNumber:sub(1,1) == "0" then cleanNumber = "92" .. cleanNumber:sub(2) end
    local url = "https://wa.me/" .. cleanNumber
    local intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)); intent.setPackage(packageName); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    service.startActivity(intent)
end
function runCalls(input)
    local name = ""; local actionType = ""
    if input:find("^" .. getCommandKeyword("voice call") .. " ") then name = input:gsub("^" .. getCommandKeyword("voice call") .. " ", ""):gsub("^%s*(.-)%s*$", "%1"); actionType = "voice"
    elseif input:find("^" .. getCommandKeyword("video call") .. " ") then name = input:gsub("^" .. getCommandKeyword("video call") .. " ", ""):gsub("^%s*(.-)%s*$", "%1"); actionType = "video"
    elseif input:find("^" .. getCommandKeyword("chat") .. " ") then name = input:gsub("^" .. getCommandKeyword("chat") .. " ", ""):gsub("^%s*(.-)%s*$", "%1"); actionType = "chat"
    elseif input:find("^" .. getCommandKeyword("call") .. " ") then name = input:gsub("^" .. getCommandKeyword("call") .. " ", ""):gsub("^%s*(.-)%s*$", "%1"); actionType = "phone"
    else return false end
    
    if name == "" then return false end
    
    local possibleNum = name:lower():gsub("zero", "0"):gsub("one", "1"):gsub("two", "2"):gsub("three", "3"):gsub("four", "4"):gsub("five", "5"):gsub("six", "6"):gsub("seven", "7"):gsub("eight", "8"):gsub("nine", "9"):gsub("plus", "+")
    possibleNum = possibleNum:gsub("[%s%-]", "")
    
    local isDirectNumber = false
    if possibleNum:match("^%+%d+$") or possibleNum:match("^%d+$") then
        if #possibleNum >= 7 then isDirectNumber = true end
    end
    
    if isDirectNumber then
        local contact = {name = possibleNum, number = possibleNum}
        if actionType == "chat" or actionType == "voice" or actionType == "video" then
            showWhatsAppSelectionDialog(contact.name, contact.number, actionType, function(packageName)
                if packageName then
                    if actionType == "voice" then 
                        speak("making voice call to " .. contact.name)
                        startWhatsAppVoiceCall(packageName, contact.name, contact.number) 
                    elseif actionType == "video" then 
                        speak("making video call to " .. contact.name)
                        startWhatsAppVideoCall(packageName, contact.name, contact.number) 
                    else 
                        speak("opening " .. contact.name .. " WhatsApp chat")
                        startWhatsAppChat(packageName, contact.name, contact.number) 
                    end
                end
            end)
        else
            local intent = Intent(Intent.ACTION_CALL, Uri.parse("tel:"..contact.number)); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(intent)
            speak("making phone call to " .. contact.name)
            attemptAutoSpeaker()
        end
        return true
    end
    
    name = name:lower():gsub("mohammed", "muhammad"):gsub("mohammad", "muhammad")
    
    local actualContactName = getContactByKeyword(name)
    if actualContactName then name = actualContactName end
    
    local contacts = {}
    local uniqueContacts = {}
    
    local flexName = name:gsub("%s+", "%%")
    local searchPattern1 = name 
    local searchPattern2 = "%" .. flexName .. "%" 

    local cur = service.getContentResolver().query(
        ContactsContract.CommonDataKinds.Phone.CONTENT_URI, 
        nil, 
        "display_name LIKE ? OR display_name LIKE ?", 
        {"%"..searchPattern1.."%", searchPattern2}, 
        "display_name ASC"
    )
    
    if cur then
        while cur.moveToNext() do
            local contactName = cur.getString(cur.getColumnIndex("display_name"))
            local phoneNumber = cur.getString(cur.getColumnIndex("data1"))
            local contactId = cur.getString(cur.getColumnIndex("contact_id"))
            if contactName and phoneNumber then
                local cleanedNumber = cleanPhoneNumber(phoneNumber)
                local uniqueKey = contactName .. "_" .. cleanedNumber
                
                local cNamePadded = " " .. contactName:lower() .. " "
                local isMatch = true
                for word in name:lower():gmatch("%S+") do
                    local escapedWord = word:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
                    if not cNamePadded:find("%s" .. escapedWord) then
                        isMatch = false
                        break
                    end
                end
                
                if isMatch and not uniqueContacts[uniqueKey] then 
                    table.insert(contacts, {name = contactName, number = phoneNumber, cleanedNumber = cleanedNumber, contactId = contactId})
                    uniqueContacts[uniqueKey] = true 
                end
            end
        end
        cur.close()
    end
    
    table.sort(contacts, function(a, b)
        local aName = a.name:lower()
        local bName = b.name:lower()
        local searchName = name:lower()
        local aExact = (aName == searchName)
        local bExact = (bName == searchName)
        if aExact and not bExact then return true end
        if bExact and not aExact then return false end
        local aStarts = aName:find("^" .. searchName) ~= nil
        local bStarts = bName:find("^" .. searchName) ~= nil
        if aStarts and not bStarts then return true end
        if bStarts and not aStarts then return false end
        return aName < bName
    end)
    
    if #contacts == 0 then speak("Contact not found for " .. name); return true end
    
    if #contacts == 1 then
        local contact = contacts[1]
        if actionType == "chat" or actionType == "voice" or actionType == "video" then
            showWhatsAppSelectionDialog(contact.name, contact.number, actionType, function(packageName)
                if packageName then
                    if actionType == "voice" then 
                        speak("making voice call to " .. contact.name)
                        startWhatsAppVoiceCall(packageName, contact.name, contact.number) 
                    elseif actionType == "video" then 
                        speak("making video call to " .. contact.name)
                        startWhatsAppVideoCall(packageName, contact.name, contact.number) 
                    else 
                        speak("opening " .. contact.name .. " WhatsApp chat")
                        startWhatsAppChat(packageName, contact.name, contact.number) 
                    end
                end
            end)
        else
            local intent = Intent(Intent.ACTION_CALL, Uri.parse("tel:"..contact.number)); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(intent)
            speak("making phone call to " .. contact.name)
            attemptAutoSpeaker()
        end
        return true
    end
    
    currentContactSelection = {actionType = actionType, contacts = contacts}
    showContactSelectionDialog(contacts, actionType, function(selectedContact)
        if not selectedContact then return end
        if actionType == "chat" or actionType == "voice" or actionType == "video" then
            showWhatsAppSelectionDialog(selectedContact.name, selectedContact.number, actionType, function(packageName)
                if packageName then
                    if actionType == "voice" then 
                        speak("making voice call to " .. selectedContact.name)
                        startWhatsAppVoiceCall(packageName, selectedContact.name, selectedContact.number) 
                    elseif actionType == "video" then 
                        speak("making video call to " .. selectedContact.name)
                        startWhatsAppVideoCall(packageName, selectedContact.name, selectedContact.number) 
                    else 
                        speak("opening " .. selectedContact.name .. " WhatsApp chat")
                        startWhatsAppChat(packageName, selectedContact.name, selectedContact.number) 
                    end
                end
            end)
        else
            local intent = Intent(Intent.ACTION_CALL, Uri.parse("tel:"..selectedContact.number)); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(intent)
            speak("making phone call to " .. selectedContact.name)
            attemptAutoSpeaker()
        end
    end)
    return true
end

function runMediaSearch(input)
    input = input:lower(); if not input:find("^search .* on ") then return false end
    local query, platform
    if input:find("^search song .* on youtube music$") then query = input:gsub("^search song ", ""):gsub(" on youtube music$", ""):gsub("^%s*(.-)%s*$", "%1"); platform = "youtube music"
    elseif input:find("^search .* on youtube$") then query = input:gsub("^search ", ""):gsub(" on youtube$", ""):gsub("^%s*(.-)%s*$", "%1"); platform = "youtube"
    elseif input:find("^search .* on spotify$") then query = input:gsub("^search ", ""):gsub(" on spotify$", ""):gsub("^%s*(.-)%s*$", "%1"); platform = "spotify"
    elseif input:find("^search .* on google$") then query = input:gsub("^search ", ""):gsub(" on google$", ""):gsub("^%s*(.-)%s*$", "%1"); platform = "google"
    elseif input:find("^search .* on play store$") then query = input:gsub("^search ", ""):gsub(" on play store$", ""):gsub("^%s*(.-)%s*$", "%1"); platform = "play store"
    else return false end
    if not query or query == "" then return false end
    speak("Searching " .. query .. " on " .. platform)
    local intent = nil
    if platform == "spotify" then intent = Intent(Intent.ACTION_VIEW, Uri.parse("spotify:search:" .. Uri.encode(query)))
    elseif platform == "play store" then intent = Intent(Intent.ACTION_VIEW, Uri.parse("market://search?q=" .. Uri.encode(query))); intent.setPackage("com.android.vending")
    elseif platform == "youtube music" then intent = Intent(Intent.ACTION_SEARCH); intent.setPackage("com.google.android.apps.youtube.music"); intent.putExtra(SearchManager.QUERY, query)
    elseif platform == "youtube" then intent = Intent(Intent.ACTION_SEARCH); intent.setPackage("com.google.android.youtube"); intent.putExtra(SearchManager.QUERY, query)
    elseif platform == "google" then intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.google.com/search?q=" .. Uri.encode(query))) end
    if intent then intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(intent) end
    return true
end

function runCalculator(input)
    local originalInput = input
    input = input:lower():gsub("plus", "+"):gsub("add", "+"):gsub("sum", "+"):gsub("minus", "-"):gsub("subtract", "-"):gsub("multiplied by", "*"):gsub("multiply", "*"):gsub("times", "*"):gsub("divided by", "/"):gsub("divide", "/"):gsub("over", "/")
    local expression = input:gsub("%s+", "")
    if expression == "" then return false end
    if not expression:match("^[0-9%+%-%*/%.]+$") then return false end
    if expression:match("[%+%-%*/%.][%+%-%*/%.]") then return false end
    local success, result = pcall(function() return loadstring("return " .. expression)() end)
    if success and result then speak(originalInput .. " = " .. tostring(result)); return true else speak("Invalid calculation"); return true end
end

function openAppWithForceLogic(appName)
    if not appName or appName == "" then return end
    local pm = service.getPackageManager()
    if appName:find("deep") or appName:find("seek") or appName:find("sea") then
        local intent = pm.getLaunchIntentForPackage("com.deepseek.chat")
        if intent then intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(intent); speak("Opening DeepSeek"); return true end
    end
    local apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
    for i = 0, apps.size() - 1 do
        local info = apps.get(i); local label = tostring(info.loadLabel(pm)):lower()
        if label:find(appName, 1, true) or appName:find(label, 1, true) then
            local intent = pm.getLaunchIntentForPackage(info.packageName)
            if intent then intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(intent); speak("Opening " .. tostring(info.loadLabel(pm))); return true end
        end
    end
    speak("I'm sorry, I couldn't find " .. appName)
    return false
end

function executeTwoPassResult(type, name)
    if not name or name == "" then speak("No name provided"); return end
    if type == "function" then
        local spokenWords = {}
        for w in name:gmatch("%S+") do table.insert(spokenWords, w) end
        local bestMatch = nil; local minLengthDiff = 9999
        for _, f in ipairs(FUNCTIONS_LIST) do
            local fl = f:lower(); local matchCount = 0
            for _, w in ipairs(spokenWords) do if fl:find(w, 1, true) then matchCount = matchCount + 1 end end
            if matchCount > 0 and matchCount == #spokenWords then
                local diff = #fl - #name
                if diff < minLengthDiff then minLengthDiff = diff; bestMatch = f end
            end
        end
        if not bestMatch then
            local cleanName = name:gsub("%s+", "")
            for _, f in ipairs(FUNCTIONS_LIST) do
                local cleanF = f:lower():gsub("%s+", "")
                if cleanF:find(cleanName, 1, true) or cleanName:find(cleanF, 1, true) then bestMatch = f; break end
            end
        end
        if bestMatch then speak("Executed function: " .. bestMatch); service.execute(bestMatch) else speak("Function not found: " .. name) end
    elseif type == "tool" then
        local cleanName = name:gsub("%s+", "")
        local toolPathDir = "/storage/emulated/0/解说/Tools/"; local toolFiles = File(toolPathDir).listFiles(); local bestMatch = nil
        if toolFiles then
            for i=0, #toolFiles-1 do
                if toolFiles[i].isDirectory() then
                    local dirName = toolFiles[i].getName():lower():gsub("%s+", "")
                    if dirName:find(cleanName, 1, true) then bestMatch = {name = toolFiles[i].getName()}; break end
                end
            end
        end
        if bestMatch then local realName = bestMatch.name:gsub("%.lua$", ""); speak("Executed tool: " .. realName); service.tool(realName) else speak("Tool not found: " .. name) end
    elseif type == "extension" or type == "plugin" then
        local cleanName = name:gsub("%s+", "")
        local pluginPathDir = "/storage/emulated/0/解说/Plugins/"; local pluginFiles = File(pluginPathDir).listFiles(); local bestMatch = nil
        if pluginFiles then
            for i=0, #pluginFiles-1 do
                if pluginFiles[i].isDirectory() then
                    local dirName = pluginFiles[i].getName():lower():gsub("%s+", "")
                    if dirName:find(cleanName, 1, true) then bestMatch = {name = pluginFiles[i].getName()}; break end
                elseif pluginFiles[i].isFile() and pluginFiles[i].getName():lower():match("%.lua$") then
                    local fileName = pluginFiles[i].getName():lower():gsub("%s+", "")
                    if fileName:find(cleanName, 1, true) then bestMatch = {name = pluginFiles[i].getName()}; break end
                end
            end
        end
        if bestMatch then
            local realName = bestMatch.name:gsub("%.lua$", ""); speak("Executed plugin: " .. realName); local rootNode = service.getRootInActiveWindow(); service.plugin(realName, rootNode)
        else speak("Plugin not found: " .. name) end
    end
end

function runSystem(input)
    if input:find(getCommandKeyword("assistant setting")) then showSettingsDialog(); return true end
    if input:find(getCommandKeyword("command list")) then showAllCommandsDialog(); return true end
    
    -- "tf" کمانڈ کا بگ فکس: سپیس کو ختم کر کے چیک کرے گا
    local noSpaceInput = input:gsub("%s+", "")
    if noSpaceInput == getCommandKeyword("turn off screen reader"):gsub("%s+", "") then 
        service.speak("Jieshuo off")
        while service.isSpeaking() do end
        service.disableSelf()
        return true 
    end
    
    if noSpaceInput == getCommandKeyword("restart screen reader"):gsub("%s+", "") then 
        speak("Restarting"); os.exit(0); return true 
    end
    
    if input:find(getCommandKeyword("accessibility settings")) then 
        local accIntent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        accIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        service.startActivity(accIntent)
        speak("Accessibility")
        return true 
    end
    
    if input:find(getCommandKeyword("how to use")) then openHowToUseVideo(); return true end
    
    if input == getCommandKeyword("stop listening") then stopAllSpeechRecognizers(); vibrateDevice(); return true end
    
    if input == getCommandKeyword("spell this") then
        local rootNode = service.getRootInActiveWindow()
        local textToSpell = ""
        if rootNode then
            local targetNode = rootNode.findFocus(2)
            if not targetNode then targetNode = rootNode.findFocus(1) end
            if targetNode then
                local t = targetNode.getText(); local d = targetNode.getContentDescription()
                if t and tostring(t) ~= "" then textToSpell = tostring(t) elseif d and tostring(d) ~= "" then textToSpell = tostring(d) end
            end
        end
        
        if textToSpell ~= "" then
            local finalSpeech = ""
            for word in textToSpell:gmatch("%S+") do
                local spelled = word:gsub(".", "%1, ") 
                finalSpeech = finalSpeech .. spelled .. " . " .. word .. " . "
            end
            if isToastReadEnabled() then speak(finalSpeech) else service.speak(finalSpeech) end
        else
            if isToastReadEnabled() then speak("No text found to spell") else service.speak("No text found to spell") end
        end
        return true
    end
    
    if input:find(getCommandKeyword("current battery")) then local lvl = service.registerReceiver(nil, IntentFilter(Intent.ACTION_BATTERY_CHANGED)).getIntExtra("level", -1); speak("Battery " .. lvl .. "%"); return true end
    if input:find(getCommandKeyword("current time")) then speak("Time " .. os.date("%I:%M %p")); return true end
    if input:find(getCommandKeyword("current date")) then return speakCurrentDate() end
    if input:find(getCommandKeyword("speech rate")) then local rate = tonumber(input:match("(%d+)")); if rate then service.setTTSSpeed(rate); speak("Speech rate set to " .. rate); return true end end
    
    if input == getCommandKeyword("send now") then
        local pref = getWhatsAppPreference()
        if pref == WHATSAPP_PREF_BUSINESS then
            local success = service.click({{"%Direct long press","Share|More|Send>15","WhatsApp Business|Share>15","WhatsApp Business>15"}})
            if not success then success = service.click({">WA Business>15"}) end
            if not success then success = service.click({"WhatsApp Business>15"}) end
            if success then speak("Sent") else speak("Share not found") end
        else
            if service.click({{"%Direct long press","Share|More|Send>15","WhatsApp|Share>15","WhatsApp>15"}}) then speak("Sent") else speak("Share not found") end
        end
        return true
    end
    if input == getCommandKeyword("uninstall") then
        if service.click({{"%Long press", "Uninstall>15"}}) then Handler().postDelayed(function() if service.click({{"Uninstall>15", "OK>15"}}) then speak("Uninstalled") else speak("Confirmation button not found") end end, CONSTANTS.DELAYS.LONG) else speak("Uninstall not found") end
        return true
    end
    if input == getCommandKeyword("remove application") then if service.click({{"%Direct long press","Remove*>15"}}) then speak("Removed") else speak("Remove option not found") end return true end
    if input == getCommandKeyword("delete from everyone") then if service.click({{"%Direct long press","Delete>15","Delete for everyone>15","Delete for everyone>15"}}) then speak("Deleted for everyone") else speak("Option not found") end return true end
    if input == getCommandKeyword("toggle silent mode") or input == "silent" or input == "mute" then
        local am = service.getSystemService(Context.AUDIO_SERVICE); local nm = service.getSystemService(Context.NOTIFICATION_SERVICE)
        if not nm.isNotificationPolicyAccessGranted() then speak("Please grant Do Not Disturb access first"); local intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(intent); return true end
        local mode = am.getRingerMode()
        if mode == AudioManager.RINGER_MODE_NORMAL then am.setRingerMode(AudioManager.RINGER_MODE_VIBRATE); speak("Vibration mode") elseif mode == AudioManager.RINGER_MODE_VIBRATE then am.setRingerMode(AudioManager.RINGER_MODE_SILENT); speak("Silent mode") else am.setRingerMode(AudioManager.RINGER_MODE_NORMAL); speak("Normal mode") end
        playSoundTick(); vibrateDevice(); return true
    end
    if input == getCommandKeyword("toggle bluetooth") then
        local bt = BluetoothAdapter.getDefaultAdapter()
        if bt then if bt.isEnabled() then bt.disable(); speak("Bluetooth disabled") else bt.enable(); speak("Bluetooth enabled") end; playSoundTick(); vibrateDevice() else speak("Bluetooth not supported") end
        return true
    end
    if input == getCommandKeyword("toggle flashlight") then
        local cm = service.getSystemService(Context.CAMERA_SERVICE); local list = cm.getCameraIdList()
        if list and #list > 0 then isFlashOn = not isFlashOn; cm.setTorchMode(list[0], isFlashOn); speak(isFlashOn and "Flashlight on" or "Flashlight off"); playSoundTick(); vibrateDevice() end
        return true
    end
    
    -- موبائل ڈیٹا فکس
    if input == getCommandKeyword("toggle mobile data") then
        local intent = Intent("android.settings.panel.action.INTERNET_CONNECTIVITY")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        service.startActivity(intent)
        
        Handler().postDelayed(function()
            local dataNames = {"Mobile data", "Mobile Data", "Cellular data", "Cellular Data", "Data connection"}
            local confirmBtns = {"Turn off", "Turn Off", "OK", "确定", "关闭"}
            local btnList = {dataNames, confirmBtns, dataNames}
            
            if service.click(btnList) then
                playSoundTick()
                speak("Mobile data has been toggled successfully")
                Handler().postDelayed(function() service.toBack() end, 400)
            else
                Handler().postDelayed(function()
                    if service.click(btnList) then
                        playSoundTick()
                        speak("Mobile data is now switched")
                        service.toBack()
                    else
                        speak("Toggle failed. Please check screen text.")
                    end
                end, 600)
            end
        end, 500)
        return true
    end
    
    -- وائی فائی فکس
    local cleanInput = input:gsub("%-", ""):gsub("%s+", "")
    local wifiCmd = getCommandKeyword("toggle wifi"):gsub("%-", ""):gsub("%s+", "")
    
    if cleanInput == wifiCmd then
        local intent = Intent("android.settings.panel.action.INTERNET_CONNECTIVITY")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        service.startActivity(intent)
        
        Handler().postDelayed(function()
            local btnList = {"Wi-Fi", {"Turn off", "OK", "确定", "关闭", "WLAN"}, "Wi-Fi"}
            if service.click(btnList) then
                playSoundTick()
                speak("Wi-Fi has been toggled successfully")
                Handler().postDelayed(function() service.toBack() end, 400)
            else
                Handler().postDelayed(function()
                    if service.click(btnList) then
                        playSoundTick()
                        speak("Wi-Fi is now switched")
                        service.toBack()
                    else
                        speak("Toggle failed.")
                    end
                end, 600)
            end
        end, 500)
        return true
    end
    
    local vol = tonumber(input:match("(%d+)"))
    if vol then
        local am = service.getSystemService(Context.AUDIO_SERVICE); local stream = -1
        if input:find(getCommandKeyword("accessibility volume")) then stream = AudioManager.STREAM_ACCESSIBILITY elseif input:find(getCommandKeyword("ring volume")) then stream = AudioManager.STREAM_RING elseif input:find(getCommandKeyword("alarm volume")) then stream = AudioManager.STREAM_NOTIFICATION elseif input:find(getCommandKeyword("notification volume")) then stream = AudioManager.STREAM_NOTIFICATION elseif input:find(getCommandKeyword("volume")) then stream = AudioManager.STREAM_MUSIC end
        if stream ~= -1 then local maxVol = am.getStreamMaxVolume(stream); local targetVol = math.floor((vol/100)*maxVol); am.setStreamVolume(stream, targetVol, 1); speak("Volume set to " .. vol .. " percent"); return true end
    end
    if input:find(getCommandKeyword("brightness")) then
        local number = input:match("%d+")
        if number then
            local percent = tonumber(number)
            if percent >= 0 and percent <= 100 then
                if not Settings.System.canWrite(service) then speak("Please allow system settings permission first"); local intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS, Uri.parse("package:" .. service.getPackageName())); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(intent); return true end
                local targetValue = math.floor((percent / 100) * 255); local resolver = service.getContentResolver(); Settings.System.putInt(resolver, Settings.System.SCREEN_BRIGHTNESS_MODE, 0); Settings.System.putInt(resolver, Settings.System.SCREEN_BRIGHTNESS, targetValue); local uri = Settings.System.getUriFor("screen_brightness"); resolver.notifyChange(uri, nil); speak("Brightness is now " .. percent .. " percent"); return true
            else speak("Please say a number between 0 and 100") end
        else speak("Please say brightness followed by a number") end
        return true
    end
    
    if input:find("^" .. getCommandKeyword("function") .. " ") then
        local funcPart = input:gsub("^" .. getCommandKeyword("function") .. "%s+", ""):gsub("^%s*(.-)%s*$", "%1")
        if funcPart ~= "" then
            local spokenWords = {}
            for w in funcPart:gmatch("%S+") do table.insert(spokenWords, w) end
            local bestMatch = nil; local minLengthDiff = 9999
            for _, f in ipairs(FUNCTIONS_LIST) do
                local fl = f:lower(); local matchCount = 0
                for _, w in ipairs(spokenWords) do if fl:find(w, 1, true) then matchCount = matchCount + 1 end end
                if matchCount > 0 and matchCount == #spokenWords then
                    local diff = #fl - #funcPart
                    if diff < minLengthDiff then minLengthDiff = diff; bestMatch = f end
                end
            end
            if not bestMatch then
                local cleanName = funcPart:gsub("%s+", "")
                for _, f in ipairs(FUNCTIONS_LIST) do
                    local cleanF = f:lower():gsub("%s+", "")
                    if cleanF:find(cleanName, 1, true) or cleanName:find(cleanF, 1, true) then bestMatch = f; break end
                end
            end
            if bestMatch then speak("Executed function: " .. bestMatch); service.execute(bestMatch) else speak("Function not found: " .. funcPart) end
        else speak("Please say a function name") end
        return true
    end
    if input:find("^" .. getCommandKeyword("tool") .. " ") then local toolName = input:gsub("^" .. getCommandKeyword("tool") .. "%s+", ""):gsub("%s+", ""); if toolName ~= "" then executeTwoPassResult("tool", toolName) else speak("Please say a tool name") end return true end
    if input:find("^" .. getCommandKeyword("extension") .. " ") or input:find("^" .. getCommandKeyword("plugin") .. " ") then
        local kw = getCommandKeyword("extension"); local pluginName = input:gsub("^" .. kw .. "%s+", ""):gsub("%s+", "")
        if pluginName == "" then kw = getCommandKeyword("plugin"); pluginName = input:gsub("^" .. kw .. "%s+", ""):gsub("%s+", "") end
        if pluginName ~= "" then executeTwoPassResult("extension", pluginName) else speak("Please say a plugin name") end
        return true
    end
    local fmt = input:gsub("(%a)([%w']*)", function(f, r) return f:upper()..r:lower() end)
    if service.click({{"%" .. fmt}}) then speak("Clicked " .. fmt); return true end
    if service.click({input}) then speak("Clicked " .. input); return true end
    return false
end

function runDirectAction(input)
    if input:find("^" .. getCommandKeyword("find") .. " ") then
        local query = input:gsub("^" .. getCommandKeyword("find") .. " ", ""):gsub("^%s*(.-)%s*$", "%1"):lower()
        if query ~= "" then
            local rootNode = service.getRootInActiveWindow()
            if rootNode then
                local targetNode = nil
                local function exactSearch(node)
                    if not node then return end
                    if not targetNode and node.isVisibleToUser() then
                        local t = node.getText(); local d = node.getContentDescription()
                        local nodeText = t and tostring(t):lower():gsub("^%s*(.-)%s*$", "%1") or ""
                        local nodeDesc = d and tostring(d):lower():gsub("^%s*(.-)%s*$", "%1") or ""
                        if nodeText == query or nodeDesc == query then
                            targetNode = node
                            return
                        end
                    end
                    for i = 0, node.getChildCount() - 1 do
                        if targetNode then break end
                        exactSearch(node.getChild(i))
                    end
                end
                
                exactSearch(rootNode)
                
                if targetNode then 
                    targetNode.performAction(64); speak("Focused") 
                else 
                    speak(query .. " not found on screen") 
                end
            else 
                speak("Screen content not available") 
            end
        else 
            speak("Please say what to find") 
        end
        return true
    end

    if input == getCommandKeyword("mention all") then service.playSoundTick(); service.paste("@"); Handler().postDelayed(function() if service.click({{"all, Mention all members in this chat>15","Send>15"}}) then speak("All members mentioned") end end, CONSTANTS.DELAYS.BUTTON_WAIT); return true end
    if input == getCommandKeyword("clear chat") then if service.click({{"More options>15","More*>15","*Clear chat*>15","CLEAR CHAT*>15"}}) then speak("Chat cleared") else speak("Option not found") end return true end
    if input == getCommandKeyword("only admin mode") then if service.click({{"*More options*>15","*Group info*>15","<More options*>15","*Group permissions*>15","*Send*>15","*Back>15"}}) then speak("Admin only mode set") else speak("Option not found") end return true end
    if input == getCommandKeyword("rename it") then if service.click({{"%Direct long press","Rename|More>15","Rename>15"}}) then speak("Rename option selected") else speak("Option not found") end return true end
    if input == getCommandKeyword("delete from me") then if service.click({{"%Direct long press","Delete>15","Delete for me>15","DELETE>15"}}) then Handler().postDelayed(function() service.click({{"DELETE>15","Delete>15","YES>15","Yes>15"}}) end, CONSTANTS.DELAYS.BUTTON_WAIT); speak("Deleted for me") else speak("Option not found") end return true end
    if input == getCommandKeyword("delete now") then if service.click({{"%Direct long press","Delete>15","DELETE>15"}}) then Handler().postDelayed(function() service.click({{"DELETE>15","Delete>15","YES>15","Yes>15"}}) end, CONSTANTS.DELAYS.BUTTON_WAIT); speak("Deleted") else speak("Option not found") end return true end
    if input == getCommandKeyword("delete number") then if service.click({{"%Direct click","More options>15","View contact>15","More options>15","Delete contact>15","DELETE>15"}}) then speak("Contact deleted") else speak("Option not found") end return true end
    if input == getCommandKeyword("application info") then local root = service.getRootInActiveWindow(); if root then local intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:"..tostring(root.getPackageName()))); intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); service.startActivity(intent); speak("Application info") else speak("No app open") end return true end
    if input:find("^" .. getCommandKeyword("open") .. " ") then local appName = input:gsub("^" .. getCommandKeyword("open") .. " ", ""):gsub("^%s*(.-)%s*$", "%1"):lower(); return openAppWithForceLogic(appName) end
    if input == getCommandKeyword("function") then startTwoPassRecognition("function"); return true end
    if input == getCommandKeyword("tool") then startTwoPassRecognition("tool"); return true end
    if input == getCommandKeyword("extension") or input == getCommandKeyword("plugin") then startTwoPassRecognition("extension"); return true end
    
    if input == getCommandKeyword("share and copy") then
        if service.click({{"Share*>15@*", "Copy link>15"}}) then speak("Done") else speak("Option not found") end
        return true
    end
    if input == getCommandKeyword("delete status") then
        if service.click({{"More options>15@WhatsApp", "Delete*>15@WhatsApp", "Delete*>15@WhatsApp"}}) then speak("Status deleted") else speak("Option not found") end
        return true
    end
    if input == getCommandKeyword("clear call history") then
        if service.click({{"Calls>15", "More options>15", "Clear call log>15", "OK>15"}}) then speak("Call history cleared") else speak("Option not found") end
        return true
    end
    if input == getCommandKeyword("switch account") then
        if service.click({{"More options>15@WhatsApp", "Switch account>15@WhatsApp"}}) then speak("Account switched") else speak("Option not found") end
        return true
    end
    
    return false
end

function startTwoPassRecognition(type)
    stopAllSpeechRecognizers()
    twoPassMode = type
    vibrateDevice()
    local now = System.currentTimeMillis()
    if now - lastCommandTime < CONSTANTS.DELAYS.FAST then lastCommandTime = now; return end
    lastCommandTime = now
    mainSpeechRecognizer = SpeechRecognizer.createSpeechRecognizer(service)
    local intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
    intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
    intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
    intent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, false)
    intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
    local listener = RecognitionListener {
        onResults = function(results)
            isListening = false; abandonAudioFocus()
            local arr = results.getParcelableArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            if arr and arr.size() > 0 then
                local name = arr.get(0):lower():gsub("^%s*(.-)%s*$", "%1")
                if name ~= "" then executeTwoPassResult(type, name) else vibrateDevice() end
            else vibrateDevice() end
            twoPassMode = nil; mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer); Handler().postDelayed(function() startSmartAssistant() end, CONSTANTS.DELAYS.MEDIUM)
        end,
        onError = function(e)
            isListening = false; abandonAudioFocus()
            if e == SpeechRecognizer.ERROR_NETWORK then speak("Internet connection required") 
            elseif e == SpeechRecognizer.ERROR_AUDIO then if not service.checkPermission("android.permission.RECORD_AUDIO") then speak("Microphone permission not granted") else vibrateDevice() end 
            else vibrateDevice() end
            twoPassMode = nil; mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer); Handler().postDelayed(function() startSmartAssistant() end, CONSTANTS.DELAYS.MEDIUM)
        end
    }
    mainSpeechRecognizer.setRecognitionListener(listener)
    if mainSpeechRecognizer then 
        pcall(function() mainSpeechRecognizer.startListening(intent); isListening = true end) 
    end
end

function startSmartAssistant()
    if twoPassMode then return end
    stopAllSpeechRecognizers()
    vibrateDevice()
    requestAudioFocus()
    local now = System.currentTimeMillis()
    if now - lastCommandTime < CONSTANTS.DELAYS.FAST then lastCommandTime = now; return end
    lastCommandTime = now
    mainSpeechRecognizer = SpeechRecognizer.createSpeechRecognizer(service)
    local intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
    intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
    intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
    intent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, false)
    intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
    intent.putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 10000)
    intent.putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 800)
    intent.putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 800)
    local listener = RecognitionListener {
        onResults = function(results)
            isListening = false; abandonAudioFocus()
            local arr = results.getParcelableArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            if arr and arr.size() > 0 then
                for i = 0, math.min(arr.size() - 1, 2) do
                    local input = arr.get(i):lower()
                    if runCalls(input) then mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer); return
                    elseif runMediaSearch(input) then mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer); return
                    elseif runSystem(input) then mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer); return
                    elseif runCalculator(input) then mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer); return
                    elseif runDirectAction(input) then mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer); return
                    else
                        local rootNode = service.getRootInActiveWindow()
                        if rootNode then
                            local nodes = rootNode.findAccessibilityNodeInfosByText(arr.get(i))
                            if nodes and nodes.size() > 0 then
                                nodes.get(0).performAction(AccessibilityNodeInfo.ACTION_CLICK); speak("Clicked"); mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer); return
                            end
                        end
                    end
                end
                speak("Not recognized")
            end
            mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer)
        end,
        onError = function(e)
            isListening = false; abandonAudioFocus()
            if e == SpeechRecognizer.ERROR_NO_MATCH then speak("Not recognized") 
            elseif e == SpeechRecognizer.ERROR_SPEECH_TIMEOUT then speak("No speech detected") 
            elseif e == SpeechRecognizer.ERROR_NETWORK then speak("Internet connection required for voice recognition.") 
            elseif e == SpeechRecognizer.ERROR_AUDIO then if not service.checkPermission("android.permission.RECORD_AUDIO") then speak("Microphone permission not granted.") else speak("Audio error.") end 
            else speak("Error, try again") end
            mainSpeechRecognizer = destroyMainSpeechRecognizer(mainSpeechRecognizer)
        end
    }
    mainSpeechRecognizer.setRecognitionListener(listener)
    if mainSpeechRecognizer then 
        pcall(function() mainSpeechRecognizer.startListening(intent); isListening = true end) 
    end
end

function showWelcomeDialog()
    local pref = getPref(); local welcomeShown = pref.getBoolean(WELCOME_DIALOG_SHOWN_KEY, false)
    if welcomeShown then return false end
    
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service)
    layout.setOrientation(LinearLayout.VERTICAL)
    layout.setPadding(40, 40, 40, 40)
    layout.setBackgroundColor(0xFF0A0A0A)
    
    local instruction = TextView(service)
    instruction.setText("Welcome to Spark Voice Assistant by Muhammad hanzla, If you are using this powerful extension for the first time, we highly recommend clicking the 'Watch Tutorial' button below to get started and unlock its full potential.")
    instruction.setTextColor(0xFFFFFFFF)
    instruction.setTextSize(16)
    instruction.setGravity(Gravity.CENTER)
    instruction.setPadding(0, 0, 0, 30)
    layout.addView(instruction)
    
    local dontShowCheckBox = CheckBox(service)
    dontShowCheckBox.setText("Don't show this again")
    dontShowCheckBox.setTextColor(0xFFFFFFFF)
    dontShowCheckBox.setTextSize(14)
    dontShowCheckBox.setPadding(10, 15, 10, 20)
    layout.addView(dontShowCheckBox)
    
    local buttonLayout = LinearLayout(service)
    buttonLayout.setOrientation(LinearLayout.HORIZONTAL)
    buttonLayout.setGravity(Gravity.CENTER)
    
    local tutorialBtn = Button(service)
    tutorialBtn.setText("WATCH TUTORIAL")
    tutorialBtn.setBackgroundColor(0xFF2196F3)
    tutorialBtn.setTextColor(0xFFFFFFFF)
    tutorialBtn.setPadding(15, 15, 15, 15)
    tutorialBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1))
    
    local okayBtn = Button(service)
    okayBtn.setText("ok")
    okayBtn.setBackgroundColor(0xFF4CAF50)
    okayBtn.setTextColor(0xFFFFFFFF)
    okayBtn.setPadding(15, 15, 15, 15)
    
    local okParams = LinearLayout.LayoutParams(0, -2, 1)
    okParams.setMargins(15, 0, 0, 0)
    okayBtn.setLayoutParams(okParams)
    
    buttonLayout.addView(tutorialBtn)
    buttonLayout.addView(okayBtn)
    layout.addView(buttonLayout)
    
    scrollView.addView(layout)
    local dialog = LuaDialog(service)
    dialog.setTitle(" ")
    dialog.setView(scrollView)
    dialog.setCancelable(false)
    
    tutorialBtn.onClick = function()
        if dontShowCheckBox.isChecked() then 
            getEdit().putBoolean(WELCOME_DIALOG_SHOWN_KEY, true)
            getEdit().commit() 
        end
        dialog.dismiss()
        local intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://youtu.be/BQEREUKKkR8"))
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        service.startActivity(intent)
        speak("Video opened")
    end
    
    okayBtn.onClick = function() 
        if dontShowCheckBox.isChecked() then 
            getEdit().putBoolean(WELCOME_DIALOG_SHOWN_KEY, true)
            getEdit().commit() 
        end
        dialog.dismiss()
        startSmartAssistant() 
    end
    
    dialog.show()
    return true
end

local function showLatestVersionDialog(currentVer, isManual)
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(30, 30, 30, 30); layout.setBackgroundColor(0xFF0A0A0A)
    local title = TextView(service); title.setText("Check Update"); title.setTextColor(0xFF2196F3); title.setTextSize(20); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 15); layout.addView(title)
    local msgText = TextView(service); msgText.setText("You are using the latest version.\nCurrent Version: " .. currentVer); msgText.setTextColor(0xFFFFFFFF); msgText.setTextSize(15); msgText.setGravity(Gravity.CENTER); msgText.setPadding(0, 0, 0, 30); layout.addView(msgText)
    local okBtn = Button(service); okBtn.setText("OK"); okBtn.setBackgroundColor(0xFF4CAF50); okBtn.setTextColor(0xFFFFFFFF); okBtn.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
    layout.addView(okBtn)
    
    scrollView.addView(layout)
    local dialog = LuaDialog(service); dialog.setView(scrollView); dialog.setCancelable(true)
    
    okBtn.onClick = function() 
        dialog.dismiss() 
        if isManual then showSettingsDialog() end
    end
    
    dialog.show()
end

local function showUpdateAvailableDialog(serverVersion, isManual, isMaintenance)
    local scrollView = ScrollView(service)
    local layout = LinearLayout(service); layout.setOrientation(LinearLayout.VERTICAL); layout.setPadding(30, 30, 30, 30); layout.setBackgroundColor(0xFF0A0A0A)
    
    local title = TextView(service)
    title.setText(isMaintenance and "Maintenance Alert" or "Update Available")
    title.setTextColor(0xFF4CAF50); title.setTextSize(20); title.setTypeface(nil, Typeface.BOLD); title.setGravity(Gravity.CENTER); title.setPadding(0, 0, 0, 15)
    layout.addView(title)
    
    local msgText = TextView(service)
    if isMaintenance then
        msgText.setText("Spark Voice Assistant is going under maintenance. You must apply this update to proceed.")
    else
        msgText.setText("Version " .. serverVersion .. " is available. Do you want to update now?")
    end
    msgText.setTextColor(0xFFFFFFFF); msgText.setTextSize(15); msgText.setGravity(Gravity.CENTER); msgText.setPadding(0, 0, 0, 30)
    layout.addView(msgText)
    
    local btnLayout = LinearLayout(service); btnLayout.setOrientation(LinearLayout.HORIZONTAL); btnLayout.setGravity(Gravity.CENTER)
    
    local laterBtn = nil
    if not isMaintenance then
        laterBtn = Button(service)
        laterBtn.setText("Later")
        laterBtn.setBackgroundColor(0xFFF44336)
        laterBtn.setTextColor(0xFFFFFFFF)
        laterBtn.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1))
        btnLayout.addView(laterBtn)
    end
    
    local updateBtn = Button(service)
    updateBtn.setText(isMaintenance and "Apply Now" or "Update Now")
    updateBtn.setBackgroundColor(0xFF2196F3)
    updateBtn.setTextColor(0xFFFFFFFF)
    local updateParams = LinearLayout.LayoutParams(0, -2, 1)
    if not isMaintenance then updateParams.setMargins(15, 0, 0, 0) end
    updateBtn.setLayoutParams(updateParams)
    btnLayout.addView(updateBtn)
    
    layout.addView(btnLayout)
    scrollView.addView(layout)
    
    local dialog = LuaDialog(service)
    dialog.setView(scrollView)
    dialog.setCancelable(not isMaintenance) 
    
    if laterBtn then
        laterBtn.onClick = function() 
            dialog.dismiss() 
            if isManual then showSettingsDialog() end
        end
    end
    
    updateBtn.onClick = function()
        if laterBtn then laterBtn.setEnabled(false) end
        updateBtn.setEnabled(false)
        updateBtn.setText("Downloading...")
        
        speak("Downloading...")
        
        local fileUrl = isMaintenance and "https://sva-coral.vercel.app/maintenance.lua" or "https://sva-coral.vercel.app/main.lua"
        local LOCAL_FILE_PATH = "/storage/emulated/0/解说/Plugins/Spark Voice Assistant by Muhammad hanzla/main.lua"
        
        Http.download(fileUrl, LOCAL_FILE_PATH, function(dlCode, dlFile)
            if dlCode == 200 then
                dialog.dismiss()
                
                local successScroll = ScrollView(service)
                local successLayout = LinearLayout(service)
                successLayout.setOrientation(LinearLayout.VERTICAL)
                successLayout.setPadding(40, 40, 40, 40)
                successLayout.setBackgroundColor(0xFF0A0A0A)

                local successTitle = TextView(service)
                successTitle.setText("Update Successful")
                successTitle.setTextColor(0xFF4CAF50)
                successTitle.setTextSize(20)
                successTitle.setTypeface(nil, Typeface.BOLD)
                successTitle.setGravity(Gravity.CENTER)
                successTitle.setPadding(0, 0, 0, 20)
                successLayout.addView(successTitle)

                local successMsg = TextView(service)
                successMsg.setText("The assistant has been updated successfully. Please restart the plugin to apply the changes.")
                successMsg.setTextColor(0xFFFFFFFF)
                successMsg.setTextSize(15)
                successMsg.setGravity(Gravity.CENTER)
                successMsg.setPadding(0, 0, 0, 30)
                successLayout.addView(successMsg)

                local okSuccessBtn = Button(service)
                okSuccessBtn.setText("OK")
                okSuccessBtn.setBackgroundColor(0xFF4CAF50)
                okSuccessBtn.setTextColor(0xFFFFFFFF)
                okSuccessBtn.setPadding(15, 15, 15, 15)
                okSuccessBtn.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
                successLayout.addView(okSuccessBtn)

                successScroll.addView(successLayout)
                local successDialog = LuaDialog(service)
                successDialog.setView(successScroll)
                successDialog.setCancelable(false)

                okSuccessBtn.onClick = function()
                    successDialog.dismiss()
                    local homeIntent = Intent(Intent.ACTION_MAIN)
                    homeIntent.addCategory(Intent.CATEGORY_HOME)
                    homeIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    service.startActivity(homeIntent)
                end

                successDialog.show()
                speak("Update successful. Please restart.")
            else
                if laterBtn then laterBtn.setEnabled(true) end
                updateBtn.setEnabled(true)
                updateBtn.setText(isMaintenance and "Apply Now" or "Update Now")
                speak("Download failed. Code: " .. tostring(dlCode))
            end
        end)
    end
    
    dialog.show()
end

function checkForUpdates(isManual)
    local REPO_URL_BASE = "https://sva-coral.vercel.app/"
    if isManual then speak("Checking for updates...") end
    
    Http.get(REPO_URL_BASE .. "version.txt", function(code, response)
        if code == 200 and response then
            local serverVersion = response:match("^%s*(.-)%s*$")
            
            if serverVersion == "0.0" then
                showUpdateAvailableDialog("0.0", isManual, true)
            elseif serverVersion and serverVersion ~= "" and serverVersion ~= CURRENT_VERSION then
                local serverNum = tonumber(serverVersion)
                local currentNum = tonumber(CURRENT_VERSION)
                if serverNum and currentNum and serverNum > currentNum then
                    showUpdateAvailableDialog(serverVersion, isManual, false)
                else
                    if isManual then showLatestVersionDialog(CURRENT_VERSION, isManual) end
                end
            else
                if isManual then showLatestVersionDialog(CURRENT_VERSION, isManual) end
            end
        else
            if isManual then 
                showNoInternetDialog("update")
            end
        end
    end)
end

initializeTTS()

checkForUpdates(false)

if not showWelcomeDialog() then
    startSmartAssistant()
end