package com.softrism.sencha.backend.web;

import com.softrism.sencha.backend.domain.AppUser;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.encoding.ShaPasswordEncoder;

import java.util.List;

/**
 * Created with IntelliJ IDEA.
 * User: sudhir
 * Date: 4/23/13
 * Time: 8:35 PM
 * To change this template use File | Settings | File Templates.
 */

public aspect AppUserControllerAspect {

    pointcut authUser(String userid, String password) :  execution(* com.softrism.sencha.backend.web.AppUserController.jsonFindTusersByUseridEqualsAndPasswordEquals(..)) && args(userid,password);

    Object around(String userid, String password) : authUser(userid,password){
        ShaPasswordEncoder encoder = new ShaPasswordEncoder(256);
        String encoded = encoder.encodePassword(password,null);
        System.out.println("userid " + userid);
        System.out.println("encoded " + encoded);
        return proceed(userid,encoded) ;
    }

    pointcut aroundCreateUSer(String jsonUserString) : execution(* com.softrism.sencha.backend.web.AppUserController.createFromJson(..)) && args(jsonUserString);

    Object around(String jsonUserString) : aroundCreateUSer(jsonUserString){

        AppUser appUser = AppUser.fromJsonToAppUser(jsonUserString);

        String userid = appUser.getUserid();
        List tuserList = AppUser.findAppUsersByUseridEquals(userid.trim()).getResultList();
        while(tuserList.size() > 0){
            double random = Math.random();
            int count = (int)(random * 1000);
            userid = userid + count;
            tuserList = AppUser.findAppUsersByUseridEquals(userid.trim()).getResultList();
        }

        appUser.setUserid(userid);
        ShaPasswordEncoder encoder = new ShaPasswordEncoder(256);
        String password = appUser.getPassword() ;

        String encoded = encoder.encodePassword(password,null);
        appUser.setPassword(encoded);
        String finalJsonUser = appUser.toJson();

        ResponseEntity responseEntity = (ResponseEntity)proceed(finalJsonUser);

        appUser = AppUser.findAppUsersByUseridEquals(userid).getSingleResult();
        appUser.setPassword(null);

        return new ResponseEntity<String>(appUser.toJson(),responseEntity.getHeaders(), responseEntity.getStatusCode());
    }

    pointcut aroundUpdateUser(String jsonUserString) : execution(* com.softrism.sencha.backend.web.AppUserController.updateFromJson(..)) && args(jsonUserString);

    Object around(String jsonUserString) : aroundUpdateUser(jsonUserString){
        AppUser appUser = AppUser.fromJsonToAppUser(jsonUserString);

        String newUserId = appUser.getUserid();
        AppUser oldAppUser = AppUser.findAppUser(appUser.getId());

        if(! oldAppUser.getUserid().equalsIgnoreCase(appUser.getUserid())){
            List<AppUser> alreadyAppUsers= AppUser.findAppUsersByUseridEquals(appUser.getUserid()).getResultList();
            if(alreadyAppUsers.size() > 0){
                HttpHeaders headers = new HttpHeaders();
                headers.add("Content-Type", "application/json");
                return new ResponseEntity<String>(headers, HttpStatus.CONFLICT);
            }

        }

        ShaPasswordEncoder encoder = new ShaPasswordEncoder(256);
        String password = appUser.getPassword() ;
        String encoded = encoder.encodePassword(password,null);
        appUser.setPassword(encoded);

        String finalJsonUser = appUser.toJson();
        ResponseEntity responseEntity = (ResponseEntity)proceed(finalJsonUser);

        appUser = AppUser.findAppUser(appUser.getId());
        appUser.setPassword(null);
        return new ResponseEntity<String>(appUser.toJson(),responseEntity.getHeaders(), responseEntity.getStatusCode());

    }
    /*
    This does not work, neither if I move throws close with try/catch
     @Around("execution(* com.softrism.tortlets.web.TuserController.jsonFindTusersByUseridEqualsAndPasswordEquals(..)) && args(userid,password)")
     public Object myMethod(ProceedingJoinPoint jointPoint, String userid, String password) throws Throwable {
         ShaPasswordEncoder encoder = new ShaPasswordEncoder(256);
         String encoded = encoder.encodePassword(password,null);
         System.out.println("userid " + userid);
         System.out.println("encoded " + encoded);

         return jointPoint.proceed(new Object[] {userid,encoded}) ;
     }
     */


}
