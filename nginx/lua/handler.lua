local template = require "resty.template"
local utils = require "utils"

template.cache = {}

template.render("view.html", { title = "Login" })
