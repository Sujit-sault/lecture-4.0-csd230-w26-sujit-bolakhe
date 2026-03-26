package csd230.bookstore.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class SpaController {

    // Match any path that doesn't contain a dot (to avoid matching .js, .css, etc)
    // and isn't an API call.
    @RequestMapping(value = "{path:[^\\.]*}")
    public String redirect() {
        // Forward to the React index.html
        return "forward:/index.html";
    }
}

