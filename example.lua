local Comet = loadstring(game:HttpGet("https://your-hosted-url.com/comet.lua"))()

-- Create the main window
local Window = Comet:MakeWindow({
    Name = "Comet Demo"
})

-- Create a tab
local MainTab = Window:MakeTab({
    Name = "Main"
})

-- Add a button to the tab
MainTab:AddButton({
    Name = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})
