
-- VARS

message = "Hello world!"
message2 = 'World of lua'

-- CONDITIONS

condition = 250

if condition <= 10 then
    message2 = message
elseif condition > 10 and condition <= 20 then
    message2 = "from 10 to 20"
elseif condition == 25 or condition > 50 then
    message2 = "exactly 25 or greater than 50"
else
    message2 = "something else"
end

-- not equal is "~=" -- whaaat?!

-- LOOPS

counter = 0

while counter < 10 do
    counter = counter + 1
end

counter2 = 1

for i = 1, 5, 1 do
    counter2 = counter2 * i
end

for i = 10, 0, -1 do
    counter2 = counter2 - i
end

for i = 0, 100 do -- 3d param is optional
    counter2 = counter2 + 1
end

-- FUNCTIONS

num = 33
function double(num)
    num = num * 2 -- nil arg value raises exception
    return num
end
num = double(num)

--

num2 = 5
function numExec(num, fun)
    globalVar = "Ou nooo, I'm global"
    local localVar = "He he, I'm local, can't change me outside of this block of code"
    return fun(num)
end
num2 = numExec(num2, double)

-- Anonimous functions

myF = function(x, y)
    return x + y
end

--[[

Multistring comments are looks 
this one

]]

-- TABLES

scores = {}

scores[1] = 55
scores[2] = 66
scores[3] = 77

winScore = scores[3]

--

scores2 = {55, 66, 77} -- exact same table as before

table.insert(scores2, 88)

scores2["also a key"] = 99

scores2.keyAsWell = 100

--

scoreSum = 0;
for key,value in ipairs(scores) do
    scoreSum = scoreSum + value
end


-- LOVE2D MAIN METHOD

function love.draw()
    love.graphics.setFont(love.graphics.newFont(50))
    -- love.graphics.print(message2)
    -- love.graphics.print("Counter is " .. counter .. ", Counter2 is " .. counter2) -- concatenation here
    -- love.graphics.print("Function num value is " .. num)
    -- love.graphics.print("Function num2 value is " .. num2)
    -- love.graphics.print("Global var example " .. globalVar)
    -- love.graphics.print("Score2 4th row is " .. scores2[4])
    -- love.graphics.print("Score2 string key row is " .. scores2["also a key"])
    -- love.graphics.print("Another key example: " .. scores2["keyAsWell"] .. " " .. scores2.keyAsWell)
    -- love.graphics.print("scoreSum = " .. scoreSum)
    -- love.graphics.print("table last number key = " .. #scores2)
end
