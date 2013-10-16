package com.softrism.sencha.backend.web;

import com.softrism.sencha.backend.domain.AppUser;
import org.springframework.roo.addon.web.mvc.controller.json.RooWebJson;
import org.springframework.roo.addon.web.mvc.controller.scaffold.RooWebScaffold;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@RequestMapping("/appusers")
@Controller
@RooWebScaffold(path = "appusers", formBackingObject = AppUser.class)
@RooWebJson(jsonObject = AppUser.class)
public class AppUserController {
}
