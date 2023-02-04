local say = require("say")

local function has_error_like(state, arguments)
    if #arguments ~= 2 or type(arguments[1]) ~= "function" or type(arguments[1]) ~= "function" then return false end

    local noError, err = pcall(arguments[1])
    if noError then return false end 
    return arguments[2](err)
end

say:set("assertion.has_error_like.positive", "Expected %s\nto have matching error")
say:set("assertion.has_error_like.negative", "Expected %s\nnot to have matching error")
assert:register("assertion", "has_error_like", has_error_like, "assertion.has_error_like.positive", "assertion.has_error_like.negative")
