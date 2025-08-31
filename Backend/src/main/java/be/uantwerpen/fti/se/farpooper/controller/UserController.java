package be.uantwerpen.fti.se.farpooper.controller;

import be.uantwerpen.fti.se.farpooper.model.User;
import be.uantwerpen.fti.se.farpooper.model.dto.UserEditDto;
import be.uantwerpen.fti.se.farpooper.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/Users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/all")
    public Iterable<User> getAllUsers() {
        return  userService.GetAllUsers();
    }

    @GetMapping("/points/{uid}")
    public Integer getUserPoops(@PathVariable("uid") String uid) {
        return userService.getUserPoints(uid);
    }

    @GetMapping("/friends/{uid}")
    public Iterable<User> getFriends(@PathVariable("uid") String user1) {
        return userService.getFriends(user1);
    }

    @PutMapping("/new")
    public void createUser(@Valid @RequestBody UserEditDto user){
        try{
            userService.addUser(user);
        }catch (Exception e){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage());
        }
    }

    @PutMapping("/newFriend/{uid}/{uid2}")
    public void AddFriend(@PathVariable("uid") String user1, @PathVariable("uid2") String user2){
        userService.addFriend(user1, user2);
    }

    @PutMapping("/RemoveFriend/{uid}/{uid2}")
    public void RemoveFriend(@PathVariable("uid") String user1, @PathVariable("uid2") String user2){
        userService.removeFriend(user1, user2);
    }
}
