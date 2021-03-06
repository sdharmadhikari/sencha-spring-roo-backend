package com.softrism.sencha.backend.domain;

import org.springframework.roo.addon.javabean.RooJavaBean;
import org.springframework.roo.addon.jpa.activerecord.RooJpaActiveRecord;
import org.springframework.roo.addon.json.RooJson;
import org.springframework.roo.addon.tostring.RooToString;

@RooJavaBean
@RooToString
@RooJson
@RooJpaActiveRecord(finders = { "findAppUsersByUseridEqualsAndPasswordEquals", "findAppUsersByUseridEquals" })
public class AppUser {

    private String firstName;

    private String lastName;

    private String userid;

    private String password;

    private String userEmail;

    private String roleName;
}
