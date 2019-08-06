package com.example.hello;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class HelloController {
  @GetMapping("/")
  public String sayHello(Model model, @RequestParam(defaultValue = "World") String name) {
    model.addAttribute("name", name);
    return "hello";
  }
}
