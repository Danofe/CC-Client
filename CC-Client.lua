local modemSide = "back"
local monitorSide = "left"
rednet.open(modemSide)

local monitor = peripheral.find("monitor")
if monitor then
    monitor.clear()
    monitor.setTextScale(0.9)
    monitor.setCursorPos(1, 4)
    print("Monitor found! Displaying logs.")
else
    print("No monitor found on the left!")
end

local turtleID = 6
local logLines = {}
local colors = {
    black = colors.black,
    blue = colors.blue,
    green = colors.green,
    cyan = colors.cyan,
    red = colors.red,
    purple = colors.purple,
    orange = colors.orange,
    gray = colors.gray,
    lightGray = colors.lightGray,
    lightBlue = colors.lightBlue,
    lime = colors.lime,
    pink = colors.pink,
    yellow = colors.yellow,
    white = colors.white,
}

function updateMonitor(text)
    if monitor then
        table.insert(logLines, text)
        if #logLines > 20 then table.remove(logLines, 1) end
        monitor.clear()
        for i, line in ipairs(logLines) do
            monitor.setCursorPos(1, i)
            monitor.write(line)
        end
    end
end

function sendCommand(command)
    rednet.send(turtleID, { type = "command", data = command })
    updateMonitor("> " .. command)
end

function sendFile(filename)
    local file = fs.open(filename, "r")
    if not file then
        print("File not found!")
        return
    end

    local content = file.readAll()
    file.close()

    rednet.send(turtleID, { type = "file", name = filename, data = content })
    updateMonitor("File sent: " .. filename)
end

function listenForResponses()
    while true do
        local senderID, message = rednet.receive()
        if senderID == turtleID and type(message) == "string" then
            print("Turtle: " .. message)
            updateMonitor("Turtle: " .. message)
        end
    end
end

parallel.waitForAny(listenForResponses, function()
    while true do
        io.write("Enter command ('send <filename>' to transfer, 'exit' to quit): ")
        local input = io.read()
        
        if input == "w" then
            sendCommand("turtle.forward()")
        elseif input == "s" then
            sendCommand("turtle.back()")
        elseif input == "e" then
            sendCommand("turtle.up()")
        elseif input == "q" then
            sendCommand("turtle.down()")
        elseif input == "a" then
            sendCommand("turtle.turnLeft()")
        elseif input == "d" then
            sendCommand("turtle.turnRight()")
        elseif input == "exit" then break end

        local cmd, filename = input:match("send%s+(.*)")
        if cmd and filename then
            sendFile(filename)
        else
            sendCommand(input)
        end
    end
end)

rednet.close(modemSide)
